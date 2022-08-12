//
//  RETokenizationRequest.swift
//  RecurlySDK-iOS
//
//  Created by David Figueroa on 5/12/21.
//

import Foundation

/// Model That Encapsulates Card Data and/or BillingInfo request
public struct RETokenRequest: Codable {
    var cardData: RECardData
    var billingInfo: REBillingInfo
    var version: String
    var key: String
    var deviceId: String
    var sessionId: String
    
    /// Encode the Codable Objects with version, key, deviceId and sessionId
    /// - Parameter encoder: Custom Encoder
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try cardData.encode(to: encoder)
        try billingInfo.encode(to: encoder)
        try container.encode(version, forKey: .version)
        try container.encode(key, forKey: .key)
        try container.encode(deviceId, forKey: .deviceId)
        try container.encode(sessionId, forKey: .sessionId)
    }
}
