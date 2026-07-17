//
//  RecurlyApplePaymentMethod.swift
//  RecurlySDK-iOS
//

import Foundation

public struct RecurlyApplePaymentMethod: Codable, Sendable {
    let paymentMethod: RecurlyApplePaymentMethodBody
    
    public init(paymentMethod: RecurlyApplePaymentMethodBody = RecurlyApplePaymentMethodBody()) {
        self.paymentMethod = paymentMethod
    }
}

public struct RecurlyApplePaymentMethodBody: Codable, Sendable {
    let displayName: String
    let network: String
    let type: String
    
    public init(displayName: String = String(),
                network: String = String(),
                type: String = String()) {
        self.displayName = displayName
        self.network = network
        self.type = type
    }
}
