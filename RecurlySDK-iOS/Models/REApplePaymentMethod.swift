//
//  REApplePaymentMethod.swift
//  RecurlySDK-iOS
//
//  Created by Carlos Landaverde on 22/6/22.
//

import Foundation

public struct REApplePaymentMethod: Codable {
    let paymentMethod: REApplePaymentMethodBody
    
    public init(paymentMethod: REApplePaymentMethodBody = REApplePaymentMethodBody()) {
        self.paymentMethod = paymentMethod
    }
}

public struct REApplePaymentMethodBody: Codable {
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
