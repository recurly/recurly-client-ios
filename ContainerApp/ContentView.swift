//
//  ContentView.swift
//  ContainerApp
//
//  Created by Carlos Landaverde on 14/01/22.
//

import SwiftUI
import RecurlySDK_iOS

struct ContentView: View {
    @State private var currentStatusLabel = "Logs here"
    
    // Apple Payment handler instance
    let paymentHandler = REApplePaymentHandler()

    var body: some View {
        
        ScrollView {
            
            /// Components UI
            VStack(alignment: .center, spacing: 20) {
                VStack(alignment: .leading) {
                    RECardNumberTextField(placeholder: " Card number")
                        .padding(.bottom, 30)
                    
                    HStack(spacing: 15) {
                        REExpDateTextField(placeholder: "MM/YY")
                        RECVVTextField(placeholder: "CVV")
                    }.padding(.bottom, 3)
        
                }.padding(.horizontal, 51)
                .padding(.vertical, 10)
                
                Button {
                    getToken { myToken in
                        print(myToken)
                        currentStatusLabel = myToken
                    }
                } label: {
                    Text("Subscribe")
                        .fontWeight(.bold)
                }
            }
            
            /// Inline payment UI
            VStack(alignment: .center) {
                RECreditCardInputUI(cardNumberPlaceholder: "Card number",
                                    expDatePlaceholder: "MM/YY",
                                    cvvPlaceholder: "CVV")
                    .padding(10)
                
                Button {
                    getToken { myToken in
                        print("Token: \(myToken)")
                        currentStatusLabel = myToken
                    }
                } label: {
                    Text("Subscribe")
                        .fontWeight(.bold)
                }.padding(.bottom, 50)
                       
            }.padding(.vertical, 50)
            
            /// Apple Pay
            VStack(alignment: .center) {
                Group {
                    REApplePayButton(action: {
                        getTokenApplePayment { myToken in
                            print("Apple Pay Token: \(myToken)")
                        }
                    })
                    .padding()
                    .preferredColorScheme(.light)
                }
                .previewLayout(.sizeThatFits)
            }
            
            /// Show the current status message or token
            VStack {
                Text("Current Status: \(currentStatusLabel)")
                    .lineLimit(nil)
            }
            .padding([.top, .bottom], 16)
            
        }
        
    }
    
    // Get token from UI components
    private func getToken(completion: @escaping (String) ->()) {
        
        let billingInfo = REBillingInfo(firstName: "John",
                                        lastName: "Doe",
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
        
        RETokenizationManager.shared.getTokenId { tokenId, error in
            
            if let errorResponse = error {
                print(errorResponse.error.message ?? "")
                currentStatusLabel = errorResponse.error.message ?? ""
                return
            }
            
            completion(tokenId ?? "")
        }
    }
    
    // Get token from ApplePay button
    private func getTokenApplePayment(completion: @escaping (String) -> ()) {
        
        // Test items
        var items = [REApplePayItem]()
        
        items.append(REApplePayItem(amountLabel: "Foo",
                                    amount: NSDecimalNumber(string: "3.80")))
        items.append(REApplePayItem(amountLabel: "Bar",
                                    amount: NSDecimalNumber(string: "0.99")))
        items.append(REApplePayItem(amountLabel: "Tax",
                                    amount: NSDecimalNumber(string: "1.53")))
         
        // Using 'var' instance to change some default properties values
        var applePayInfo = REApplePayInfo(purchaseItems: items)
        applePayInfo.merchantIdentifier = "merchant.com.ch2solutions.recurlySDK-iOS"
        applePayInfo.countryCode = "US"
        applePayInfo.currencyCode = "USD"
        
        /// Starting the Apple Pay flow
        self.paymentHandler.startApplePayment(with: applePayInfo) { (success, token, billingInfo) in
            
            if success {
                /// Token object 'PKPaymentToken' returned by Apple Pay
                guard let token = token else { return }
                
                /// Billing info
                guard let billingInfo = billingInfo else { return }
                
                /// Decode ApplePaymentData from Token
                let decoder = JSONDecoder()
                var applePaymentData = REApplePaymentData()
                
                do {
                    // This only works with a Sandbox Apple Pay enviroment in real device
                    let applePaymentDataBody = try decoder.decode(REApplePaymentDataBody.self, from: token.paymentData)
                    applePaymentData = REApplePaymentData(paymentData: applePaymentDataBody)
                } catch {
                    print("Apple Payment Data Error")
                    
                    // Creating a Simulated Data for Apple Pay
                    let paymentDataBody = REApplePaymentDataBody(version: "EC_v1", data: "test", signature: "test", header: REApplePaymentDataHeader(ephemeralPublicKey: "test_public_key", publicKeyHash: "test_public_hash", transactionId: "abc123"))
                    applePaymentData = REApplePaymentData(paymentData: paymentDataBody)
                }
                
                let displayName = token.paymentMethod.displayName ?? "unknown"
                let network = token.paymentMethod.network?.rawValue ?? "unknown"
                let type = token.paymentMethod.type.rawValue
                
                // Creating Apple Payment Method
                let applePaymentMethod = REApplePaymentMethod(paymentMethod: REApplePaymentMethodBody(displayName: displayName, network: network, type: "\(type)"))
                
                // Creating Billing Info
                let billingData = REBillingInfo(firstName: billingInfo.name?.givenName ?? String(),
                                                lastName: billingInfo.name?.familyName ?? String(),
                                                address1: billingInfo.postalAddress?.street ?? String(),
                                                address2: "",
                                                country: billingInfo.postalAddress?.country ?? String(),
                                                city: billingInfo.postalAddress?.city ?? String(),
                                                state: billingInfo.postalAddress?.state ?? String(),
                                                postalCode: billingInfo.postalAddress?.postalCode ?? String(),
                                                taxIdentifier: "",
                                                taxIdentifierType: "")
                
                RETokenizationManager.shared.setBillingInfo(billingInfo: billingData)
                RETokenizationManager.shared.setApplePaymentData(applePaymentData: applePaymentData)
                RETokenizationManager.shared.setApplePaymentMethod(applePaymentMethod: applePaymentMethod)
                
                // This method is used to send ApplePay data for Tokenization
                RETokenizationManager.shared.getApplePayTokenId { tokenId, error in
                    
                    if let errorResponse = error {
                        print(errorResponse.error.message ?? "")
                        currentStatusLabel = errorResponse.error.message ?? ""
                        return
                    }
                    
                    self.currentStatusLabel = tokenId ?? ""
                    completion(tokenId ?? "")
                }
                
            } else {
                print("Apple Payment Failed")
                completion("")
            }
        }
    }
    
}

// MARK: - UI Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
