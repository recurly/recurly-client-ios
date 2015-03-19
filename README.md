#Recurly iOS SDK

The Recurly SDK allows you to integrate recurrent payments in your exisiting iOS app in a matter of minutes.

The Recurly SDK will provide to you an authorization key (or token), you can do anything with our API that requires payment information. Because you never handle any sensitive payment information, your PCI scope is drastically reduced.

##1. Get the SDK
We have to options here.
  
1. Download framework and drop it in your existing Xcode project.
2. Use cocoapods. If you are currently using cocoapods in your Xcode, add this line your `PodFile`.

```
	pod 'RecurlySDK'
```
For more information, visit: [http://guides.cocoapods.org/syntax/podfile.html]()

DONE!


##2. Import it
Once the framework added to your project or linked with cocoapods, you only have to add the following line to all the files that will use the SDK.

```obj-c
#import <RecurlySDK/RecurlySDK.h>
```

##3. Configure it
In order to connect successfully to the Recurly's servers, you have initialize the SDK with the public key provided in your Recurly's dashboard. See manual.

```obj-c
[Recurly configure:@"sc-zBh5Z3Jcto0c3Z6YLGPMFb"];
```

We strongly recomend to configure Recurly just when your application is launched.

```obj-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Recurly configure:@"sc-zBh5Z3Jcto0c3Z6YLGPMFb"];
    // continue initializing your app
    // use Recurly API
}    
```

##4. Let's try some APIs
Once the SDK is imported and configured, we can start builing stuff with it!
###Get a payment token
```obj-c
RECardRequest *card = [RECardRequest new];
card.number = @"4111111111111111";
card.cvv = @"123";
card.expirationMonth = 12;
card.expirationYear = 2015;
card.billingAddress.firstName = @"Jonh";
card.billingAddress.lastName = @"Smith";
card.billingAddress.country = @"US";

[Recurly tokenWithRequest:card completion:^(NSString *token, NSError *error) {
    if(!error) {
        // DO STUFF WITH THE TOKEN
    }
}];
```

or (exactly the same):

```obj-c
RECardRequest *card = [RECardRequest paymentWithCardNumber:@"4111111111111111"
                                                   CVV:@"123"
                                                 month:12
                                                  year:2015
                                             firstName:@"John"
                                              lastName:@"Smith"
                                           countryCode:@"US"];

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

###Get Plan's information

```obj-c
[Recurly planForCode:@"premium"
          completion:^(REPlan *plan, NSError *error) {
    if(!error) {
        NSLog(@"Plan info: %@", plan);
    }
}];
```

###Get Plan's information

```obj-c
[Recurly planForCode:@"premium"
          completion:^(REPlan *plan, NSError *error) {
    if(!error) {
        NSLog(@"Plan info: %@", plan);
    }
}];
```

###Get Coupon's information

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

##Validating input data manually