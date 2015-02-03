//
//  REPlanPricing.h
//  RecurlySDK
//
//  Created by Peter Hsu on 12/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "REProtocols.h"


@interface REPriceSummary : NSObject

@property (nonatomic, readonly) NSString *currency;
@property (nonatomic, readonly) NSDecimalNumber *planPrice;
@property (nonatomic, readonly) NSDecimalNumber *setupFee;
@property (nonatomic, readonly) NSDecimalNumber *addonsPrice;
@property (nonatomic, readonly) NSDecimalNumber *discount;
@property (nonatomic, readonly) NSDecimalNumber *taxRate;
@property (nonatomic, readonly) NSDecimalNumber *subtotal;
@property (nonatomic, readonly) NSDecimalNumber *tax;
@property (nonatomic, readonly) NSDecimalNumber *total;

- (NSString *)localizedWithDecimal:(NSDecimalNumber *)decimal;
- (NSString *)localizedSubtotal;
- (NSString *)localizedTotal;

@end
