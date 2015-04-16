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
#import "REProtocols.h"


@interface REPriceSummary : NSObject

/** Currency */
@property (nonatomic, readonly) NSString *currency;

/** Plan price */
@property (nonatomic, readonly) NSDecimalNumber *planPrice;

/** Setup fee */
@property (nonatomic, readonly) NSDecimalNumber *setupFee;

/** Aggregated price of the included addons */
@property (nonatomic, readonly) NSDecimalNumber *addonsPrice;

/** Applied discount */
@property (nonatomic, readonly) NSDecimalNumber *discount;

/** Tax rate applied to the subtotal */
@property (nonatomic, readonly) NSDecimalNumber *taxRate;

/** Subtotal */
@property (nonatomic, readonly) NSDecimalNumber *subtotal;

/** Tax amount */
@property (nonatomic, readonly) NSDecimalNumber *tax;

/** Total after taxes */
@property (nonatomic, readonly) NSDecimalNumber *total;

/** Returns a localized string of the subtotal */
- (NSString *)localizedSubtotal;

/** Returns a localized string of the total amount */
- (NSString *)localizedTotal;

@end
