//
//  REApplePaymentData.swift
//  RecurlySDK-iOS
//
//  Created by Carlos Landaverde on 21/6/22.
//

import Foundation

public struct REApplePaymentData: Codable {
    let paymentData: REApplePaymentDataBody
    
    public init(paymentData: REApplePaymentDataBody = REApplePaymentDataBody()) {
        self.paymentData = paymentData
    }
}

public struct REApplePaymentDataBody: Codable {
    let version: String
    let data: String
    let signature: String
    let header: REApplePaymentDataHeader
    
    public init(version: String = String(),
         data: String = String(),
         signature: String = String(),
         header: REApplePaymentDataHeader = REApplePaymentDataHeader()) {
        self.version = version
        self.data = data
        self.signature = signature
        self.header = header
    }
}

public struct REApplePaymentDataHeader: Codable {
    let ephemeralPublicKey: String
    let publicKeyHash: String
    let transactionId: String
    
    public init(ephemeralPublicKey: String = String(),
         publicKeyHash: String = String(),
         transactionId: String = String()) {
        self.ephemeralPublicKey = ephemeralPublicKey
        self.publicKeyHash = publicKeyHash
        self.transactionId = transactionId
    }
}
