# Recurly iOS SDK
![Recurly Client iOS](https://github.com/recurly/recurly-client-ios/actions/workflows/ci-test.yaml/badge.svg?branch=master)

The Recurly SDK allows you to integrate recurrent payments in your existing iOS app in a matter of minutes.

We encourage our partners to review Apple's guidelines on mobile application development. In particular, please review Payments section to familiarize yourself with the purchases and currencies guidelines: <https://developer.apple.com/app-store/review/guidelines/#payments>

When a customer submits your payment form, the Recurly iOS SDK sends customer payment information to be encrypted and stored at Recurly and gives you an billing token to complete the subscription process using our powerful API.

With this billing token, you can do anything with our API that requires payment information. Because you never handle any sensitive payment information, your PCI scope is drastically reduced.

## 1. Download

Access our SDK via GitHub: [iOS Client Repository](https://github.com/recurly/recurly-client-ios)

After reviewing our SDK via GitHub, use one of these two options to begin using the Recurly iOS SDK.

### 1.1 Using CocoaPods
If you already have and use Cocoapods, skip to step 3.

1. [Install CocoaPods](https://guides.cocoapods.org/using/getting-started.html) if you don't already have it.
2. [Set up](https://guides.cocoapods.org/using/using-cocoapods.html) CocoaPods in your project.
3. Add this line your `Podfile`.

	```ruby
	pod 'RecurlySDK'
	```
4. Download `RecurlySDK` and any other specified pods by running:

	```bash
	$ pod install
	```

For more information on CocoaPods and the `Podfile`, visit: <https://guides.cocoapods.org/using/the-podfile.html>


### 1.2 Using the RecurlySDK.framework
1. Download the framework from the releases page (or build it yourself using the `build.sh` script provided).
2. [Drop it in](https://developer.apple.com/library/ios/recipes/xcode_help-structure_navigator/articles/Adding_a_Framework.html) your existing Xcode project.
3. RecurlySDK needs the following frameworks:
  - Foundation
  - UIKit
  - AddressBook
  - Security
  - CoreTelephony
  - PassKit

4. Add the flag `-ObjC` to `Other Linker Flags` (located in Build Settings > Linking).


## 2. Import
Once the framework is added to your project (via either of the methods above) you only need to import the SDK.

```SwiftUI
import RecurlySDK_iOS
```

## 3. Configure
In order to connect to the Recurly API, you must initialize the SDK with the API public key. This is found on the API credentials page of your Recurly site: <https://app.recurly.com/go/developer/api_access>

```Swift
REConfiguration.shared.initialize(publicKey: "Your Public Key")
// after configuring, you can perform any operation with the SDK!
```

We strongly recommend that you configure the SDK when your application is launched (in your `AppDelegate` or creating a custom init for your @main App (SwiftUI), for example).

```Swift
@main
struct ContainerApp: App {
    init() {
        REConfiguration.shared.initialize(publicKey: "Your Public Key")
    }
    var body: some Scene {

        WindowGroup {
            ContentView()
        }
    }
}
```

### Unit Tests
`RecurlySDK-iOSTests/RecurlySDK-iOSTests.swift` expects to receive environment variables (such as PUBLIC\_KEY) from the command line.

If you'd like to run the tests in Xcode, be sure to set the `publicKey` variable directly in the test file with your own file. Tests won't pass without a valid public key that you provide.

## 4. Examples
Once the SDK is imported and configured, we can start building stuff with it!

### Display our RECreditCardInputUI TextField

```Swift
       VStack(alignment: .center) {
            RECreditCardInputUI(cardNumberPlaceholder: "Card number",
                                expDatePlaceholder: "MM/YY",
                                cvvPlaceholder: "CVV")
                .padding(10)

            Button {
                getToken { myToken in
                    print(myToken)
                }
            } label: {
                Text("Subscribe")
                    .fontWeight(.bold)
            }
        }.padding(.vertical, 100)
```
### Display Individual Components

```Swift
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
                }
            } label: {
                Text("Subscribe")
                    .fontWeight(.bold)
            }
        }
```

### Apply Custom Fonts and Sizes

```Swift

    RECreditCardInputUI(cardNumberPlaceholder: "Card number",
                                expDatePlaceholder: "MM/YY",
                                cvvPlaceholder: "CVV",
                                textFieldFont: Font.system(size: 15, weight: .bold, design: .default),
                                titleLabelFont: Font.system(size: 13, weight: .bold, design: .default))
```

### Get a payment token

```Swift
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
//Inject the BillingInfo
RETokenizationManager.shared.billingInfo = billingInfo

//Get the TokenId for your Billing Info
RETokenizationManager.shared.getTokenId { tokenId, error in
        if let errorResponse = error {
            print(errorResponse.error.message ?? "")
            return
        }    
            print(tokenId ?? "")
        }
```

or (exactly the same for requesting a tokenId just with your CardData):

**The Card Data its passed to our Framework as the user types it so you don't need it nor have access to sensitive user info**
```Swift
// Display The RECreditCardInputUI or The Individual Components and as the User types in, the info will be ready to submitt inside our Framework

//Get the TokenId for your Card Data
RETokenizationManager.shared.getTokenId { tokenId, error in
        if let errorResponse = error {
            print(errorResponse.error.message ?? "")
            return
        }    
            print(tokenId ?? "")
        }
```

## 5. Apple Pay support

The following assumes your company is setup as an Apple Pay merchant. For more info on configuration and setup, look at the `README-APPLE-PAY-CONFIG.md` documentation in the repo.

To include the Apple Pay support using our SDK you need to following the next steps:

### Instantiate REApplePaymentHandler class
```Swift
// Apple Payment handler instance
    let paymentHandler = REApplePaymentHandler()
```

### Use our REApplePayButton
```Swift
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

```

### Apple Pay Token Callback
```Swift
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
        // This MerchantID is required by Apple, you can learn more about:
        // https://developer.apple.com/apple-pay/sandbox-testing/
        applePayInfo.merchantIdentifier = "merchant.com.YOURDOMAIN.YOURAPPNAME"
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

                print("Success Apple Payment with token: \(applePayTokenString)")

            } else {
                print("Apple Payment Failed")
            }

            completion(success)
        }
    }
```