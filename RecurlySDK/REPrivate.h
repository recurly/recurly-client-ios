/********************/
/** PRIVATE HEADER **/
/********************/
/*
 * The MIT License
 * Copyright (c) 2015 Recurly, Inc.

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

#import <Foundation/Foundation.h>
#import "REPlan.h"
#import "RECoupon.h"
#import "RETaxes.h"
#import "REProtocols.h"
#import "REPriceSummary.h"
#import "RECartSummary.h"
#import "REPricing.h"


@protocol REDeserializable
- (instancetype)initWithDictionary:(NSDictionary *)JSONDictionary;

@end


@interface REPricingResult ()

- (instancetype)initWithNow:(REPriceSummary *)now
                  recurrent:(REPriceSummary *)recurrent
                       cart:(RECartSummary *)cart;

@end

@interface REPriceSummary ()

+ (instancetype)summaryWithTaxRate:(NSDecimalNumber *)taxRate
                          currency:(NSString *)currency
                         planPrice:(NSDecimalNumber *)planPrice
                          setupFee:(NSDecimalNumber *)setupFee
                       addonsPrice:(NSDecimalNumber *)addonsPrice
                            coupon:(RECoupon *)coupon
                             error:(NSError *__autoreleasing*)error;

@end

@interface RECartSummary ()

- (instancetype)initWithPlan:(REPlan *)plan
                   planCount:(NSUInteger)planCount
                      addons:(NSDictionary *)addons
                      coupon:(RECoupon *)coupon
                    currency:(NSString *)currency;

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
