/*
 * The MIT License
 * Copyright (c) 2014-2015 Recurly, Inc.

 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

// FRAMEWORKS
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <PassKit/PassKit.h>
#import <AddressBook/AddressBook.h>

// BASIC
#import "REProtocols.h"
#import "REError.h"
#import "REConfiguration.h"
#import "REValidation.h"


// NETWORKING PRIMITIVES
#import "REAPIRequest.h"

// MODELS
#import "REAddress.h"
#import "REPlan.h"
#import "RETaxes.h"
#import "RECoupon.h"
#import "REPricing.h"
#import "RECartSummary.h"
#import "REPriceSummary.h"


// REQUESTS
#import "RECardRequest.h"
#import "RECouponRequest.h"
#import "REPlanRequest.h"
#import "RETaxRequest.h"


//! Project version number for RecurlySDK.
FOUNDATION_EXPORT const double RecurlySDKVersionNumber;

//! Project version string for RecurlySDK.
FOUNDATION_EXPORT const char RecurlySDKVersionString[];


@interface Recurly : NSObject

#pragma mark - Configuration

/** This must be the first method to be called. It configures the framework using the public key provided
 in your Recurly's dashboard.
 
 @see setConfiguration:
 */
+ (void)configure:(NSString *)publicKey;

/** Allows a higher level of customization, instance a object of REConfiguration with your
 default settings and make it default by using this method.

 @see configure:
 @see REConfiguration
 */
+ (void)setConfiguration:(REConfiguration *)config;


/** Returns the current settings of the framework.
 */
+ (REConfiguration *)configuration;


#pragma mark - API methods

/** Tokenizers a payment in order to use it safely in your backend and manage the transaction.
 A payment is an instance of RECardPayment. This method performs an async operation, it connects with the 
 recurly servers.
 
 @see RECardPayment
 */
+ (void)tokenWithRequest:(REPayment *)payment
              completion:(void(^)(NSString *token, NSError *error))handler;


/** Returns an instance of RETaxes given a postal code and a country code. RETaxes will encapsulate
 the tax rates of the specified area.
 @discussion The country code is ISO 3166-1 alpha-2
 @see RETaxes
 */
+ (void)taxForPostalCode:(NSString *)postalCode
             countryCode:(NSString *)countryCode
              completion:(void(^)(RETaxes *taxes, NSError *error))handler;

/** Returns an instance of REPlan given the specified plan code. The plans can be created and managed
 in your Recurly's dashboard.
 */
+ (void)planForCode:(NSString *)planCode
         completion:(void(^)(REPlan *plan, NSError *error))handler;


/** Returns the coupon details given a plan code and a discount code. */
+ (void)couponForPlan:(NSString *)plan
                 code:(NSString *)coupon
           completion:(void(^)(RECoupon *coupon, NSError *error))handler;

/** Returns a pricing object used for advanced pricing calculations. 
 @see REPricing
 */
+ (REPricing *)pricing;


#pragma mark - Utilities

/** Helper method to create UIAlerViews based in any error provided by this SDK.
 */
+ (UIAlertView *)alertViewWithError:(NSError *)error;

@end
