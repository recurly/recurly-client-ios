//
//  REApplePayTokenRequest.swift
//  RecurlySDK-iOS
//
//  Created by Carlos Landaverde on 21/6/22.
//

import Foundation

/// Model That Encapsulates Apple Pay and/or BillingInfo request
public struct REApplePayTokenRequest: Codable {
    var paymentData: REApplePaymentData
    var paymentMethod: REApplePaymentMethod
    var billingInfo: REBillingInfo
    var version: String
    var key: String
    var deviceId: String
    var sessionId: String
    
    /// Encode the Codable Objects with version, key, deviceId and sessionId
    /// - Parameter encoder: Custom Encoder
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try paymentData.encode(to: encoder)
        try paymentMethod.encode(to: encoder)
        try billingInfo.encode(to: encoder)
        try container.encode(version, forKey: .version)
        try container.encode(key, forKey: .key)
        try container.encode(deviceId, forKey: .deviceId)
        try container.encode(sessionId, forKey: .sessionId)
    }
}
