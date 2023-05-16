//
//  UnifiedViewModel.swift
//  RecurlySDK-iOS
//
//  Created by David Figueroa on 29/11/21.
//

import SwiftUI

class UnifiedViewModel: ObservableObject {
    
    @Published var lastTfBorderColor = Color.gray
    
    @Published var lastCardStatus = RECardStatus.entering {
        didSet {
            switch lastCardStatus {
            case .error:
                lastTfBorderColor = .red
                tfBorderWidth = 1
            case .entering:
                lastTfBorderColor = .gray
                tfBorderWidth = 0.5
            case .success:
                lastTfBorderColor = .gray
                tfBorderWidth = 1
            }
        }
    }
    
    @Published var cardNumber: String = "" {
        didSet {
            let ccValidator = CreditCardValidator(RETokenizationManager.shared.cardData.number)
            let cardLenght = ccValidator.type == .amex ? 17 : 19
            
            if cardNumber.range(of: "[^0-9 ]+", options: .regularExpression) != nil { return }
            if cardNumber.count > cardLenght { return }
            
            if cardNumber != oldValue {
                cardNumber = CreditCardValidator.formatCCfrom(string: cardNumber)
                if cardNumber.count > cardLenght {
                    cardNumber = String(cardNumber.prefix(cardLenght))
                }
            }
            
            self.validateCreditCard()
            RETokenizationManager.shared.cardData.number = cardNumber.trimmingCharacters(in: .whitespaces)
        }
    }
    
    @Published var expDate: String = "" {
        didSet {
            if expDate.count > 5 { return }
            if expDate.range(of: "[^0-9 /]+", options: .regularExpression) != nil { return }
            if expDate.count == 1 && expDate != "1" && expDate != "0" {
                expDate = "0\(expDate)"
            }
            
            if expDate != oldValue {
                expDate = CreditCardValidator.getExpDateFrom(string: expDate)
                if expDate.count > 5 {
                    expDate = String(expDate.prefix(5))
                }
            }
            
            if expDate.isEmpty {
                cardStatus = .entering
                expDateError = false
            }
            
            if !expDate.isEmpty && expDate.count < 5 {
                cardStatus = .error
                expDateError = true
            }
            
            if expDate.count == 5 {
                validateExpDate()
            }
        }
    }
    
    @Published var cvv: String = "" {
        didSet {
            if cvv.range(of: "[^0-9 ]+", options: .regularExpression) != nil { return }
            
            let ccValidator = CreditCardValidator(RETokenizationManager.shared.cardData.number)
            let cvvLenght = ccValidator.type == .amex ? 4 : 3
            
            if cvv.isEmpty {
                cardStatus = .entering
                return
            }
            
            if cvv.count > cvvLenght { return }
            
            if cvv.count < cvvLenght {
                cardStatus = .error
                return
            }
            
            if cvv.count == cvvLenght {
                cardStatus = .success
            }
            
            if cvv != oldValue {
                if cvv.count > cvvLenght {
                    cvv = String(cvv.prefix(cvvLenght))
                }
                RETokenizationManager.shared.cardData.cvv = cvv
            }
        }
    }
    
    @Published var cvvFocus: Bool = false {
        didSet {
            if cvvFocus {
                if CreditCardValidator(cardNumber).type == .amex {
                    mainImageName = "amexCVVcardIcon"
                } else {
                    rotation = 360
                    mainImageName = "cvvCardIcon"
                }
            } else {
                rotation = 0
                validateCreditCard()
            }
        }
    }
    
    @Published var cardStatus = RECardStatus.entering {
        didSet {
            switch cardStatus {
            case .error:
                tfBorderColor = .red
                tfBorderWidth = 1
            case .entering:
                tfBorderColor = .gray
                tfBorderWidth = 0.5
            case .success:
                tfBorderColor = .gray
                tfBorderWidth = 1
            }
        }
    }
    
    @Published var mainImageName = "placeholderCCIcon"
    @Published var rotation = 0.0
    @Published var tfBorderColor = Color.gray
    @Published var tfBorderWidth = 0.5
    @Published var cardNumberError = false
    @Published var expDateError = false

    // MARK: - Initializers
    
    init() {
        FontLoader.loadFont(name: "Inter-Regular", fileExtension: "ttf")
      }
    
    // MARK: - Helpers
    
    func validateCreditCard() {
        let ccValidator = CreditCardValidator(cardNumber)
        
        if cardNumber.isEmpty {
            mainImageName = "placeholderCCIcon"
            cardStatus = .entering
            cardNumberError = false
        }
        
        if cardNumber.count > 0 && !cvvFocus {
            if let ccName = ccValidator.type {
                mainImageName = ccName.ccImage
            }
            
            cardStatus = ccValidator.isValid ? .success : .error
            cardNumberError = !ccValidator.isValid
            
        }
    }
    
    func validateExpDate() {
        
        let date = expDate.components(separatedBy: "/")
        let currentDate = Calendar.current.dateComponents([.year, .month], from: Date())
        
        let expMonth = Int(date[0]) ?? 0
        let expYear = Int("20"+date[1]) ?? 0
        
        RETokenizationManager.shared.cardData.month = String(expMonth)
        RETokenizationManager.shared.cardData.year = String(expYear)
        
        let isValidYear = (currentDate.year ?? 0) < expYear
        let isSameYear = (currentDate.year ?? 0) == expYear
        let isValidMonth = (currentDate.month ?? 0) <= expMonth
        
        if isSameYear {
            expDateError = !isValidMonth
        } else if isValidYear && expMonth <= 12 {
            expDateError = false
        } else {
            expDateError = true
        }

        validateCreditCard()
    }
}
