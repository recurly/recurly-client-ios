//
//  IndividualViewModel.swift
//  RecurlySDK-iOS
//

import SwiftUI

class IndividualViewModel: UnifiedViewModel {
    
    override func validateExpDate() {
        let date = expDate.components(separatedBy: "/")
        // An untouched field is not an error yet.
        guard date.count == 2 else {
            expDateError = !expDate.isEmpty
            cardStatus = expDate.isEmpty ? .entering : .error
            return
        }
        let currentDate = Calendar.current.dateComponents([.year, .month], from: Date())
        
        let expMonth = Int(date[0]) ?? 0
        let expYear = Int("20"+date[1]) ?? 0
        
        RecurlyTokenizationManager.shared.cardData.month = String(expMonth)
        RecurlyTokenizationManager.shared.cardData.year = String(expYear)
        
        let isValidYear = (currentDate.year ?? 0) < expYear
        let isSameYear = (currentDate.year ?? 0) == expYear
        let isValidMonth = (currentDate.month ?? 0) <= expMonth
        
        cardStatus = .entering
        if isSameYear {
            expDateError = !isValidMonth
        } else if isValidYear && expMonth <= 12{
            expDateError = false
        } else {
            expDateError = true
            cardStatus = .error
        }
    }
}
