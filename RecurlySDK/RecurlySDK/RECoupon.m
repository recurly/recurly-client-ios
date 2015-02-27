//
//  RECoupon.m
//  RecurlySDK
//
//  Created by Peter Hsu on 12/5/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

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

    if(!_name || !_code)
        return NO;

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

    if(!type || (!discountRate && !fixedDiscounts)) {
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
