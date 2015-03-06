#Recurly iOS SDK
![Ship io](https://ship.io/jobs/dzuagaYFjBg8c5xF/build_status.png)  

The Recurly SDK allows you to integrate recurrent payments in your exisiting iOS app in a matter of minutes.

By using the Recurly SDK, you can tokenize your users payment information and safely use it to do transactions. Because you never handle any sensitive payment information, your PCI scope is drastically reduced.

##1. Download
There are two ways to begin using the Recurly iOS SDK.
  
1. Download the framework and drop it in your existing Xcode project.
2. Use cocoapods. If you are currently using cocoapods in your Xcode, add this line your `PodFile`.

```
	pod 'RecurlySDK'
```
For more information on cocoapods, visit: [http://guides.cocoapods.org/syntax/podfile.html]()

##2. Import
Once the framework is added to your project (via either of the methods above) you only need to import the SDK headers.

```obj-c
#import <RecurlySDK/RecurlySDK.h>
```

##3. Configure
In order to connect to the Recurly API, you must initialize the SDK with the public key provided in your Recurly's dashboard which is availble here: [https://app.recurly.com/go/developer/api_access]()

```obj-c
[Recurly configure:@"sc-zBh5Z3Jcto0c3Z6YLGPMFb"];
// here, after configuring, you can perform any operation with recurly!
```

We strongly recomend that you configure the RecurlySDK when your application is launched.

```obj-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Recurly configure:@"sc-zBh5Z3Jcto0c3Z6YLGPMFb"];
    // continue initializing your app
}    
```

##4. Examples
Once the SDK is imported and configured, we can start builing stuff with it!
###Get a payment token
```obj-c
RECardRequest *card = [RECardRequest new];
card.number = @"4111111111111111";
card.cvv = @"123";
card.expirationMonth = 12;
card.expirationYear = 2015;
card.billingAddress.firstName = @"Manu";
card.billingAddress.lastName = @"Almeida";
card.billingAddress.country = @"ES";

[Recurly tokenWithRequest:card completion:^(NSString *token, NSError *error) {
    if(!error) {
        // DO STUFF WITH THE TOKEN
    }
}];
```

or (exactly the same):
```obj-c
RECardRequest *card = [REPayment paymentWithCardNumber:@"4111111111111111"
                                                   CVV:@"123"
                                                 month:12
                                                  year:2015
                                             firstName:@"Manu"
                                              lastName:@"Almeida"
                                           countryCode:@"ES"];

[Recurly tokenWithRequest:card completion:^(NSString *token, NSError *error) {
    if(!error) {
        // DO STUFF WITH THE TOKEN
    }
}];
```


###Get a tax for a country/postal code

```obj-c
[Recurly taxForPostalCode:@"94566"
              countryCode:@"US"
               completion:^(double tax, NSError *error)
{
    if(!error) {
        NSLog(@"The VAT imposed in that location is: %.3f%%", tax);
    }
}];
```
