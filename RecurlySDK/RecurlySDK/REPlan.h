//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "REProtocols.h"
#import "REAddon.h"


@interface REPlanPrice : NSObject

@property (nonatomic, readonly) NSString *currency;
@property (nonatomic, readonly) NSString *currencySymbol;
@property (nonatomic, readonly) NSDecimalNumber *setupFee;
@property (nonatomic, readonly) NSDecimalNumber *unitAmount;

@end


@interface REPlan : NSObject

@property (nonatomic, readonly) NSString *code;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *interval;
@property (nonatomic, readonly) NSUInteger length;
@property (nonatomic, readonly) NSString *trialInterval;
@property (nonatomic, readonly) NSUInteger trialLength;
@property (nonatomic, readonly) NSDictionary *price; // map of REPlanPrice, by currency
@property (nonatomic, readonly, getter=isTaxExempt) BOOL taxExempt;

- (REPlanPrice *)priceForCurrency:(NSString *)aCurrency;
- (REAddon *)addonForName:(NSString *)name;
- (NSArray *)addons;

@end
