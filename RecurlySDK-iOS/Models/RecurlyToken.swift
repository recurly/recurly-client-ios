//
//  RecurlyToken.swift
//  RecurlySDK-iOS
//

import Foundation

/// The token returned by a successful tokenization request.
public struct RecurlyToken: Sendable {
    /// The token id to be used for creating a subscription, purchase, or account.
    public var id: String
    /// The token type (e.g. "credit_card" or "apple_pay").
    public var type: String?
    /// Card metadata associated with the token, when available.
    public var card: RecurlyTokenCard?
}

/// Card metadata returned alongside a token.
public struct RecurlyTokenCard: Codable, Sendable {
    /// The card brand (e.g. "visa", "master", "american_express").
    public var brand: String?
    /// The first six digits of the card number (BIN).
    public var firstSix: String?
    /// The last four digits of the card number.
    public var lastFour: String?
    /// The card's expiration month.
    public var expMonth: Int?
    /// The card's expiration year.
    public var expYear: Int?
    /// ISO 3166-1 alpha-2 issuing country code. "ZZ" if unknown.
    public var issuingCountry: String?
    /// The card's funding source (e.g. "credit", "debit", "prepaid").
    public var fundingSource: String?

    enum CodingKeys: String, CodingKey {
        case brand
        case firstSix = "first_six"
        case lastFour = "last_four"
        case expMonth = "exp_month"
        case expYear = "exp_year"
        case issuingCountry = "issuing_country"
        case fundingSource = "funding_source"
    }
}
