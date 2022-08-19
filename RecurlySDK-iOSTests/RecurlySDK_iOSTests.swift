//
//  RecurlySDK_iOSTests.swift
//  RecurlySDK-iOSTests
//
//  Created by David Figueroa on 22/11/21.
//

import XCTest
@testable import RecurlySDK_iOS

class RecurlySDK_iOSTests: XCTestCase {
    
    let paymentHandler = REApplePaymentHandler()

    func testTokenization() throws {
        //Initialize the SDK
        REConfiguration.shared.initialize(publicKey: "ewr1-4TIXlPCkR68woNJp7UYMSL")
        
        let billingInfo = REBillingInfo(firstName: "David",
                                        lastName: "Figueroa",
                                        address1: "123 Main St",
                                        address2: "",
                                        company: "CH2",
                                        country: "USA",
                                        city: "Miami",
                                        state: "Florida",
                                        postalCode: "33101",
                                        phone: "555-555-5555",
                                        vatNumber: "",
                                        taxIdentifier: "",
                                        taxIdentifierType: "")
        
        RETokenizationManager.shared.setBillingInfo(billingInfo: billingInfo)
        RETokenizationManager.shared.cardData.number = "4111111111111111"
        RETokenizationManager.shared.cardData.month = "12"
        RETokenizationManager.shared.cardData.year = "2022"
        RETokenizationManager.shared.cardData.cvv = "123"
        
        let tokenResponseExpectation = expectation(description: "TokenResponse")
        RETokenizationManager.shared.getTokenId { tokenId, error in
            if let errorResponse = error {
                XCTFail(errorResponse.error.message ?? "")
                return
            }
            XCTAssertNotNil(tokenId)
            XCTAssertGreaterThan((tokenId?.count ?? 0), 5)
            tokenResponseExpectation.fulfill()
        }
        wait(for: [tokenResponseExpectation], timeout: 5.0)
    }
    
    func testApplePayIsSupported() {
        XCTAssertTrue(paymentHandler.applePaySupported(), "Apple Pay is not supported")
    }
    
    func testApplePayTokenization() {
        
        paymentHandler.isTesting = true
        
        var items = [REApplePayItem]()
        items.append(REApplePayItem(amountLabel: "Foo",
                                    amount: NSDecimalNumber(string: "3.80")))
        items.append(REApplePayItem(amountLabel: "Bar",
                                    amount: NSDecimalNumber(string: "0.99")))
        items.append(REApplePayItem(amountLabel: "Tax",
                                    amount: NSDecimalNumber(string: "1.53")))
         
        var applePayInfo = REApplePayInfo(purchaseItems: items)
        applePayInfo.requiredContactFields = []
        applePayInfo.merchantIdentifier = "merchant.com.recurly.recurlySDK-iOS"
        applePayInfo.countryCode = "US"
        applePayInfo.currencyCode = "USD"
        
        let tokenResponseExpectation = expectation(description: "ApplePayTokenResponse")
        paymentHandler.startApplePayment(with: applePayInfo) { (success, token) in
            
            XCTAssertTrue(success, "Apple Pay is not ready")
            tokenResponseExpectation.fulfill()
        }
        wait(for: [tokenResponseExpectation], timeout: 3.0)
    }
    
    func testCardBrandValidator() throws {
                
        //Test VISA
        var ccValidator = CreditCardValidator("4111111111111111")
        XCTAssertTrue(ccValidator.type == .visa)
        
        //Test American Express
        ccValidator = CreditCardValidator("377813011144444")
        XCTAssertTrue(ccValidator.type == .amex)
    }
    
    func testValidCreditCard() throws {
                
        //Test Valid AE
        let ccValidator = CreditCardValidator("374245455400126")
        XCTAssertTrue(ccValidator.isValid)
        
        //Test Fake Card
        XCTAssertFalse(CreditCardValidator("3778111111111").isValid)
    }
    
    func testRecurlyErrorResponse() throws {
        //Initialize the SDK
        REConfiguration.shared.initialize(publicKey: "ewr1-4TIXlPCkR68woNJp7UYMSL")
        
        RETokenizationManager.shared.cardData.number = "4111111111111111"
//        RETokenizationManager.shared.cardData.month = "12" MISSED THIS ON PURPOSE
        RETokenizationManager.shared.cardData.year = "2022"
        RETokenizationManager.shared.cardData.cvv = "123"
        
        let tokenResponseExpectation = expectation(description: "TokenErrorResponse")
        RETokenizationManager.shared.getTokenId { tokenId, error in
            if let errorResponse = error {
                XCTAssertTrue(errorResponse.error.code == "invalid-parameter")
                tokenResponseExpectation.fulfill()
            }
        }
        wait(for: [tokenResponseExpectation], timeout: 5.0)
    }
}
