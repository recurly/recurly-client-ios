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


@class RECartSummary, REPlan, RETaxes, REAddress, REPriceSummary;

@interface REPricingResult : NSObject

@property (nonatomic, readonly) REPriceSummary *now;
@property (nonatomic, readonly) REPriceSummary *recurrent;
@property (nonatomic, readonly) RECartSummary *cart;

@end

@interface REPricing : NSObject

/** Addons */
@property (nonatomic) NSDictionary *addons;

/** Number of plans included. 1 by default */
@property (nonatomic) NSUInteger planCount;

/** Coupon code. Used for discounts */
@property (nonatomic) NSString *couponCode;

/** Country code. Used for taxes */
@property (nonatomic) NSString *countryCode;

/** Postal code. Used for taxes */
@property (nonatomic) NSString *postalCode;

/** VAT code. Used for taxes */
@property (nonatomic) NSString *vatCode;

/** Currency code */
@property (nonatomic, readonly) NSString *currency;

/** Delegate */
@property (nonatomic, weak) id<REPricingHandlerDelegate>delegate;

/** Initializes a Pricing object with the specified currency.
 @param currency Currency code
 */
- (instancetype)initWithCurrency:(NSString *)currency NS_DESIGNATED_INITIALIZER;

/** Sets the plan code
 @param planCode Plan code
 */
- (void)setPlanCode:(NSString *)planCode;

/** Sets the country code. Used for taxing
 @param country Country Code
 */
- (void)setCountryCode:(NSString *)country;

/** Sets address. Used to populate the country and postal code
 @param anAddress Address container
 */
- (void)setAddress:(REAddress *)anAddress;

/** Updates the quantity of included addons.
 @param addonName Addon name
 @param quantity Number of the specified addons included
 */
- (void)updateAddon:(NSString *)addonName quantity:(NSUInteger)quantity;

@end
