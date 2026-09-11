//
//  RecurlyTokenizationManager.swift
//  RecurlySDK-iOS
//

import Combine
import SwiftUI

/// Tokenization Manager for sending sensitive user data and receiving the tokenId from the submitted data.
public final class RecurlyTokenizationManager {
    /// Singleton shared instance
    public static let shared = RecurlyTokenizationManager()

    private let lock = NSLock()

    /// Runs `body` while holding `lock`, releasing it afterwards even if `body` throws/returns early.
    private func withLock<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }

    private var _subscriptions = Set<AnyCancellable>()

    private let apiClient: TokenAPIClient

    internal init(apiClient: TokenAPIClient = RecurlyAPIClient()) {
        self.apiClient = apiClient
    }

    /// Returns the tokenId as String from a `RecurlyCardSession` and/or `RecurlyBillingInfo` tokenization request.
    ///
    /// Reads the CardData (CardNumber, ExpDate, CVV) currently held by `session` and, by default,
    /// resets `session` on success. Pass `resetOnSuccess: false` to keep the entered data, e.g. to
    /// retry against a second gateway or to redisplay a saved card; call `session.reset()` manually
    /// when you're ready to clear it.
    ///
    /// - Parameter session: The card session to tokenize and, on success, reset.
    /// - Parameter billingInfo: The BillingInfo to include, if any.
    /// - Parameter resetOnSuccess: Whether to reset `session` after a successful tokenization. Defaults to `true`.
    /// - Parameter completion: (TokenId, Error)
    public func getTokenId(session: RecurlyCardSession, billingInfo: RecurlyBillingInfo = RecurlyBillingInfo(), resetOnSuccess: Bool = true, completion: @escaping (String?, RecurlyBaseErrorResponse?) -> ()) {
        getToken(session: session, billingInfo: billingInfo, resetOnSuccess: resetOnSuccess) { token, error in
            completion(token?.id, error)
        }
    }

    /// Returns the tokenized `RecurlyToken` (id, type, and card metadata when present) from a `RecurlyCardSession` and/or `RecurlyBillingInfo` tokenization request.
    ///
    /// Reads the CardData (CardNumber, ExpDate, CVV) currently held by `session` and, by default,
    /// resets `session` on success. Pass `resetOnSuccess: false` to keep the entered data, e.g. to
    /// retry against a second gateway or to redisplay a saved card; call `session.reset()` manually
    /// when you're ready to clear it.
    ///
    /// - Parameter session: The card session to tokenize and, on success, reset.
    /// - Parameter billingInfo: The BillingInfo to include, if any.
    /// - Parameter resetOnSuccess: Whether to reset `session` after a successful tokenization. Defaults to `true`.
    /// - Parameter completion: (RecurlyToken, Error)
    public func getToken(session: RecurlyCardSession, billingInfo: RecurlyBillingInfo = RecurlyBillingInfo(), resetOnSuccess: Bool = true, completion: @escaping (RecurlyToken?, RecurlyBaseErrorResponse?) -> ()) {
        // Hop onto `session`'s `@MainActor` to read `cardData` safely from any thread.
        // `self` stays strong: a weak capture here can drop `completion` before it fires.
        Task { @MainActor in
            let cardData = session.cardData

            guard !cardData.cvv.isEmpty else {
                completion(
                    nil,
                    RecurlyBaseErrorResponse(
                        error: RecurlyTokenError(
                            code: "validation",
                            message: "cvv is required",
                            details: []
                        )
                    )
                )
                return
            }

            let tokenizationRequest = RecurlyTokenRequest(
                cardData: cardData,
                billingInfo: billingInfo,
                version: RecurlySDK.version,
                key: RecurlyConfiguration.shared.apiPublicKey,
                deviceId: self.getDeviceID(),
                sessionId: self.getSessionID()
            )

            self.subscribe(self.apiClient.getToken(with: tokenizationRequest, requestType: .getTokenID), completion: self.clearingSessionOnSuccess(session, resetOnSuccess: resetOnSuccess, completion))
        }
    }

    /// Returns the tokenId as String from ApplePaymentData, ApplePaymentMethod, and/or BillingInfo.
    ///
    /// Sends the ApplePaymentData (version, data, signature, header), ApplePaymentMethod (displayName, network, type)
    /// and/or the BillingInfo that you want to tokenize
    ///
    /// - Parameter paymentData: The Apple Pay payment data to tokenize.
    /// - Parameter paymentMethod: The Apple Pay payment method to tokenize.
    /// - Parameter billingInfo: The BillingInfo to include, if any.
    /// - Parameter completion: (TokenId, Error)
    public func getApplePayTokenId(paymentData: RecurlyApplePaymentData, paymentMethod: RecurlyApplePaymentMethod, billingInfo: RecurlyBillingInfo = RecurlyBillingInfo(), completion: @escaping (String?, RecurlyBaseErrorResponse?) -> ()) {
        getApplePayToken(paymentData: paymentData, paymentMethod: paymentMethod, billingInfo: billingInfo) { token, error in
            completion(token?.id, error)
        }
    }

    /// Returns the tokenized `RecurlyToken` (id, type, and card metadata when present) from ApplePaymentData, ApplePaymentMethod, and/or BillingInfo.
    ///
    /// Sends the ApplePaymentData (version, data, signature, header), ApplePaymentMethod (displayName, network, type)
    /// and/or the BillingInfo that you want to tokenize
    ///
    /// - Parameter paymentData: The Apple Pay payment data to tokenize.
    /// - Parameter paymentMethod: The Apple Pay payment method to tokenize.
    /// - Parameter billingInfo: The BillingInfo to include, if any.
    /// - Parameter completion: (RecurlyToken, Error)
    public func getApplePayToken(paymentData: RecurlyApplePaymentData, paymentMethod: RecurlyApplePaymentMethod, billingInfo: RecurlyBillingInfo = RecurlyBillingInfo(), completion: @escaping (RecurlyToken?, RecurlyBaseErrorResponse?) -> ()) {

        let applePayTokenizationRequest = RecurlyApplePayTokenRequest(paymentData: paymentData,
                                                                 paymentMethod: paymentMethod,
                                                                 billingInfo: billingInfo,
                                                                 version: RecurlySDK.version,
                                                                 key: RecurlyConfiguration.shared.apiPublicKey,
                                                                 deviceId: getDeviceID(),
                                                                 sessionId: getSessionID())

        subscribe(apiClient.getToken(with: applePayTokenizationRequest, requestType: .getApplePayTokenID), completion: completion)
    }

    // MARK: - Helpers

    /// Wraps `completion` to reset `session` on success when `resetOnSuccess` is `true`.
    private func clearingSessionOnSuccess(
        _ session: RecurlyCardSession,
        resetOnSuccess: Bool,
        _ completion: @escaping (RecurlyToken?, RecurlyBaseErrorResponse?) -> ()
    ) -> (RecurlyToken?, RecurlyBaseErrorResponse?) -> () {
        { token, error in
            // Same `Task`, reset before completion — two separate Tasks could run out of order.
            Task { @MainActor in
                if token != nil && resetOnSuccess {
                    session.reset()
                }
                completion(token, error)
            }
        }
    }

    /// Subscribes to a tokenization publisher, bridging its result to `completion` and
    /// handling the error-wrap/store/remove plumbing shared by every tokenization call.
    private func subscribe<T>(_ publisher: AnyPublisher<T, Error>, completion: @escaping (T?, RecurlyBaseErrorResponse?) -> ()) {
        // `didComplete` stops a synchronously-completing publisher from leaking a cancellable
        // `store` would otherwise insert after `remove` already ran as a no-op.
        // `didCallCompletion` stops a double completion call, since Combine can emit a value
        // then still fail, and `bridgedToken`'s continuation crashes on a double resume.
        // `completion` always delivers on the main thread, matching `RecurlyApplePaymentHandler`.
        var didComplete = false
        var didCallCompletion = false
        var cancellable: AnyCancellable?
        cancellable = publisher.sink(receiveCompletion: { [weak self] result in
            switch result {
            case .failure(let error as RecurlyBaseErrorResponse):
                if !didCallCompletion {
                    didCallCompletion = true
                    DispatchQueue.main.async { completion(nil, error) }
                }
            case .failure(let error):
                if !didCallCompletion {
                    didCallCompletion = true
                    let wrapped = RecurlyBaseErrorResponse(error: RecurlyTokenError(code: "sdk-internal",
                                                                             message: error.localizedDescription,
                                                                             details: []))
                    DispatchQueue.main.async { completion(nil, wrapped) }
                }
            case .finished:
                if !didCallCompletion {
                    didCallCompletion = true
                    let wrapped = RecurlyBaseErrorResponse(error: RecurlyTokenError(code: "sdk-internal",
                                                                             message: "Tokenization finished without returning a token.",
                                                                             details: []))
                    DispatchQueue.main.async { completion(nil, wrapped) }
                }
            }
            didComplete = true
            if let cancellable = cancellable {
                self?.remove(cancellable)
            }
        }, receiveValue: { value in
            guard !didCallCompletion else { return }
            didCallCompletion = true
            DispatchQueue.main.async { completion(value, nil) }
        })
        if !didComplete, let cancellable = cancellable {
            store(cancellable)
        }
    }

    /// Inserts `cancellable` into the subscription set atomically (single locked operation).
    private func store(_ cancellable: AnyCancellable) {
        withLock { _subscriptions.insert(cancellable) }
    }

    /// Drops a completed subscription so `_subscriptions` doesn't grow unbounded
    /// across repeated calls.
    private func remove(_ cancellable: AnyCancellable) {
        withLock { _subscriptions.remove(cancellable) }
    }
    
    private func getDeviceID() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    private func getSessionID() -> String {
        return RecurlyConfiguration.shared.sessionId.uuidString
    }
}

// MARK: - Async/Await

extension RecurlyTokenizationManager {

    /// Async overload of `getToken(session:billingInfo:resetOnSuccess:completion:)`. Returns the tokenized `RecurlyToken`; throws `RecurlyBaseErrorResponse` on failure.
    /// - Parameter resetOnSuccess: When `true` (the default), `session` is reset on success before this
    ///   function returns. Pass `false` to keep the entered data, e.g. to retry against a second gateway
    ///   or to redisplay a saved card; call `session.reset()` manually when you're ready to clear it.
    public func getToken(session: RecurlyCardSession, billingInfo: RecurlyBillingInfo = RecurlyBillingInfo(), resetOnSuccess: Bool = true) async throws -> RecurlyToken {
        try await bridgedToken { completion in
            self.getToken(session: session, billingInfo: billingInfo, resetOnSuccess: resetOnSuccess, completion: completion)
        }
    }

    /// Async overload of `getTokenId(session:billingInfo:resetOnSuccess:completion:)`. Returns the token id; throws `RecurlyBaseErrorResponse` on failure.
    /// - Parameter resetOnSuccess: When `true` (the default), `session` is reset on success before this
    ///   function returns. Pass `false` to keep the entered data, e.g. to retry against a second gateway
    ///   or to redisplay a saved card; call `session.reset()` manually when you're ready to clear it.
    public func getTokenId(session: RecurlyCardSession, billingInfo: RecurlyBillingInfo = RecurlyBillingInfo(), resetOnSuccess: Bool = true) async throws -> String {
        try await getToken(session: session, billingInfo: billingInfo, resetOnSuccess: resetOnSuccess).id
    }

    /// Async overload of `getApplePayToken(paymentData:paymentMethod:billingInfo:completion:)`. Returns the tokenized `RecurlyToken`; throws `RecurlyBaseErrorResponse` on failure.
    public func getApplePayToken(paymentData: RecurlyApplePaymentData, paymentMethod: RecurlyApplePaymentMethod, billingInfo: RecurlyBillingInfo = RecurlyBillingInfo()) async throws -> RecurlyToken {
        try await bridgedToken { completion in
            self.getApplePayToken(paymentData: paymentData, paymentMethod: paymentMethod, billingInfo: billingInfo, completion: completion)
        }
    }

    /// Async overload of `getApplePayTokenId(paymentData:paymentMethod:billingInfo:completion:)`. Returns the token id; throws `RecurlyBaseErrorResponse` on failure.
    public func getApplePayTokenId(paymentData: RecurlyApplePaymentData, paymentMethod: RecurlyApplePaymentMethod, billingInfo: RecurlyBillingInfo = RecurlyBillingInfo()) async throws -> String {
        try await getApplePayToken(paymentData: paymentData, paymentMethod: paymentMethod, billingInfo: billingInfo).id
    }

    /// Bridges a completion-handler tokenization call to async. The single-`completion`-call
    /// contract of `subscribe(_:completion:)` is load-bearing here: a checked continuation
    /// crashes if resumed twice.
    private func bridgedToken(
        _ call: (@escaping (RecurlyToken?, RecurlyBaseErrorResponse?) -> ()) -> Void
    ) async throws -> RecurlyToken {
        try await withCheckedThrowingContinuation { continuation in
            call { token, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let token {
                    continuation.resume(returning: token)
                } else {
                    continuation.resume(throwing: RecurlyBaseErrorResponse(
                        error: RecurlyTokenError(code: "sdk-internal",
                                                  message: "Tokenization completed without a token or an error.",
                                                  details: [])
                    ))
                }
            }
        }
    }
}
