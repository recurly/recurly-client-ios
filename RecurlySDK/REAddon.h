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


/** Encapsulates an addon included in a plan. Instances of this class are populared with the response of a 
 REPlanRequest.
 @see REPlan
 @see REPlanRequest
 @see Recurly
 */
@interface REAddon : NSObject

/** Addon id */
@property (nonatomic, readonly) NSString *code;

/** Addon name */
@property (nonatomic, readonly) NSString *name;

/** Number of units */
@property (nonatomic, readonly) NSUInteger quantity;

/** Dictionary containing the addon price for each currency.
 You should better use the priceForCurrency: method.
 @see priceForCurrency:
 */
@property (nonatomic, readonly) NSDictionary *price; // key = currency, value = price

/** Returns the addon's price for the specified currency code. ISO 4217
 @param aCurrency Currency code
 @return nil if there is not a defined price for the given currency.
 */
- (NSDecimalNumber *)priceForCurrency:(NSString *)aCurrency;

@end
