//
//  REApplePaymentMethod.swift
//  RecurlySDK-iOS
//

import Foundation

public struct REApplePaymentMethod: Codable, Sendable {
    let paymentMethod: REApplePaymentMethodBody
    
    public init(paymentMethod: REApplePaymentMethodBody = REApplePaymentMethodBody()) {
        self.paymentMethod = paymentMethod
    }
}

public struct REApplePaymentMethodBody: Codable, Sendable {
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
