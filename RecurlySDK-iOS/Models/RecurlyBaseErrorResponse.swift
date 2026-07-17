//
//  RecurlyBaseErrorResponse.swift
//  RecurlySDK-iOS
//

import Foundation

/// Base Model containing an Error (RecurlyTokenError)
public struct RecurlyBaseErrorResponse: Codable, Error, Sendable {
    public var error: RecurlyTokenError
}

/// The Model for mapping a Tokenization Error Response
public struct RecurlyTokenError: Codable, Sendable {
    /// The Recurly error code (see Tokenization section) [Recurly Error Codes](https://developers.recurly.com/reference/recurly-js/index.html#errors)
    public var code: String?
    /// Internal error message contains diagnostic information intended to help you diagnose problems with the form, and we do not recommend displaying its contents to your customers.
    public var message: String?
    /// details about the error
    public var details: [RecurlyTokenDetails]?
}

/// Codable Model for mapping Error details
public struct RecurlyTokenDetails: Codable, Sendable {
    /// The Field in which the error ocurred
    public var field: String?
    /// The Error message related to the field
    public var messages: [String]?
}
