//
//  RecurlyApplePaymentData.swift
//  RecurlySDK-iOS
//

import Foundation

public struct RecurlyApplePaymentData: Codable, Sendable {
    let paymentData: RecurlyApplePaymentDataBody
    
    public init(paymentData: RecurlyApplePaymentDataBody = RecurlyApplePaymentDataBody()) {
        self.paymentData = paymentData
    }
}

public struct RecurlyApplePaymentDataBody: Codable, Sendable {
    let version: String
    let data: String
    let signature: String
    let header: RecurlyApplePaymentDataHeader
    
    public init(version: String = String(),
         data: String = String(),
         signature: String = String(),
         header: RecurlyApplePaymentDataHeader = RecurlyApplePaymentDataHeader()) {
        self.version = version
        self.data = data
        self.signature = signature
        self.header = header
    }
}

public struct RecurlyApplePaymentDataHeader: Codable, Sendable {
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
