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


FOUNDATION_EXTERN NSString *const RecurlyCouponTypeFixed;
FOUNDATION_EXTERN NSString *const RecurlyCouponTypePercent;

/** Encapsulates the response of a RECouponRequest.
 @see RECouponRequest
 @see Recurly
 */
@interface RECoupon : NSObject

/** Coupon code */
@property (nonatomic, readonly) NSString *code;

/** Coupon name */
@property (nonatomic, readonly) NSString *name;

/** Coupon type, it can be a rated discount or a fixed amount */
@property (nonatomic, readonly) NSString *type; // enum: RecurlyCouponType

/** Discount rate
 @discussion this value may be nil, if the discount is a fixed amount
 */
@property (nonatomic, readonly) NSDecimalNumber *discountRate;

/** Fixed discount amount, but the fixed amount is not unique, it may be different for each supported currency.
 @discussion this value may be nil, if the discount is a fixed amount
 */
@property (nonatomic, readonly) NSDictionary *discountAmount; // currency, amount


/** Calculates the discount amount (absolute value) for a given subtotal and currency.
 @param subtotal Subtotal
 @param currency Currency
 @discussion The amount can be fixed or a rate of the subtotal, use this method to calculate it properly.
 Do not implement it by yourself.
 */
- (NSDecimalNumber *)discountForSubtotal:(NSDecimalNumber *)subtotal currency:(NSString *)currency;

@end
