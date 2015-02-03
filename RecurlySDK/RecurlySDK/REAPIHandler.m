//
//  Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

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
