//
//  RECardRequest.swift
//  RecurlySDK-iOS
//
//  Created by David Figueroa on 2/12/21.
//

import Foundation

// Recurly Billing Info Data Model
public struct REBillingInfo: Codable {
    
    /// Cardholder first name. Required
    var firstName: String
    /// Cardholder last name. Required
    var lastName: String
    /// First line of a street address.
    var address1: String
    /// Second line of a street address.
    var address2: String
    /// Company Name
    var company: String
    /// ISO 3166-1 alpha-2 country code.
    var country: String
    /// Town or locality.
    var city: String
    /// Province or region.
    var state: String
    /// Postal code.
    var postalCode: String
    /// Phone number.
    var phone: String
    /// Customer VAT number. Used for VAT exclusion
    var vatNumber: String
    /// A valid CPF or CUIT. Required if it is a consumer card in Brazil early access or in Argentina.
    var taxIdentifier: String? = nil
    ///  cpf and cuit are the only accepted values for this field. Required if it is a consumer card in Brazil early access or in Argentina.
    var taxIdentifierType: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case address1
        case address2
        case company
        case country
        case city
        case state
        case postalCode = "postal_code"
        case phone
        case vatNumber = "vat_number"
        case taxIdentifier = "tax_identifier"
        case taxIdentifierType = "tax_identifier_type"
    }
    
    public init(firstName: String = "",
                lastName: String = "",
                address1: String = "",
                address2: String = "",
                company: String = "",
                country: String = "",
                city: String = "",
                state: String = "",
                postalCode: String = "",
                phone: String = "",
                vatNumber: String = "",
                taxIdentifier: String? = nil,
                taxIdentifierType: String? = nil) {
        
        self.firstName = firstName
        self.lastName = lastName
        self.address1 = address1
        self.address2 = address2
        self.company = company
        self.country = country
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.phone = phone
        self.vatNumber = vatNumber
        self.taxIdentifier = taxIdentifier
        self.taxIdentifierType = taxIdentifierType
    }
}
