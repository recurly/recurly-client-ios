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

    private var _cardData = RecurlyCardData()
    private var _billingInfo = RecurlyBillingInfo()
    private var _applePaymentData = RecurlyApplePaymentData()
    private var _applePaymentMethod = RecurlyApplePaymentMethod()
    private var _subscriptions = Set<AnyCancellable>()

    /// CardData (CardNumber, ExpDate, CVV)
    ///
    /// Whole-value assignment and compound field mutation are both atomic (lock held for
    /// the full read-modify-write). `lock` is non-reentrant, so don't read a lock-guarded
    /// property from within an assignment to itself or another one on this instance.
    internal var cardData: RecurlyCardData {
        get { withLock { _cardData } }
        _modify {
            lock.lock()
            defer { lock.unlock() }
            yield &_cardData
        }
    }
    /// Billing Info (First Name, Last Name, Billing Address, City, Country)
    ///
    /// See threading note on `cardData`.
    internal var billingInfo: RecurlyBillingInfo {
        get { withLock { _billingInfo } }
        _modify {
            lock.lock()
            defer { lock.unlock() }
            yield &_billingInfo
        }
    }
    /// See threading note on `cardData`.
    internal var applePaymentData: RecurlyApplePaymentData {
        get { withLock { _applePaymentData } }
        _modify {
            lock.lock()
            defer { lock.unlock() }
            yield &_applePaymentData
        }
    }
    /// See threading note on `cardData`.
    internal var applePaymentMethod: RecurlyApplePaymentMethod {
        get { withLock { _applePaymentMethod } }
        _modify {
            lock.lock()
            defer { lock.unlock() }
            yield &_applePaymentMethod
        }
    }

    private let apiClient: TokenAPIClient

    internal init(apiClient: TokenAPIClient = RecurlyAPIClient()) {
        self.apiClient = apiClient
    }

    /// Set the Billing Info that its going to be send for tokenization
    /// - Parameter billingInfo: The BillingInfo received from the User
    public func setBillingInfo(billingInfo: RecurlyBillingInfo) {
        self.billingInfo = billingInfo
    }
    
    /// Set the ApplePaymentData that its going to be send for tokenization
    /// - Parameter applePaymentData: The ApplePaymentData received from the Apple Pay flow
    public func setApplePaymentData(applePaymentData: RecurlyApplePaymentData) {
        self.applePaymentData = applePaymentData
    }
    
    /// Set the ApplePaymentMethod that its going to be send for tokenization
    /// - Parameter applePaymentData: The ApplePaymentMethod received from the Apple Pay flow
    public func setApplePaymentMethod(applePaymentMethod: RecurlyApplePaymentMethod) {
        self.applePaymentMethod = applePaymentMethod
    }
    
    /// Returns the tokenId as String from a BillingInfo or/with CardData tokenization request.
    ///
    /// Sends the CardData (CardNumber, ExpDate, CVV) and/or the BillingInfo that you want to tokenize
    ///
    /// - Parameter completion: (TokenId, Error)
    public func getTokenId(completion: @escaping (String?, RecurlyBaseErrorResponse?) -> ()) {
        getToken { token, error in
            completion(token?.id, error)
        }
    }
    
    /// Returns the tokenized `RecurlyToken` (id, type, and card metadata when present) from a BillingInfo or/with CardData tokenization request.
    ///
    /// Sends the CardData (CardNumber, ExpDate, CVV) and/or the BillingInfo that you want to tokenize
    ///
    /// - Parameter completion: (RecurlyToken, Error)
    public func getToken(completion: @escaping (RecurlyToken?, RecurlyBaseErrorResponse?) -> ()) {
        
        let tokenizationRequest = RecurlyTokenRequest(
            cardData: cardData,
            billingInfo: billingInfo,
            version: RecurlySDK.version,
            key: RecurlyConfiguration.shared.apiPublicKey,
            deviceId: getDeviceID(),
            sessionId: getSessionID()
        )
        
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
        
        subscribe(apiClient.getToken(with: tokenizationRequest, requestType: .getTokenID), completion: completion)
    }
    
    /// Returns the tokenId as String from a BillingInfo or/with ApplePaymentData, ApplePaymentMethod tokenization request.
    ///
    /// Sends the ApplePaymentData (version, data, signature, header), ApplePaymentMethod (displayName, network, type)
    /// and/or the BillingInfo that you want to tokenize
    ///
    /// - Parameter completion: (TokenId, Error)
    public func getApplePayTokenId(completion: @escaping (String?, RecurlyBaseErrorResponse?) -> ()) {
        getApplePayToken { token, error in
            completion(token?.id, error)
        }
    }
    
    /// Returns the tokenized `RecurlyToken` (id, type, and card metadata when present) from a BillingInfo or/with ApplePaymentData, ApplePaymentMethod tokenization request.
    ///
    /// Sends the ApplePaymentData (version, data, signature, header), ApplePaymentMethod (displayName, network, type)
    /// and/or the BillingInfo that you want to tokenize
    ///
    /// - Parameter completion: (RecurlyToken, Error)
    public func getApplePayToken(completion: @escaping (RecurlyToken?, RecurlyBaseErrorResponse?) -> ()) {
        
        let applePayTokenizationRequest = RecurlyApplePayTokenRequest(paymentData: applePaymentData,
                                                                 paymentMethod: applePaymentMethod,
                                                                 billingInfo: billingInfo,
                                                                 version: RecurlySDK.version,
                                                                 key: RecurlyConfiguration.shared.apiPublicKey,
                                                                 deviceId: getDeviceID(),
                                                                 sessionId: getSessionID())
        
        subscribe(apiClient.getToken(with: applePayTokenizationRequest, requestType: .getApplePayTokenID), completion: completion)
    }
    
    // MARK: - Helpers
    
    /// Subscribes to a tokenization publisher, bridging its result to `completion` and
    /// handling the error-wrap/store/remove plumbing shared by every tokenization call.
    private func subscribe<T>(_ publisher: AnyPublisher<T, Error>, completion: @escaping (T?, RecurlyBaseErrorResponse?) -> ()) {
        // `didComplete` guards against a synchronously-completing publisher (e.g. the `Fail`
        // publisher returned when request-building fails): `receiveCompletion` can run
        // *inside* `sink(...)` while `cancellable` is still nil, so `remove` below is a no-op.
        // Without this guard, `store` would then insert an already-completed cancellable that
        // never gets removed, leaking it in `_subscriptions` for the life of the manager.
        var didComplete = false
        var didEmitValue = false
        var cancellable: AnyCancellable?
        cancellable = publisher.sink(receiveCompletion: { [weak self] result in
            switch result {
            case .failure(let error as RecurlyBaseErrorResponse):
                completion(nil, error)
            case .failure(let error):
                completion(nil, RecurlyBaseErrorResponse(error: RecurlyTokenError(code: "sdk-internal",
                                                                         message: error.localizedDescription,
                                                                         details: [])))
            case .finished:
                if !didEmitValue {
                    completion(nil, RecurlyBaseErrorResponse(error: RecurlyTokenError(code: "sdk-internal",
                                                                             message: "Tokenization finished without returning a token.",
                                                                             details: [])))
                }
            }
            didComplete = true
            if let cancellable = cancellable {
                self?.remove(cancellable)
            }
        }, receiveValue: { value in
            guard !didEmitValue else { return }
            didEmitValue = true
            completion(value, nil)
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

    /// Async overload of `getToken(completion:)`. Returns the tokenized `RecurlyToken`; throws `RecurlyBaseErrorResponse` on failure.
    public func getToken() async throws -> RecurlyToken {
        try await bridgedToken(getToken)
    }

    /// Async overload of `getTokenId(completion:)`. Returns the token id; throws `RecurlyBaseErrorResponse` on failure.
    public func getTokenId() async throws -> String {
        try await getToken().id
    }

    /// Async overload of `getApplePayToken(completion:)`. Returns the tokenized `RecurlyToken`; throws `RecurlyBaseErrorResponse` on failure.
    public func getApplePayToken() async throws -> RecurlyToken {
        try await bridgedToken(getApplePayToken)
    }

    /// Async overload of `getApplePayTokenId(completion:)`. Returns the token id; throws `RecurlyBaseErrorResponse` on failure.
    public func getApplePayTokenId() async throws -> String {
        try await getApplePayToken().id
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
