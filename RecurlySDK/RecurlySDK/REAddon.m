//
//  REAddon.m
//  RecurlySDK
//
//  Created by Peter Hsu on 12/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

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
    
    NSNumber *quantity = DYNAMIC_CAST(NSNumber, dict[@"quantity"]);
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
        
        NSNumber *unitAmount = [REAPIUtils parseNumber:priceDict[@"unit_amount"]];
        if(unitAmount) {
            prices[currency] = unitAmount;
        }else{
            return NO;
        }
    }
    _price = prices;
    return YES;
}


- (NSNumber *)priceForCurrency:(NSString *)aCurrency
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
