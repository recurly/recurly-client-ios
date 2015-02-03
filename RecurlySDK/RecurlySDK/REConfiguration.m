//
//  Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "REConfiguration.h"
#import "REMacros.h"
#import "REError.h"


@implementation REConfiguration

- (instancetype)initWithPublicKey:(NSString *)aPublicKey
{
    self = [super init];
    if (self) {
        _publicKey = aPublicKey;
        _currency = @"USD";
        _apiEndpoint = @"https://api.recurly.com/js/v1";
        _timeout = 60000;
    }
    return self;
}


- (instancetype)initWithPublicKey:(NSString *)aPublicKey
                         currency:(NSString *)aCurrency
                      apiEndpoint:(NSString *)apiEndpoint
                          timeout:(NSUInteger)aTimeout
{
    self = [super init];
    if (self) {
        _publicKey = aPublicKey;
        _currency = aCurrency;
        _apiEndpoint = apiEndpoint;
        _timeout = aTimeout;
    }
    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"REConfiguration{\n"
            @"\t-Public key: %@\n"
            @"\t-Currency: %@\n"
            @"\t-API endpoint: %@\n"
            @"\t-Timeout: %lu\n}",
            _publicKey, _currency, _apiEndpoint, (unsigned long)_timeout];
}


- (NSError *)validate
{
    if(IS_EMPTY(_publicKey))
        return [REError invalidFieldError:@"public key" message:nil];

    if(IS_EMPTY(_currency))
        return [REError invalidFieldError:@"currency" message:nil];

    if(IS_EMPTY(_apiEndpoint))
        return [REError invalidFieldError:@"API endpoint" message:nil];

    if(_timeout == 0)
        return [REError invalidFieldError:@"timeout" message:nil];

    return nil;
}

@end
