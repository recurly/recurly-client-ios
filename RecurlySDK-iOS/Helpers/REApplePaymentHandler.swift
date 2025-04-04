//
//  PaymentHandler.swift
//  RecurlySDK-iOS
//
//  Created by David Figueroa on 21/12/21.
//

import PassKit

public enum REApplePaymentError: Error {
    case failedToPresentController
    case paymentAuthorization
    case cancelled
}

// Callback for payment status
public typealias PaymentCompletionHandler = (Result<(PKPaymentToken, PKContact?), REApplePaymentError>) -> Void

// Primary Apple Payment class to handle all logic about ApplePay Button
public class REApplePaymentHandler: NSObject {
    
    // Available Networks
    static let supportedNetworks: [PKPaymentNetwork] = [
        .amex,
        .masterCard,
        .visa,
        .discover
    ]
    
    var paymentController: PKPaymentAuthorizationController?
    var requiredContactFields = Set<PKContactField>()
    // Reference to REApplePayItem
    var paymentSummaryItems = [PKPaymentSummaryItem]()
    // Current status of the transaction
    var paymentStatus: PKPaymentAuthorizationStatus?
    // ApplePay token
    var currentToken: PKPaymentToken?
    // Billing info
    var currentBillingInfo: PKContact?
    var completionHandler: PaymentCompletionHandler!
    
    // TDD
    var isPaymentControllerPresented = false
    var isTesting = false
    
    /**
     Main function to start the Apple Payment flow
     applePayInfo: Required model with all information to create the PKPaymentRequest
     completion: Callback to show failure or success of the payment transaction
     */
    public func startApplePayment(with applePayInfo: REApplePayInfo, completion: @escaping PaymentCompletionHandler) {
        
        requiredContactFields = applePayInfo.requiredContactFields
        paymentSummaryItems = applePayInfo.paymentSummaryItems()
        completionHandler = completion
        
        // Creating the request
        let paymentRequest = createPaymentRequest(with: applePayInfo)
        
        // Presenting the Apple Pay UI
        presentPaymentRequest(with: paymentRequest)
    }
    
    // Presenting the payment request
    private func presentPaymentRequest(with paymentRequest: PKPaymentRequest) {
        paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController?.delegate = self
        paymentController?.present { [weak self] presented in
            guard let self = self else { return }
            if presented {
                NSLog("Presented payment controller")
                self.isPaymentControllerPresented = true
                
                if self.isTesting {
                    self.completionHandler(.success((PKPaymentToken(), nil)))
                }
            } else {
                NSLog("Failed to present payment controller")
                self.completionHandler(.failure(.failedToPresentController))
            }
        }
    }
    
    // Create the payment request
    // All information required to create an order is here 'REApplePayInfo'
    private func createPaymentRequest(with applePayInfo: REApplePayInfo) -> PKPaymentRequest {
        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = paymentSummaryItems
        paymentRequest.merchantIdentifier = applePayInfo.merchantIdentifier
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.countryCode = applePayInfo.countryCode
        paymentRequest.currencyCode = applePayInfo.currencyCode
        paymentRequest.requiredShippingContactFields = applePayInfo.requiredContactFields
        paymentRequest.supportedNetworks = REApplePaymentHandler.supportedNetworks
        
        return paymentRequest
    }
    
    // Validate if the ApplePay is configured in the current device
    // if not configured the process show the UI to add new cards
    public func applePaySupported() -> Bool {
        return PKPaymentAuthorizationViewController.canMakePayments() && PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: REApplePaymentHandler.supportedNetworks)
    }
    
    // MARK: - TDD
    
    // This method is intented to use from XCTest
    public func paymentControllerIsPresented() -> Bool {
        isPaymentControllerPresented
    }
    
}

// MARK: - PKPaymentAuthorizationControllerDelegate

// PKPaymentAuthorizationControllerDelegate conformance.
extension REApplePaymentHandler: PKPaymentAuthorizationControllerDelegate {
    
    public func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        paymentStatus = .failure
        
        if requiredContactFields.contains(.name), payment.shippingContact?.name == nil {
            let error = PKPaymentRequest.paymentContactInvalidError(withContactField: .name, localizedDescription: "An error with Name occurred")
            completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
            return
        }
        
        if requiredContactFields.contains(.phoneNumber), payment.shippingContact?.phoneNumber == nil {
            let error = PKPaymentRequest.paymentContactInvalidError(withContactField: .phoneNumber, localizedDescription: "An error with phone number occurred")
            completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
            return
        }
        
        if requiredContactFields.contains(.postalAddress), payment.shippingContact?.postalAddress == nil {
            let error = PKPaymentRequest.paymentContactInvalidError(withContactField: .postalAddress, localizedDescription: "An error with postal address occurred")
            completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
            return
        }
        
        // Here you would send the payment token to your server or payment provider to process
        currentToken = payment.token
        // Set current billing info
        currentBillingInfo = payment.shippingContact
        // Once processed, return an appropriate status in the completion handler (success, failure, etc)
        paymentStatus = .success
        
        completion(PKPaymentAuthorizationResult(status: paymentStatus!, errors: nil))
    }
    
    // Responsible for dismissing and releasing the controller
    public func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let paymentStatus = self.paymentStatus {
                    if paymentStatus == .success {
                        self.completionHandler(.success((self.currentToken!, self.currentBillingInfo)))
                    } else {
                        self.completionHandler(.failure(.paymentAuthorization))
                    }
                } else {
                    self.completionHandler(.failure(.cancelled))
                }
            }
        }
    }
    
}
