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
                        print(myToken)
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
                        getTokenApplePayment { completed in
                            // Do something
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
    private func getTokenApplePayment(completion: @escaping (Bool) -> ()) {
        
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
        // By default only require .phoneNumber and emailAddress
        applePayInfo.requiredContactFields = [.name, .phoneNumber, .emailAddress]
        applePayInfo.merchantIdentifier = "merchant.com.ch2solutions.recurlySDK-iOS"
        applePayInfo.countryCode = "US"
        applePayInfo.currencyCode = "USD"
        
        /// Starting the Apple Pay flow
        self.paymentHandler.startApplePayment(with: applePayInfo) { (success, token) in
            
            if success {
                /// Token object 'PKPaymentToken' returned by Apple Pay
                guard let token = token else { return }
                
                /// Decode Token
                let paymentData = String(data: token.paymentData, encoding: .utf8)
                guard let paymentJson = paymentData else { return }
                
                let displayName = token.paymentMethod.displayName ?? "unknown"
                let network = token.paymentMethod.network?.rawValue ?? "unknown"
                let type = token.paymentMethod.type
                let txId = token.transactionIdentifier
                
                // Creating a test object to send Recurly
                let applePayTokenString = """
                {\"merchantIdentifier\":\"\(applePayInfo.merchantIdentifier)\",\
                \"payment\":{\"token\":{
                \"paymentData\":\(paymentJson),\
                \"paymentMethod\":{\"displayName\":\"\(displayName)\",\"network\":\"\(network)\",\"type\":\"\(type)\"},\
                \"transactionIdentifier\":\"\(txId)\"}}}
                """
                
                self.currentStatusLabel = applePayTokenString
                print("Success Apple Payment with token: \(applePayTokenString)")
                
            } else {
                print("Apple Payment Failed")
            }
            
            completion(success)
        }
    }
    
}

// MARK: - UI Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
