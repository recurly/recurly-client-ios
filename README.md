# Recurly iOS SDK

The Recurly SDK allows you to integrate recurrent payments in your existing iOS app in a matter of minutes.

We encourage our partners to review Apple's guidelines on mobile application development. In particular, please review Section 11 to familiarize yourself with the purchases and currencies guidelines: <https://developer.apple.com/app-store/review/guidelines/#purchasing-currencies>

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

4. Add the flag `-ObjC` to `Other Linker Flags` (located in Build Settings > Linking).


## 2. Import
Once the framework is added to your project (via either of the methods above) you only need to import the SDK headers.

```obj-c
#import <RecurlySDK/RecurlySDK.h>
```

## 3. Configure
In order to connect to the Recurly API, you must initialize the SDK with the API public key. This is found on the API credentials page of your Recurly site: <https://app.recurly.com/go/developer/api_access>

```obj-c
[Recurly configure:@"YOUR_PUBLIC_KEY"];
// after configuring, you can perform any operation with the SDK!
```

We strongly recommend that you configure the SDK when your application is launched (in your `AppDelegate.m`, for example).

```obj-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Recurly configure:@"YOUR_PUBLIC_KEY"];
    // continue initializing your app
}
```

## 4. Examples
Once the SDK is imported and configured, we can start building stuff with it!
### Get a payment token

```obj-c
RECardRequest *card = [RECardRequest new];
card.number = @"4111111111111111";
card.cvv = @"123";
card.expirationMonth = 12;
card.expirationYear = 2025;
card.billingAddress.firstName = @"John";
card.billingAddress.lastName = @"Smith";
card.billingAddress.countryCode = @"US";

[Recurly tokenWithRequest:card completion:^(NSString *token, NSError *error) {
    if(!error) {
        // DO STUFF WITH THE TOKEN
    }
}];
```

or (exactly the same):

```obj-c
RECardRequest *card = [RECardRequest requestWithCardNumber:@"4111111111111111"
                                                       CVV:@"123"
                                                     month:12
                                                      year:2025
                                                 firstName:@"John"
                                                  lastName:@"Smith"
                                               countryCode:@"US"];

[Recurly tokenWithRequest:card completion:^(NSString *token, NSError *error) {
    if(!error) {
        // DO STUFF WITH THE TOKEN
    }
}];
```


### Get tax details for a specific locale

```obj-c
[Recurly taxForPostalCode:@"WA16 8GS"
              countryCode:@"GB"
               completion:^(RETaxes *tax, NSError *error)
{
    if(!error) {
        NSLog(@"The VAT imposed in that location is: %@%%", [[tax totalTax] decimalNumberByMultiplyingByPowerOf10:2]);
    }
}];
```

### Get the details of a plan

```obj-c
[Recurly planForCode:@"premium"
          completion:^(REPlan *plan, NSError *error) {
    if(!error) {
        NSLog(@"Plan info: %@", plan);
    }
}];
```

### Get the details of a coupon

```obj-c
[Recurly couponForPlan:@"premium"
                  code:@"123Win"
            completion:^(RECoupon *coupon, NSError *error)
{
    if(!error) {
        NSLog(@"Coupon info: %@", coupon);
    }
}];
```

## 5. Validate input data manually

### Card number

```obj-c
if([REValidation validateCardNumber:@"4111 1111 1111 1111"]) {
    NSLog(@"Card number is valid");
}else{
    NSLog(@"Card number is invalid");
}
```

### CVV

```obj-c
if([REValidation validateCVV:@"123"]) {
    NSLog(@"CVV is valid");
}else{
    NSLog(@"CVV is invalid");
}
```


### Country code

```obj-c
if([REValidation validateCountryCode:@"US"]) {
    NSLog(@"Country code is valid");
}else{
    NSLog(@"Country code is invalid");
}
```


### Expiration date

```obj-c
if([REValidation validateExpirationMonth:11 year:30]) {
    NSLog(@"Expiration date is valid");
}else{
    NSLog(@"Expiration date is invalid");
}
```

## 6. Using a Token

Once the SDK has stored your customer’s sensitive data and given you a token reference, you will have 20 minutes to use it in our [API](https://dev.recurly.com/). Expired tokens are permanently removed from the Recurly servers.

Tokens can be used to populate any account Billing Info data through our API. Simply assign it to the Billing Info’s `token_id` property and we’ll do the rest.

**These endpoints accept tokens within billing info.**

* Purchase [`create`](https://developers.recurly.com/api/latest/index.html#operation/create_purchase)
* Subscription [`create`](https://developers.recurly.com/api/latest/index.html#operation/create_subscription)
* Account [`create`](https://developers.recurly.com/api/latest/index.html#operation/create_account), [`update`](https://developers.recurly.com/api/latest/index.html#operation/update_account)
* Billing Info [`update`](https://developers.recurly.com/api/latest/index.html#operation/update_billing_info)

> If you use a token, no other attributes will be allowed on that Billing Info for that request.
