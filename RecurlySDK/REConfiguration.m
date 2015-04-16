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

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

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
    if(IS_EMPTY(_publicKey)) {
        return [REError invalidFieldError:@"public key" message:nil];
    }
    if(IS_EMPTY(_currency)) {
        return [REError invalidFieldError:@"currency" message:nil];
    }
    if(IS_EMPTY(_apiEndpoint)) {
        return [REError invalidFieldError:@"API endpoint" message:nil];
    }
    if(_timeout == 0) {
        return [REError invalidFieldError:@"timeout" message:nil];
    }
    return nil;
}

@end
