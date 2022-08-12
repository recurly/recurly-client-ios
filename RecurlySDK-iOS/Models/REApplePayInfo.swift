//
//  REApplePayInfo.swift
//  RecurlySDK-iOS
//
//  Created by Carlos Landaverde on 12/1/22.
//

import Foundation
import PassKit

public struct REApplePayInfo {
    
    // Customize the 'Total' label default value
    public var totalLabel: String = "Total"
    
    // Current country code
    public var countryCode: String = "US"
    
    // Current currency code
    public var currencyCode: String = "USD"
    
    // Identifies the merchant, as previously agreed with Apple. Must match one of the merchant
    // identifiers in the application's entitlement.
    // https://developer.apple.com/apple-pay/sandbox-testing/
    public var merchantIdentifier: String = "merchant.com.YOURDOMAIN.YOURAPPNAME"
    
    // Required fields of user to create billing info
    public var requiredContactFields: Set<PKContactField> = [.name, .phoneNumber, .postalAddress]
    
    // Items displayed on the summary of purchase
    public var purchaseItems: [REApplePayItem]
    
    // MARK: - Initializers
    
    public init(purchaseItems: [REApplePayItem]) {
        self.purchaseItems = purchaseItems
    }
    
    // Internal function to retrieve the 'PKPaymentSummaryItem' objects
    // This items are displayed on a list to calculate the total of the purchase
    public func paymentSummaryItems() -> [PKPaymentSummaryItem] {
        var result = [PKPaymentSummaryItem]()
        var total = NSDecimalNumber(string: "0.00")
        
        purchaseItems.forEach {
            result.append(PKPaymentSummaryItem(label: $0.amountLabel, amount: $0.amount, type: .final))
            total = $0.amount.adding(total)
        }
        
        // Calculate the final total of items
        if result.count > 0 {
            result.append(PKPaymentSummaryItem(label: totalLabel, amount: total, type: .final))
        } else {
            result.append(PKPaymentSummaryItem(label: totalLabel, amount: total, type: .pending))
        }
        
        return result
    }
    
}
