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

#import <Foundation/Foundation.h>
#import "REPlan.h"
#import "REMacros.h"
#import "REError.h"
#import "REAPIUtils.h"
#import "REPrivate.h"


@implementation REPlanPrice

- (instancetype)initWithDictionary:(NSDictionary *)dict currency:(NSString *)currency
{
    self = [super init];
    if (self) {
        _currency = currency;
        if(![self loadWithDictionary:dict])
            return nil;
    }
    return self;
}

- (BOOL)loadWithDictionary:(NSDictionary *)dict
{
    NSDecimalNumber *setupFee = [REAPIUtils parseDecimal:dict[@"setup_fee"]];
    NSDecimalNumber *unitAmount = [REAPIUtils parseDecimal:dict[@"unit_amount"]];
    NSString *symbol = DYNAMIC_CAST(NSString, dict[@"symbol"]);
    
    if(setupFee == nil || unitAmount == nil) {
        return NO;
    }
    _setupFee = setupFee;
    _unitAmount = unitAmount;
    _currencySymbol = symbol;
    
    return YES;
}

@end


@interface REPlan ()
{
    NSDictionary *_addonsByName;
}
@end

@implementation REPlan

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
    _interval = DYNAMIC_CAST(NSString, [dict valueForKeyPath:@"period.interval"]);
    _trialInterval = DYNAMIC_CAST(NSString, [dict valueForKeyPath:@"trial.interval"]);
    NSDictionary *price = DYNAMIC_CAST(NSDictionary, dict[@"price"]);
    NSArray *addons = DYNAMIC_CAST(NSArray, dict[@"addons"]);
    NSNumber *taxExempt = [REAPIUtils parseNumber:dict[@"tax_exempt"]];
    NSNumber *length = [REAPIUtils parseNumber:[dict valueForKeyPath:@"period.length"]];
    NSNumber *trialLength = [REAPIUtils parseNumber:[dict valueForKeyPath:@"trial.length"]];
    if(!_code || !_name || !_interval || !taxExempt || !length || !price)
        return NO;

    _taxExempt = [taxExempt boolValue];
    _length = [length unsignedIntegerValue];
    _trialLength = [trialLength unsignedIntegerValue];
    
    if (![self parsePrice:price]) {
        return NO;
    }
    return [self parseAddons:addons];
}


- (BOOL)parsePrice:(NSDictionary *)dict
{
    NSMutableDictionary *prices = [NSMutableDictionary dictionaryWithCapacity:[dict count]];
    for(NSString *currency in dict) {
        NSDictionary *priceDict = DYNAMIC_CAST(NSDictionary, dict[currency]);
        REPlanPrice *price = [[REPlanPrice alloc] initWithDictionary:priceDict currency:currency];
        if(price) {
            prices[currency] = price;
        }else{
            return NO;
        }
    }
    _price = prices;
    return YES;
}


- (BOOL)parseAddons:(NSArray *)array
{
    NSMutableDictionary *addonsByName = [NSMutableDictionary dictionaryWithCapacity:[array count]];
    for (NSDictionary *dict in array) {
        NSDictionary *priceDict = DYNAMIC_CAST(NSDictionary, dict);
        REAddon *addon = [[REAddon alloc] initWithDictionary:priceDict];
        if(addon) {
            addonsByName[addon.code] = addon;
        }else{
            return NO;
        }
    }
    _addonsByName = addonsByName;
    return YES;
}

- (NSArray *)addons
{
    return [_addonsByName allValues];
}

- (REAddon *)addonForName:(NSString *)name
{
    return _addonsByName[name];
}

- (REPlanPrice *)priceForCurrency:(NSString *)currency
{
    return _price[currency];
}

- (BOOL)hasTrial
{
    return _trialLength > 0;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"REPlan{\n"
            @"\t-Name: %@\n"
            @"\t-Code: %@\n"
            @"\t-Interval: %@\n"
            @"\t-Length: %lu\n"
            @"\t-Trial Interval: %@\n"
            @"\t-Trial Length: %lu\n"
            @"\t-TaxExempt: %d\n"
            @"\t-Addons: %@\n"
            @"\t-Price: %@\n}",
            _name, _code, _interval, (unsigned long)_length,
            _trialInterval, (unsigned long)_trialLength,
            _taxExempt, [self addons], _price];
}

@end
