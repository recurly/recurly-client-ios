//
//  Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RETaxRequest.h"
#import "REAPIRequest.h"
#import "REAddress.h"
#import "RecurlyState.h"
#import "REMacros.h"
#import "REError.h"
#import "Foundation+Recurly.h"


@implementation RETaxRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        _currency = [[[RecurlyState sharedInstance] configuration] currency];
    }
    return self;
}

- (instancetype)initWithPostalCode:(NSString *)postalCode
                           country:(NSString *)country
{
    self = [self init];
    if (self) {
        _postalCode = postalCode;
        _country = country;
    }
    return self;
}

- (instancetype)initWithAddress:(REAddress *)anAddress
{
    self = [self initWithPostalCode:anAddress.postalCode
                            country:anAddress.country];
    return self;
}


- (REAPIRequest *)request
{
    return [REAPIRequest requestWithEndpoint:@"/tax"
                                      method:@"GET"
                                    URLquery:[self JSONDictionary]];
}


- (NSDictionary *)JSONDictionary
{
    NSAssert(_postalCode != nil, @"Postal code can not be nil");
    NSAssert(_country != nil, @"Country code can not be nil");
    NSAssert(_currency != nil, @"Currency can not be nil");

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
    [dict setOptionalObject:_postalCode forKey:@"postal_code"];
    [dict setOptionalObject:_country forKey:@"country"];
    [dict setOptionalObject:_vatNumber forKey:@"vat_number"];
    [dict setOptionalObject:_currency forKey:@"currency"];

    return dict;
}


- (NSError *)validate
{
    if(IS_EMPTY(_postalCode))
        return [REError invalidFieldError:@"postal code" message:nil];

    if(IS_EMPTY(_country))
        return [REError invalidFieldError:@"country code" message:nil];

    if(IS_EMPTY(_currency))
        return [REError invalidFieldError:@"currency" message:nil];

    return nil;
}

@end
