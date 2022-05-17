//
//  RETokenizationManager.swift
//  RecurlySDK-iOS
//
//  Created by David Figueroa on 5/12/21.
//

import Combine
import UIKit.UIApplication
import UIKit

/// Tokenization Manager for sending sensitive user data and receiving the tokenId from the submitted data.
public struct RETokenizationManager {
    /// Singleton shared instance
    public static var shared = RETokenizationManager()
    /// CardData (CardNumber, ExpDate, CVV)
    internal var cardData = RECardData()
    /// Billing Info (First Name, Last Name, Billing Address, City, Country)
    internal var billingInfo = REBillingInfo()
    private let apiClient = REAPIClient()
    private var subscriptions = Set<AnyCancellable>()
    

    /// Set the Billing Info that its going to be send for tokenization
    /// - Parameter billingInfo: The BillingInfo received from the User
    public mutating func setBillingInfo(billingInfo: REBillingInfo) {
        self.billingInfo = billingInfo
    }
    
    /// Returns the tokenId as String from a BillingInfo or/with CardData tokenization request.
    ///
    /// Sends the CardData (CardNumber, ExpDate, CVV) and/or the BillingInfo that you want to tokenize
    ///
    ///
    /// - Parameter completion: (TokenId, Error)
    public mutating func getTokenId(completion: @escaping (String?, REBaseErrorResponse?) -> ()) {
        
        let tokenizationRequest = RETokenRequest(cardData: cardData,
                                                 billingInfo: billingInfo,
                                                 version: UIApplication.version,
                                                 key: REConfiguration.shared.apiPublicKey,
                                                 deviceId: getDeviceID(),
                                                 sessionId: getSessionID())
        
        if !cardData.cvv.isEmpty {
            apiClient.getTokenID(dataRequest: tokenizationRequest).sink { result in
                switch result {
                case .failure(let error as REBaseErrorResponse):
                    completion(nil, error)
                default: break
                }
            } receiveValue: { token in
                completion(token, nil)
            }.store(in: &subscriptions)
        } else {
            completion(nil,
                       REBaseErrorResponse(
                        error: RETokenError(code: "validation",
                                            message: "cvv is required",
                                            details: [])
                       )
            )
        }
    }
    
    private func getDeviceID() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    private func getSessionID() -> String {
        return REConfiguration.shared.sessionId.uuidString
    }
}
