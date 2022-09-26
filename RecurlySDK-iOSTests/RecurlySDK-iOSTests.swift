//
//  RecurlySDK-iOSTests.swift
//  RecurlySDK-iOSTests
//
//  Created by George Andrew Shoemaker on 8/20/22.
//

import XCTest
@testable import RecurlySDK_iOS

class RecurlySDK_iOSTests: XCTestCase {
    
    // If you are running these tests in Xcode
    // you should set your public key here.
    // Otherwise PUBLIC_KEY should be set from the command line
    let publicKey = getEnviornmentVar("PUBLIC_KEY") ?? ""
    
    let paymentHandler = REApplePaymentHandler()
    
    // This utility function will setup the TokenizationManager
    // with valid billingInfo and cardData
    private func setupTokenizationManager() {
        RETokenizationManager.shared.setBillingInfo(
            billingInfo: REBillingInfo(
                firstName: "David",
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
                taxIdentifierType: ""
            )
        )
        RETokenizationManager.shared.cardData.number = "4111111111111111"
        RETokenizationManager.shared.cardData.month = "12"
        RETokenizationManager.shared.cardData.year = "2022"
        RETokenizationManager.shared.cardData.cvv = "123"
    }
    
    func testPublicKeyIsValid() throws {
        
        guard !publicKey.isEmpty else {
            XCTFail("PUBLIC_KEY was not set")
            return
        }
        
        REConfiguration.shared.initialize(publicKey: publicKey)
        setupTokenizationManager()

        let tokenResponseExpectation = expectation(description: "TokenResponse")
        RETokenizationManager.shared.getTokenId { tokenId, errorResponse in
            if
                let errorMessage = errorResponse?.error.message,
                errorMessage == "Public key not found"
            {
                XCTFail(errorMessage + " : Is your public key valid?")
                return
            }

            if let errorResponse = errorResponse {
                XCTFail(errorResponse.error.message ?? "Something went wrong. No error message arrived with error.")
                return
            }

            XCTAssertFalse(tokenId?.isEmpty ?? true, "tokenID was unexpectedly empty.")
            tokenResponseExpectation.fulfill()
        }
        wait(for: [tokenResponseExpectation], timeout: 5.0)
    }

    func testTokenization() throws {
        //Initialize the SDK
        REConfiguration.shared.initialize(publicKey: publicKey)
        setupTokenizationManager()

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

        let items = [
            REApplePayItem(amountLabel: "Foo", amount: 3.80),
            REApplePayItem(amountLabel: "Bar", amount: 0.99),
            REApplePayItem(amountLabel: "Tax", amount: 1.53)
        ]
        var applePayInfo = REApplePayInfo(purchaseItems: items)
        applePayInfo.requiredContactFields = []
        applePayInfo.merchantIdentifier = "merchant.com.recurly.recurlySDK-iOS"
        applePayInfo.countryCode = "US"
        applePayInfo.currencyCode = "USD"

        let tokenResponseExpectation = expectation(description: "ApplePayTokenResponse")
        paymentHandler.startApplePayment(with: applePayInfo) { (success, token, nil) in
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
        REConfiguration.shared.initialize(publicKey: publicKey)
        setupTokenizationManager()

        // Purposefully set this to empty as if it were missing
        RETokenizationManager.shared.cardData.month = ""

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
