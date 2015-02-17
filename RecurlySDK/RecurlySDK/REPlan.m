//
//  Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

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
    
    if(!setupFee || !unitAmount) {
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
    NSNumber *taxExempt = DYNAMIC_CAST(NSNumber, dict[@"tax_exempt"]);
    NSNumber *length = [REAPIUtils parseNumber:[dict valueForKeyPath:@"period.length"]];
    NSNumber *trialLength = [REAPIUtils parseNumber:[dict valueForKeyPath:@"trial.length"]];
    NSDictionary *price = DYNAMIC_CAST(NSDictionary, dict[@"price"]);
    NSArray *addons = DYNAMIC_CAST(NSArray, dict[@"addons"]);
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

- (REPlanPrice *)priceForCurrency:(NSString *)aCurrency
{
    return _price[aCurrency];
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
