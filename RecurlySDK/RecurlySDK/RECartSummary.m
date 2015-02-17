//
//  RECartSummary.m
//  RecurlySDK
//
//  Created by Peter Hsu on 12/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import "RECartSummary.h"
#import "REMacros.h"
#import "REPrivate.h"


@implementation RECartSummary

- (instancetype)initWithPlan:(REPlan *)plan
                   planCount:(NSUInteger)planCount
                      addons:(NSDictionary *)addons
                      coupon:(RECoupon *)coupon
                    currency:(NSString *)currency
{
    self = [super init];
    if (self) {
        _plan = plan;
        _planCount = planCount;
        _addons = addons;
        _coupon = coupon;
        _currency = currency;
    }
    return self;
}

@end
