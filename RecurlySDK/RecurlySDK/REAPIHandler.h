//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@class RETaxRequest;
@class RENetworker;
@class REPayment;
@class REPlanRequest;
@class REPlan;
@class RETaxes;
@class RECoupon;
@class RECouponRequest;

@interface REAPIHandler : NSObject

+ (NSOperation *)handleTaxRequest:(RETaxRequest *)request
                      completion:(void(^)(RETaxes *taxes, NSError *error))handler;

+ (NSOperation *)handlePaymentRequest:(REPayment *)request
                           completion:(void(^)(NSString *token, NSError *error))handler;

+ (NSOperation *)handleCouponRequest:(RECouponRequest *)request
                          completion:(void(^)(RECoupon *coupon, NSError *error))handler;

+ (NSOperation *)handlePlanRequest:(REPlanRequest *)request
                        completion:(void(^)(REPlan *plan, NSError *error))handler;

@end
