//
//  RECoupon.h
//  RecurlySDK
//
//  Created by Peter Hsu on 12/5/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "REProtocols.h"


extern NSString *const RecurlyCouponTypeFixed;
extern NSString *const RecurlyCouponTypePercent;

@interface RECoupon : NSObject

@property (nonatomic, readonly) NSString *code;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *type; // enum: RecurlyCouponType
@property (nonatomic, readonly) NSDecimalNumber *discountRate;
@property (nonatomic, readonly) NSDictionary *discountAmount; // currency, amount

- (NSDecimalNumber *)discountForSubtotal:(NSDecimalNumber *)subtotal currency:(NSString *)currency;

@end
