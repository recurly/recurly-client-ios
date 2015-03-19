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
                       countryCode:(NSString *)country
{
    self = [self init];
    if (self) {
        _postalCode = postalCode;
        _countryCode = country;
    }
    return self;
}

- (instancetype)initWithAddress:(REAddress *)anAddress
{
    return [self initWithPostalCode:anAddress.postalCode countryCode:anAddress.countryCode];
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
    NSAssert(_countryCode != nil, @"Country code can not be nil");
    NSAssert(_currency != nil, @"Currency can not be nil");

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
    [dict setOptionalObject:_postalCode forKey:@"postal_code"];
    [dict setOptionalObject:_countryCode forKey:@"country"];
    [dict setOptionalObject:_vatNumber forKey:@"vat_number"];
    [dict setOptionalObject:_currency forKey:@"currency"];

    return dict;
}


- (NSError *)validate
{
    if(IS_EMPTY(_postalCode)) {
        return [REError invalidFieldError:@"postal code" message:nil];
    }
    if(IS_EMPTY(_countryCode)) {
        return [REError invalidFieldError:@"country code" message:nil];
    }
    if(IS_EMPTY(_currency)) {
        return [REError invalidFieldError:@"currency" message:nil];
    }
    return nil;
}

@end
