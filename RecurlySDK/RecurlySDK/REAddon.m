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

#import "REAddon.h"
#import "REMacros.h"
#import "REAPIUtils.h"


@implementation REAddon

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
    _code = DYNAMIC_CAST(NSString, dict[@"code"]);
    _name = DYNAMIC_CAST(NSString, dict[@"name"]);

    NSNumber *quantity = [REAPIUtils parseNumber:dict[@"quantity"]];
    _quantity = [quantity unsignedIntegerValue];
    
    NSDictionary *price = DYNAMIC_CAST(NSDictionary, dict[@"price"]);
    if(!_code || !_name)
        return NO;
    
    return [self parsePrice:price];
}


- (BOOL)parsePrice:(NSDictionary *)dict
{
    NSMutableDictionary *prices = [NSMutableDictionary dictionaryWithCapacity:[dict count]];
    for(NSString *currency in dict) {
        NSDictionary *priceDict = DYNAMIC_CAST(NSDictionary, dict[currency]);
        
        NSNumber *unitAmount = [REAPIUtils parseDecimal:priceDict[@"unit_amount"]];
        if(unitAmount) {
            prices[currency] = unitAmount;
        }else{
            return NO;
        }
    }
    _price = prices;
    return YES;
}


- (NSDecimalNumber *)priceForCurrency:(NSString *)aCurrency
{
    return _price[aCurrency];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"REAddon{\n"
            @"\t-Name: %@\n"
            @"\t-Code: %@\n"
            @"\t-Quantity: %d\n"
            @"\t-Price: %@\n}",
            _name, _code, (int)_quantity, _price];
}

@end
