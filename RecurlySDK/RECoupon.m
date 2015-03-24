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

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "RECoupon.h"
#import "REMacros.h"
#import "REAPIUtils.h"


NSString *const RecurlyCouponTypeFixed = @"dollars";
NSString *const RecurlyCouponTypePercent = @"percent";

@implementation RECoupon

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        if(![self loadWithDictionary:dict])
            return nil;
    }
    return self;
}


- (BOOL)loadWithDictionary:(NSDictionary *)dict
{
    _name = DYNAMIC_CAST(NSString, dict[@"name"]);
    _code = DYNAMIC_CAST(NSString, dict[@"code"]);

    if(_name == nil || _code == nil) {
        return NO;
    }
    NSDictionary *discount = DYNAMIC_CAST(NSDictionary, dict[@"discount"]);
    return [self parseDiscount:discount];
}


- (BOOL)parseDiscount:(NSDictionary *)dict
{
    // TODO
    // we get either rate or fixed amount.  one is required, not both
    NSDecimalNumber *discountRate = [REAPIUtils parseDecimal:dict[@"rate"]];
    NSString *type = DYNAMIC_CAST(NSString, dict[@"type"]);
    NSDictionary *fixedDiscounts = DYNAMIC_CAST(NSDictionary, dict[@"amount"]);

    if(type==nil || (discountRate==nil && fixedDiscounts==nil)) {
        return NO;
    }
    _discountRate = discountRate;
    _type = type; // TODO, what does this mean?
    return [self parseFixedDiscounts:fixedDiscounts];
}


- (BOOL)parseFixedDiscounts:(NSDictionary *)discounts
{
    NSMutableDictionary *amounts = [NSMutableDictionary dictionaryWithCapacity:[discounts count]];
    for(NSString *currency in discounts) {
        NSDecimalNumber *amount = [REAPIUtils parseDecimal:discounts[currency]];
        if(amount) {
            amounts[currency] = amount;
        }else{
            return NO;
        }
    }
    _discountAmount = amounts;
    return YES;
}


- (NSDecimalNumber *)discountForSubtotal:(NSDecimalNumber *)subtotal currency:(NSString *)currency
{
    NSParameterAssert(subtotal);
    NSParameterAssert(currency);

    if (_discountRate && [_discountRate doubleValue] > 0) {
        return [subtotal decimalNumberByMultiplyingBy:_discountRate];

    }else{
        NSDecimalNumber *discount = _discountAmount[currency];
        return discount ? discount : [NSDecimalNumber zero];
    }
}


- (NSString *)description
{
    // TODO
    // this method should be refactored
    NSString *discountInfo = @"";
    if ([_type isEqualToString:RecurlyCouponTypeFixed]) {
        NSMutableArray *discountAmount = [[NSMutableArray alloc] init];
        [_discountAmount enumerateKeysAndObjectsUsingBlock:^(id currency, NSNumber *value, BOOL *stop) {
            NSString *entry = [NSString stringWithFormat:@"%.2f %@", [value floatValue], currency];
            [discountAmount addObject:entry];
        }];
        discountInfo = [discountAmount componentsJoinedByString:@","];

    } else if ([_type isEqualToString:RecurlyCouponTypePercent]) {
        discountInfo = [NSString stringWithFormat:@"%@%%", [_discountRate decimalNumberByMultiplyingByPowerOf10:2]];
    }

    return [NSString stringWithFormat:@"RECoupon{\n"
            @"\t-Name: %@\n"
            @"\t-Code: %@\n"
            @"\t-Discount type: %@\n"
            @"\t-Discount info: %@\n}",
            _name, _code, _type, discountInfo];
}

@end
