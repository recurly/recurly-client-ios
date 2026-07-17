//
//  RecurlyTokenRequest.swift
//  RecurlySDK-iOS
//

import Foundation

/// Model That Encapsulates Card Data and/or BillingInfo request
public struct RecurlyTokenRequest: Codable, Sendable {
    var cardData: RecurlyCardData
    var billingInfo: RecurlyBillingInfo
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
