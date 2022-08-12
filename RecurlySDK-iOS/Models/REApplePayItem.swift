//
//  REApplePayItem.swift
//  RecurlySDK-iOS
//
//  Created by Carlos Landaverde on 14/1/22.
//

import Foundation

public struct REApplePayItem {
    
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
