//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RecurlySDK/REPlan.h>
#import <RecurlySDK/RECoupon.h>
#import <RecurlySDK/RETaxes.h>
#import <RecurlySDK/REProtocols.h>
#import <RecurlySDK/REPriceSummary.h>
#import <RecurlySDK/RECartSummary.h>


//
//@protocol REDeserializable
//
//- (id)initWithDictionary:(NSDictionary *)JSONDictionary;
//
//@end

@interface REPriceSummary ()

- (instancetype)initWithTaxRate:(NSDecimalNumber *)taxRate
                       currency:(NSString *)currency
                      planPrice:(NSDecimalNumber *)planPrice
                       setupFee:(NSDecimalNumber *)setupFee
                    addonsPrice:(NSDecimalNumber *)addonsPrice
                         coupon:(RECoupon *)coupon;
@end

@interface RECartSummary ()
- (instancetype)initWithNow:(REPriceSummary *)now recurrent:(REPriceSummary *)recurrent;
@end

@interface RETaxes ()

- (instancetype)initWithArray:(NSArray *)array;

@end


@interface REPlan () <REDeserializable>
@end

@interface RECoupon () <REDeserializable>
@end

@interface REAddon () <REDeserializable>
@end
