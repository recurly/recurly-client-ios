//
//  Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

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
    _country    = readKey(firstAddress, kABPersonAddressCountryCodeKey);
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
    [dict setOptionalObject:_country forKey:@"country"];

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
            _address1, _address2, _postalCode, _city, _state, _country];
}


- (NSError *)validate
{
    if(![REValidation validateCountryCode:_country]) {
        return [REError invalidFieldError:@"country code" message:nil];
    }
    return nil;
}

@end
