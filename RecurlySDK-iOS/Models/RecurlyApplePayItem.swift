//
//  RecurlyApplePayItem.swift
//  RecurlySDK-iOS
//

import Foundation

public struct RecurlyApplePayItem {
    
    // Customize the 'Amount' label default value
    public var amountLabel: String = "Amount"
    
    // Amount value of purchase
    var amount: NSDecimalNumber
    
    // MARK: - Initializers
    
    public init(amountLabel: String,
                amount: NSDecimalNumber) {
        self.amountLabel = amountLabel
        self.amount = amount
    }
    
}
