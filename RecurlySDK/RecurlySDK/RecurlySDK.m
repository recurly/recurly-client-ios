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

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

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
    RETaxRequest *taxRequest = [[RETaxRequest alloc] initWithPostalCode:postalCode countryCode:countryCode];
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
    RECouponRequest *couponRequest = [[RECouponRequest alloc] initWithPlanCode:plan couponCode:code];
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
