/*
 * The MIT License
 * Copyright (c) 2014-2015 Recurly, Inc.

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

/** Returns the plan's price for the specified currency code. ISO 4217
 @return nil if there is not a defined price for the given currency
 */
- (REPlanPrice *)priceForCurrency:(NSString *)aCurrency;

/** Each plan has a list of associated addons. This method returns a full description of the addon given the
 addon's name.
 @return nil if there is not a defined price for the given currency
 */
- (REAddon *)addonForName:(NSString *)name;
- (NSArray *)addons;
- (BOOL)hasTrial;

@end
