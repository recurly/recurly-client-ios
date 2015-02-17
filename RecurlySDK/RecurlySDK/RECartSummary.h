//
//  RECartSummary.h
//  RecurlySDK
//
//  Created by Peter Hsu on 12/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class REPlan;
@class RECoupon;
@interface RECartSummary : NSObject

@property (nonatomic, readonly) REPlan *plan;
@property (nonatomic, readonly) NSUInteger planCount;
@property (nonatomic, readonly) NSDictionary *addons;
@property (nonatomic, readonly) RECoupon *coupon;
@property (nonatomic, readonly) NSString *currency;

@end
