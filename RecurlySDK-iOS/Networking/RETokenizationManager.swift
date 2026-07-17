//
//  RETokenizationManager.swift
//  RecurlySDK-iOS
//

import Combine
import SwiftUI

/// Tokenization Manager for sending sensitive user data and receiving the tokenId from the submitted data.
public final class RETokenizationManager {
    /// Singleton shared instance
    public static let shared = RETokenizationManager()

    private let lock = NSLock()

    /// Runs `body` while holding `lock`, releasing it afterwards even if `body` throws/returns early.
    private func withLock<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }

    private var _cardData = RECardData()
    private var _billingInfo = REBillingInfo()
    private var _applePaymentData = REApplePaymentData()
    private var _applePaymentMethod = REApplePaymentMethod()
    private var _subscriptions = Set<AnyCancellable>()

    /// CardData (CardNumber, ExpDate, CVV)
    ///
    /// Whole-value assignment and compound field mutation are both atomic (lock held for
    /// the full read-modify-write). `lock` is non-reentrant, so don't read a lock-guarded
    /// property from within an assignment to itself or another one on this instance.
    internal var cardData: RECardData {
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
    internal var billingInfo: REBillingInfo {
        get { withLock { _billingInfo } }
        _modify {
            lock.lock()
            defer { lock.unlock() }
            yield &_billingInfo
        }
    }
    /// See threading note on `cardData`.
    internal var applePaymentData: REApplePaymentData {
        get { withLock { _applePaymentData } }
        _modify {
            lock.lock()
            defer { lock.unlock() }
            yield &_applePaymentData
        }
    }
    /// See threading note on `cardData`.
    internal var applePaymentMethod: REApplePaymentMethod {
        get { withLock { _applePaymentMethod } }
        _modify {
            lock.lock()
            defer { lock.unlock() }
            yield &_applePaymentMethod
        }
    }

    private let apiClient: REAPIClient

    internal init(apiClient: REAPIClient = REAPIClient()) {
        self.apiClient = apiClient
    }

    /// Set the Billing Info that its going to be send for tokenization
    /// - Parameter billingInfo: The BillingInfo received from the User
    public func setBillingInfo(billingInfo: REBillingInfo) {
        self.billingInfo = billingInfo
    }
    
    /// Set the ApplePaymentData that its going to be send for tokenization
    /// - Parameter applePaymentData: The ApplePaymentData received from the Apple Pay flow
    public func setApplePaymentData(applePaymentData: REApplePaymentData) {
        self.applePaymentData = applePaymentData
    }
    
    /// Set the ApplePaymentMethod that its going to be send for tokenization
    /// - Parameter applePaymentData: The ApplePaymentMethod received from the Apple Pay flow
    public func setApplePaymentMethod(applePaymentMethod: REApplePaymentMethod) {
        self.applePaymentMethod = applePaymentMethod
    }
    
    /// Returns the tokenId as String from a BillingInfo or/with CardData tokenization request.
    ///
    /// Sends the CardData (CardNumber, ExpDate, CVV) and/or the BillingInfo that you want to tokenize
    ///
    /// - Parameter completion: (TokenId, Error)
    public func getTokenId(completion: @escaping (String?, REBaseErrorResponse?) -> ()) {
        
        let tokenizationRequest = RETokenRequest(
            cardData: cardData,
            billingInfo: billingInfo,
            version: RecurlySDK.version,
            key: REConfiguration.shared.apiPublicKey,
            deviceId: getDeviceID(),
            sessionId: getSessionID()
        )
        
        guard !cardData.cvv.isEmpty else {
            completion(
                nil,
                REBaseErrorResponse(
                    error: RETokenError(
                        code: "validation",
                        message: "cvv is required",
                        details: []
                    )
                )
            )
            return
        }
        
        var cancellable: AnyCancellable?
        cancellable = apiClient.getTokenID(with: tokenizationRequest, requestType: .getTokenID).sink(receiveCompletion: { [weak self] result in
            switch result {
            case .failure(let error as REBaseErrorResponse):
                completion(nil, error)
            case .failure(let error):
                completion(nil, REBaseErrorResponse(error: RETokenError(code: "sdk-internal",
                                                                         message: error.localizedDescription,
                                                                         details: [])))
            case .finished:
                break
            }
            if let cancellable = cancellable {
                self?.remove(cancellable)
            }
        }, receiveValue: { token in
            completion(token, nil)
        })
        if let cancellable = cancellable {
            store(cancellable)
        }
    }
    
    /// Returns the tokenId as String from a BillingInfo or/with ApplePaymentData, ApplePaymentMethod tokenization request.
    ///
    /// Sends the ApplePaymentData (version, data, signature, header), ApplePaymentMethod (displayName, network, type)
    /// and/or the BillingInfo that you want to tokenize
    ///
    /// - Parameter completion: (TokenId, Error)
    public func getApplePayTokenId(completion: @escaping (String?, REBaseErrorResponse?) -> ()) {
        
        let applePayTokenizationRequest = REApplePayTokenRequest(paymentData: applePaymentData,
                                                                 paymentMethod: applePaymentMethod,
                                                                 billingInfo: billingInfo,
                                                                 version: RecurlySDK.version,
                                                                 key: REConfiguration.shared.apiPublicKey,
                                                                 deviceId: getDeviceID(),
                                                                 sessionId: getSessionID())
        
        var cancellable: AnyCancellable?
        cancellable = apiClient.getTokenID(with: applePayTokenizationRequest, requestType: .getApplePayTokenID).sink(receiveCompletion: { [weak self] result in
            switch result {
            case .failure(let error as REBaseErrorResponse):
                completion(nil, error)
            case .failure(let error):
                completion(nil, REBaseErrorResponse(error: RETokenError(code: "sdk-internal",
                                                                         message: error.localizedDescription,
                                                                         details: [])))
            case .finished:
                break
            }
            if let cancellable = cancellable {
                self?.remove(cancellable)
            }
        }, receiveValue: { token in
            completion(token, nil)
        })
        if let cancellable = cancellable {
            store(cancellable)
        }
    }
    
    // MARK: - Helpers
    
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
        return REConfiguration.shared.sessionId.uuidString
    }
}
