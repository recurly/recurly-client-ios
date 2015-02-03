//
//  Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecurlySDK.h"
#import "RecurlyState.h"
#import "REAPIHandler.h"
#import "REMacros.h"
#import "REPricing.h"


@implementation Recurly ALLOC_DISABLED

#pragma mark - Configuration

+ (void)configure:(NSString *)publicKey
{
    REConfiguration *config = [[REConfiguration alloc] initWithPublicKey:publicKey];
    [self setConfiguration:config];
}

+ (void)setConfiguration:(REConfiguration *)config
{
    [[RecurlyState sharedInstance] setConfiguration:config];
}

+ (REConfiguration *)configuration
{
    return [[RecurlyState sharedInstance] configuration];
}


#pragma mark - API methods

+ (void)tokenWithRequest:(REPayment *)payment
              completion:(void(^)(NSString *token, NSError *error))handler
{
    [REAPIHandler handlePaymentRequest:payment completion:handler];
}

+ (void)taxForPostalCode:(NSString *)postalCode
             countryCode:(NSString *)countryCode
              completion:(void(^)(RETaxes *taxes, NSError *error))handler
{
    RETaxRequest *taxRequest = [[RETaxRequest alloc] initWithPostalCode:postalCode country:countryCode];
    [REAPIHandler handleTaxRequest:taxRequest completion:handler];
}


+ (void)planForCode:(NSString *)code
         completion:(void(^)(REPlan *plan, NSError *error))handler
{
    REPlanRequest *planRequest = [[REPlanRequest alloc] initWithPlanCode:code];
    [REAPIHandler handlePlanRequest:planRequest completion:handler];
}

+ (void)couponForPlan:(NSString *)plan
                 code:(NSString *)code
           completion:(void(^)(RECoupon *coupon, NSError *error))handler
{
    RECouponRequest *couponRequest = [[RECouponRequest alloc] initWithPlan:plan coupon:code];
    [REAPIHandler handleCouponRequest:couponRequest completion:handler];
}

+ (REPricing *)pricing
{
    return [[REPricing alloc] init];
}


#pragma mark - Utilities

+ (UIAlertView *)alertViewWithError:(NSError *)error
{
    if(error == nil) {
        return nil;
    }
    return [[UIAlertView alloc] initWithTitle:[error localizedFailureReason]
                                      message:[error localizedDescription]
                                     delegate:nil
                            cancelButtonTitle:@"Ok"
                            otherButtonTitles:nil];
}

@end
