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


/** Configures the SDK and provides the main APIs for interacting with the Recurly backend.
 The SDK should be initialized calling `[Recurly configure:]` or `[Recurly setConfiguration:]` before any other
 
 */
@interface Recurly : NSObject

#pragma mark - Configuration

/** This must be the first method to be called. It configures the framework using the public key provided
 in your Recurly's dashboard.
 @param publicKey The public key used to configure Recurly.
 @see setConfiguration:
 */
+ (void)configure:(NSString *)publicKey;

/** Allows a higher level of customization, instance a object of REConfiguration with your
 default settings and make it default by using this method.

 @param config The configuration object containing all the settings and the public key.
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
 
 @param payment Payment to tokenize
 @param handler Completion handler
 @see RECardRequest
 */
+ (void)tokenWithRequest:(REPayment *)payment
              completion:(void(^)(NSString *token, NSError *error))handler;


/** Returns an instance of RETaxes given a postal code and a country code. RETaxes will encapsulate
 the tax rates of the specified area.

 @param postalCode Postal code
 @param countryCode Country Code. ISO 3166-1 alpha-2
 @param handler Completion handler

 @see RETaxes
 */
+ (void)taxForPostalCode:(NSString *)postalCode
             countryCode:(NSString *)countryCode
              completion:(void(^)(RETaxes *taxes, NSError *error))handler;

/** Returns an instance of REPlan given the specified plan code. The plans can be created and managed
 in your Recurly's dashboard.

 @param planCode Plan's id
 @param handler Completion handler
 */
+ (void)planForCode:(NSString *)planCode
         completion:(void(^)(REPlan *plan, NSError *error))handler;


/** Returns the coupon details given a plan code and a discount code.
 @param plan Plan's id
 @param couponCode Coupon code
 @param handler Completion handler
 */
+ (void)couponForPlan:(NSString *)plan
                 code:(NSString *)couponCode
           completion:(void(^)(RECoupon *coupon, NSError *error))handler;

/** Returns a pricing object used for advanced pricing calculations. 
 @see REPricing
 */
+ (REPricing *)pricing;


#pragma mark - Utilities

/** Helper method to create UIAlerViews based in any error provided by this SDK.
 @param error Error used to create the UIAlertView
 */
+ (UIAlertView *)alertViewWithError:(NSError *)error;

@end
