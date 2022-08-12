//
//  IndividualViewModel.swift
//  RecurlySDK-iOS
//
//  Created by David Figueroa on 29/11/21.
//

import SwiftUI

class IndividualViewModel: UnifiedViewModel {
    
    override func validateExpDate() {
        let date = expDate.components(separatedBy: "/")
        let currentDate = Calendar.current.dateComponents([.year, .month], from: Date())
        
        let expMonth = Int(date[0]) ?? 0
        let expYear = Int("20"+date[1]) ?? 0
        
        RETokenizationManager.shared.cardData.month = String(expMonth)
        RETokenizationManager.shared.cardData.year = String(expYear)
        
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
