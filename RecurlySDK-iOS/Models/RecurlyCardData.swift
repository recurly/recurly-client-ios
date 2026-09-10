//
//  RecurlyCardData.swift
//  RecurlySDK-iOS
//

import Foundation

/// Recurly Card Data Model
public struct RecurlyCardData: Codable, Sendable {
    /// Credit Card number
    var number: String = ""
    /// Expiration Month
    var month: String = ""
    /// Expiration Year
    var year: String = ""
    /// Security Code
    var cvv: String = ""
}

extension RecurlyCardData: CustomDebugStringConvertible, CustomStringConvertible {
    /// Redacted so card data never appears in cleartext in logs, `po`, or crash reports.
    public var debugDescription: String { "RecurlyCardData(<redacted>)" }
    public var description: String { debugDescription }
}
