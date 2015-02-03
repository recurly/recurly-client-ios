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
#import <AddressBook/AddressBook.h>
#import "REAddress.h"
#import "REValidation.h"
#import "REMacros.h"
#import "REError.h"
#import "Foundation+Recurly.h"


static NSString *readProperty(ABRecordRef record, ABPropertyID propertyId)
{
    return CFBridgingRelease(ABRecordCopyValue(record, propertyId));
}

static NSString *readKey(NSDictionary *dict, CFStringRef key)
{
    if(dict) {
        return dict[(__bridge __strong id)(key)];
    }else{
        return nil;
    }
}

static NSDictionary *readAddress(ABRecordRef record)
{
    CFTypeRef addressInfo = ABRecordCopyValue(record, kABPersonAddressProperty);
    if(addressInfo) {
        NSDictionary *dict = CFBridgingRelease(ABMultiValueCopyValueAtIndex(addressInfo, 0));
        CFRelease(addressInfo);
        return dict;
    }else {
        return NULL;
    }
}


@implementation REAddress

- (instancetype)initWithABRecord:(ABRecordRef)record
{
    self = [super init];
    if (self) {
        [self parseABRecord:record];
    }
    return self;
}


- (void)parseABRecord:(ABRecordRef)record
{
    _firstName      = readProperty(record, kABPersonFirstNameProperty);
    _lastName       = readProperty(record, kABPersonLastNameProperty);
    _companyName    = readProperty(record, kABPersonOrganizationProperty);

    NSDictionary *firstAddress = readAddress(record);
    _address1   = readKey(firstAddress, kABPersonAddressStreetKey);
    _city       = readKey(firstAddress, kABPersonAddressCityKey);
    _postalCode = readKey(firstAddress, kABPersonAddressZIPKey);
    _state      = readKey(firstAddress, kABPersonAddressStateKey);
    _countryCode= readKey(firstAddress, kABPersonAddressCountryCodeKey);
}


- (NSDictionary *)JSONDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];

    [dict setOptionalObject:_firstName forKey:@"first_name"];
    [dict setOptionalObject:_lastName forKey:@"last_name"];
    [dict setOptionalObject:_companyName forKey:@"company"];
    [dict setOptionalObject:_vatCode forKey:@"vat_code"];
    [dict setOptionalObject:_phone forKey:@"phone"];

    [dict setOptionalObject:_address1 forKey:@"address1"];
    [dict setOptionalObject:_address2 forKey:@"address2"];
    [dict setOptionalObject:_city forKey:@"city"];
    [dict setOptionalObject:_postalCode forKey:@"postal_code"];
    [dict setOptionalObject:_state forKey:@"state"];
    [dict setOptionalObject:_countryCode forKey:@"country"];

    return dict;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"REAddress{\n"
            @"\t-First name: %@\n"
            @"\t-Last name: %@\n"
            @"\t-Company name: %@\n"
            @"\t-VAT code: %@\n"
            @"\t-Address1: %@\n"
            @"\t-Address2: %@\n"
            @"\t-Postal code: %@\n"
            @"\t-City: %@\n"
            @"\t-State: %@\n"
            @"\t-Country code: %@\n}",
            _firstName, _lastName, _companyName, _vatCode,
            _address1, _address2, _postalCode, _city, _state, _countryCode];
}


- (NSError *)validate
{
    if(![REValidation validateCountryCode:_countryCode]) {
        return [REError invalidFieldError:@"country code" message:nil];
    }
    return nil;
}

@end
