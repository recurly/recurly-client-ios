//
//  Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RETaxes.h"
#import "REMacros.h"
#import "REAPIUtils.h"


// TODO
// unit tests

@implementation RETax

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
    NSString *type = DYNAMIC_CAST(NSString, dict[@"type"]);
    NSDecimalNumber *rateNumber = [REAPIUtils parseDecimal:dict[@"rate"]];
    if(!type || !rateNumber)
        return NO;

    _region = DYNAMIC_CAST(NSString, dict[@"region"]); //optional
    _type = type;
    _rate = rateNumber;
    return YES;
}

@end


@implementation RETaxes

- (instancetype)initWithArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        if(![self loadWithArray:array])
            return nil;
    }
    return self;
}

- (BOOL)loadWithArray:(NSArray *)array
{
    if(!array) {
        return NO;
    }
    NSMutableArray *taxes = [NSMutableArray arrayWithCapacity:[array count]];
    for(id rawTax in array) {
        NSDictionary *dictTax = DYNAMIC_CAST(NSDictionary, rawTax);
        RETax *tax = [[RETax alloc] initWithDictionary:dictTax];
        if(tax) {
            [taxes addObject:tax];
        }else{
            return NO;
        }
    }
    _taxes = taxes;
    return YES;
}

- (NSDecimalNumber *)totalTax
{
    NSDecimalNumber *finalTax = [NSDecimalNumber one];
    for(RETax *tax in _taxes) {
        NSDecimalNumber *invTax = [[NSDecimalNumber one] decimalNumberBySubtracting:[tax rate]];
        finalTax = [finalTax decimalNumberByMultiplyingBy:invTax];
    }
    return [[NSDecimalNumber one] decimalNumberBySubtracting:finalTax];
}

// TODO
// add description method

@end
