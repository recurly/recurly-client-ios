//
//  RECardData.swift
//  RecurlySDK-iOS
//
//  Created by David Figueroa on 5/12/21.
//

import Foundation

/// Recurly Card Data Model
public struct RECardData: Codable {
    /// Credit Card number
    var number: String = ""
    /// Expiration Month
    var month: String = ""
    /// Expiration Year
    var year: String = ""
    /// Security Code
    var cvv: String = ""
}
