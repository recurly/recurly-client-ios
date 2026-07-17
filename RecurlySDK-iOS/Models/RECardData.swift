//
//  RECardData.swift
//  RecurlySDK-iOS
//

import Foundation

/// Recurly Card Data Model
public struct RECardData: Codable, Sendable {
    /// Credit Card number
    var number: String = ""
    /// Expiration Month
    var month: String = ""
    /// Expiration Year
    var year: String = ""
    /// Security Code
    var cvv: String = ""
}
