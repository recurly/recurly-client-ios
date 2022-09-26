# Recurly iOS SDK + Apple Pay Conﬁguration

## Introduction

The [Recurly iOS SDK repository](https://github.com/recurly/recurly-client-ios) contains the [ContainerApp](https://github.com/recurly/recurly-client-ios/tree/master/ContainerApp) which includes a minimal example of tokenizing an Apple Pay transaction via Recurly. However it doesn't work out of the box...

There's considerable conﬁguration that needs to happen with both
Apple and Recurly in order for Apple Pay tokenization to work. This isn't a feautre of the SDK that be easily "tried out" if your company is not already set up with an Apple as a merchant.

Additionally, [sandbox testin](https://developer.apple.com/apple-pay/sandbox-testing/) for Apple Pay only works on a real device, so your
development devices must be [registered](https://help.apple.com/developer-account/#/dev40df0d9fa) with your Apple development team.

## Tokenization Overview


These are the basic steps your iOS code should accomplish:

1. Submit a payment request via the in your app.
2. Receive a object that represents the Apple Pay transaction.
3. Decode the to create an REApplePayment object.
4. Conﬁgure the `RETokenizationManager` singleton and submit the Apple Pay transaction to Recurly with
`RETokenizationManager.shared.getApplePayTokenId()`.
5. If all goes well, you'll receive a token from Recurly as a string. ✅

Steps 1 & 2 are purey Apple Pay behavior. The remaining steps can be accomplished with help from and classes in the SDK.

## Apple Pay

This information is independent of the Recurly iOS SDK.

### Conﬁguration

Familiarize yourself with this documentation:

- [Setting Up Apple Pay](https://developer.apple.com/documentation/passkit/apple_pay/setting_up_apple_pay)
- [Configure Apple Pay](https://help.apple.com/developer-account/#/devb2e62b839?sub=dev103e030bb)
- [Offering Apple Pay in Your App](https://developer.apple.com/documentation/passkit/apple_pay/offering_apple_pay_in_your_app)


Be warned, if your company is not veriﬁed as a merchant, you can't try out Apple Pay.

Additionally, you must run your code on a real device to succsefully decode a `PKPaymentToken` (step 3).

It's also a good idea to use a [Sandbox Tester Account](https://developer.apple.com/apple-pay/sandbox-testing/) to allow you to submit transactions without a real credit card.


## Code

Use a `PKPaymentAuthorizationController` to present the Apple Pay sheet. This class has a delegate, `PKPaymentAuthorizationControllerDelegate`, with the function `paymentAuthorizationController(\_:didAuthorizePayment:handler:)`. Use this func to validate payment data and receive the `PKPayment` object from Apple (step 2).

The `ContainerApp` in the repositry has an example of this in [ContentView.swift](https://github.com/recurly/recurly-client-ios/blob/master/ContainerApp/ContentView.swift)

## Recurly tokenization**

### Conﬁguration

You will need to request Merchant Identity and Apple Pay CSRs from
Recurly as described here: [Apple Pay on the Web > Getting Started](https://docs.recurly.com/docs/apple-pay-on-the-web#getting-started)

You will then use Recurly's CSRs to create & upload a respective Merchant Identy and Apple Pay certiﬁcate. Described here: [Configuration in Apple and Recurly](https://docs.recurly.com/docs/apple-pay-on-the-web#configuration-in-apple-and-recurly)

(If Recurly sends you private keys, upload those too.)

### Code

[ContentView.swift](https://github.com/recurly/recurly-client-ios/blob/master/ContainerApp/ContentView.swift) has an example of

- Decoding PKPayment.token
- Initializing a `REApplePaymentMethod`
- Conﬁguring the `RETokenizationManager` singleton
- And ﬁnally submitting the transaction data to recurly with `RETokenizationManager.getApplePayTokenId()`

⚠️ If you are using the `ContainerApp` in the repo, make sure you set your merchant ID in the `applePayInfo` instance of [ContentView.swift](https://github.com/recurly/recurly-client-ios/blob/master/ContainerApp/ContentView.swift).

Through a completion handler you will receive either Recurly\'s token or
an error.

In the SDK, the transactiond data is being sent to recurly as a POST
request to the endpoint /apple_pay/token

## ⚠️ Troubleshooting

- Make sure you are using a real device and a Sandbox Tester Account if you are trying to decode `PKPayment` in your app
- If you are using the `ContainerApp`, make sure you set your Recurly public key in [ContainerApp.swift](https://github.com/recurly/recurly-client-ios/blob/master/ContainerApp/ContainerApp.swift)
- If you are struggling with with provisioning profile / merchant ID, consider selecting "Automatically manage siging" in the Project navigator > ContainerApp Target > Signing & Capabilities.
	- This assumes your test device is registered, you are using a valid merchant ID, etc