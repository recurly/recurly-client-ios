//
//  RecurlySDK.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

// EXTERNAL FRAMEWORKS
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <PassKit/PassKit.h>
#import <AddressBook/AddressBook.h>

// BASIC
#import <RecurlySDK/REProtocols.h>
#import <RecurlySDK/REError.h>
#import <RecurlySDK/RecurlyState.h>
#import <RecurlySDK/REConfiguration.h>
#import <RecurlySDK/REValidation.h>


// NETWORKING PRIMITIVES
#import <RecurlySDK/REAPIRequest.h>
#import <RecurlySDK/REAPIResponse.h>
#import <RecurlySDK/RENetworker.h>
#import <RecurlySDK/REAPIOperation.h>
#import <RecurlySDK/REAPIUtils.h>

// MODELS
#import <RecurlySDK/REAddress.h>
#import <RecurlySDK/REPlan.h>
#import <RecurlySDK/RETaxes.h>
#import <RecurlySDK/RECoupon.h>
#import <RecurlySDK/REPricing.h>
#import <RecurlySDK/RECartSummary.h>
#import <RecurlySDK/REPriceSummary.h>


// REQUESTS
#import <RecurlySDK/RECardRequest.h>
#import <RecurlySDK/RECouponRequest.h>
#import <RecurlySDK/REPlanRequest.h>
#import <RecurlySDK/RETaxRequest.h>


//! Project version number for RecurlySDK.
FOUNDATION_EXPORT double RecurlySDKVersionNumber;

//! Project version string for RecurlySDK.
FOUNDATION_EXPORT const unsigned char RecurlySDKVersionString[];


@interface Recurly : NSObject

#pragma mark - Configuration

+ (void)configure:(NSString *)publicKey;
+ (void)setConfiguration:(REConfiguration *)config;
+ (REConfiguration *)configuration;


#pragma mark - API methods

+ (void)tokenWithRequest:(REPayment *)payment
              completion:(void(^)(NSString *token, NSError *error))handler;

+ (void)taxForPostalCode:(NSString *)postalCode
             countryCode:(NSString *)countryCode
              completion:(void(^)(RETaxes *taxes, NSError *error))handler;

+ (void)planForCode:(NSString *)code
         completion:(void(^)(REPlan *plan, NSError *error))handler;

+ (void)couponForPlan:(NSString *)plan
                 code:(NSString *)coupon
           completion:(void(^)(RECoupon *coupon, NSError *error))handler;

+ (REPricing *)pricing;


#pragma mark - Utilities

+ (UIAlertView *)alertViewWithError:(NSError *)error;

@end
