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
#import "REAPIHandler.h"
#import "REAPIRequest.h"
#import "REAPIResponse.h"
#import "RETaxRequest.h"
#import "RENetworker.h"
#import "RecurlyState.h"
#import "REPayment.h"
#import "REPlanRequest.h"
#import "REMacros.h"
#import "REError.h"
#import "REPrivate.h"
#import "RECoupon.h"
#import "RECouponRequest.h"


// TODO
// this class should be refactored

@implementation REAPIHandler ALLOC_DISABLED

+ (NSOperation *)enqueueRequest:(id<RERequestable>)aRequest
                     completion:(REAPICompletion)handler
{
    return [[[RecurlyState sharedInstance] networker] enqueueRequestable:aRequest completion:handler];
}


+ (NSOperation *)handlePaymentRequest:(REPayment *)request
                           completion:(void(^)(NSString *token, NSError *error))handler
{
    NSParameterAssert(handler);

    return [self enqueueRequest:request completion:^(REAPIResponse *response, NSError *error) {
        NSString *token = nil;
        if(error == nil) {
            token = DYNAMIC_CAST(NSString, [response JSONDictionary][@"id"]);
            if(token == nil) error = [REError unexpectedHTTPResponse];
        }
        handler(token, error);
    }];
}


+ (NSOperation *)handleTaxRequest:(RETaxRequest *)request
                       completion:(void(^)(RETaxes *taxes, NSError *error))handler
{
    NSParameterAssert(handler);

    return [self enqueueRequest:request completion:^(REAPIResponse *response, NSError *error) {
        RETaxes *taxes = nil;
        if(error == nil) {
            taxes = [[RETaxes alloc] initWithArray:[response JSONArray]];
            if(!taxes) error = [REError unexpectedHTTPResponse];
        }
        handler(taxes, error);
    }];
}

+ (NSOperation *)handlePlanRequest:(REPlanRequest *)request
                        completion:(void(^)(REPlan *plan, NSError *error))handler
{
    NSParameterAssert(handler);

    return [self enqueueRequest:request completion:^(REAPIResponse *response, NSError *error) {
        REPlan *plan = nil;
        if(error == nil) {
            plan = [[REPlan alloc] initWithDictionary:[response JSONDictionary]];
            if(!plan) error = [REError unexpectedHTTPResponse];
            
        }
        handler(plan, error);
    }];
}

+ (NSOperation *)handleCouponRequest:(RECouponRequest *)request
                          completion:(void(^)(RECoupon *coupon, NSError *error))handler
{
    NSParameterAssert(handler);
    
    return [self enqueueRequest:request completion:^(REAPIResponse *response, NSError *error) {
        RECoupon *coupon = nil;
        if (error == nil) {
            coupon = [[RECoupon alloc] initWithDictionary:[response JSONDictionary]];
            if(!coupon) error = [REError unexpectedHTTPResponse];
        }
        handler(coupon, error);
    }];

}

@end
