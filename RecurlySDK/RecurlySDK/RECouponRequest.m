//
//  Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RECouponRequest.h"
#import "REAPIRequest.h"
#import "REMacros.h"
#import "REError.h"
#import "REAPIUtils.h"


@implementation RECouponRequest

- (instancetype)initWithPlan:(NSString *)plan coupon:(NSString *)coupon
{
    self = [super init];
    if (self) {
        _plan = plan;
        _coupon = coupon;
    }
    return self;
}

- (REAPIRequest *)request
{
    NSString *escapedPlan = [REAPIUtils escape:_plan];
    NSString *escapedCoupon = [REAPIUtils escape:_coupon];
    NSString *query = [NSString stringWithFormat:@"/plans/%@/coupons/%@", escapedPlan, escapedCoupon];
    return [REAPIRequest requestWithEndpoint:query
                                      method:@"GET"
                                    URLquery:nil];
}

- (NSError *)validate
{
    if(IS_EMPTY(_plan))
        return [REError invalidFieldError:@"plan code" message:nil];

    if(IS_EMPTY(_coupon))
        return [REError invalidFieldError:@"coupon code" message:nil];

    return nil;
}

@end
