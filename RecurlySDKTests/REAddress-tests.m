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

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "RecurlySDK.h"
#import "Shared-tests.h"


REAddress *validAddress() {
    REAddress *address = [[REAddress alloc] init];
    address.firstName = @"Manu";
    address.lastName = @"Martinez-Almeida";
    address.countryCode = @"US";

    address.companyName = @"Recurly";
    address.vatCode = @"12232";
    address.address1 = @"451 Oak Park Dr.";
    address.address2 = @"Suite 0";
    address.postalCode = @"94131";
    address.state = @"CA";
    address.city = @"San Francisco";
    return address;
}

ABRecordRef validABRecord() {
    ABRecordRef person = ABPersonCreate();
    ABRecordSetValue(person, kABPersonFirstNameProperty, CFSTR("Manu"), nil);
    ABRecordSetValue(person, kABPersonLastNameProperty, CFSTR("Mtz"), nil);
    ABRecordSetValue(person, kABPersonOrganizationProperty, CFSTR("Recurly"), nil);
    return person;
}

ABRecordRef validABRecordWithAddress() {
    CFStringRef values[] = {
        CFSTR("451 Oak Park Dr."),
        CFSTR("San Francisco"),
        CFSTR("CA"),
        CFSTR("98344"),
        CFSTR("US")
    };

    CFStringRef keys[] = {
        kABPersonAddressStreetKey,
        kABPersonAddressCityKey,
        kABPersonAddressStateKey,
        kABPersonAddressZIPKey,
        kABPersonAddressCountryCodeKey
    };
    CFDictionaryRef dicref = CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)values, 5, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

    ABMutableMultiValueRef address = ABMultiValueCreateMutable(kABDictionaryPropertyType);
    ABMultiValueIdentifier identifier;
    ABMultiValueAddValueAndLabel(address, dicref, kABHomeLabel, &identifier);

    ABRecordRef person = validABRecord();
    ABRecordSetValue(person, kABPersonAddressProperty, address, NULL);
    CFRelease(address);

    return person;
}


@interface REAddressTests : XCTestCase
@end

@implementation REAddressTests

- (void)testInitializeWithFullABRecord
{
    ABRecordRef person = validABRecordWithAddress();
    REAddress *address = [[REAddress alloc] initWithABRecord:person];
    XCTAssertEqualObjects(address.firstName, @"Manu");
    XCTAssertEqualObjects(address.lastName, @"Mtz");
    XCTAssertEqualObjects(address.companyName, @"Recurly");
    XCTAssertEqualObjects(address.address1, @"451 Oak Park Dr.");
    XCTAssertEqualObjects(address.postalCode, @"98344");
    XCTAssertEqualObjects(address.city, @"San Francisco");
    XCTAssertEqualObjects(address.state, @"CA");
    XCTAssertEqualObjects(address.countryCode, @"US");

    NSDictionary *json = [address JSONDictionary];
    NSDictionary *expected = @{@"first_name": @"Manu",
                               @"last_name": @"Mtz",
                               @"company": @"Recurly",
                               @"address1": @"451 Oak Park Dr.",
                               @"city": @"San Francisco",
                               @"postal_code": @"98344",
                               @"state": @"CA",
                               @"country": @"US"};

    XCTAssertJSONSerializable(json);
    XCTAssertEqualObjects(json, expected);
}

- (void)testInitializeWithSimpleABRecord
{
    ABRecordRef person = validABRecord();
    REAddress *address = [[REAddress alloc] initWithABRecord:person];
    XCTAssertEqualObjects(address.firstName, @"Manu");
    XCTAssertEqualObjects(address.lastName, @"Mtz");
    XCTAssertEqualObjects(address.companyName, @"Recurly");

    NSDictionary *json = [address JSONDictionary];
    NSDictionary *expected = @{@"first_name": @"Manu",
                               @"last_name": @"Mtz",
                               @"company": @"Recurly"};

    XCTAssertJSONSerializable(json);
    XCTAssertEqualObjects(json, expected);
}

- (void)testInitializeWithBadABRecord
{
    ABRecordRef person = ABPersonCreate();
    ABRecordSetValue(person, kABPersonFirstNameProperty, CFSTR("Manu"), nil);

    REAddress *address = [[REAddress alloc] initWithABRecord:person];
    XCTAssertEqualObjects(address.firstName, @"Manu");
    XCTAssertNil(address.lastName);
    XCTAssertNotNil([address validate]);
}

- (void)testValidBasicAddress
{
    REAddress *address = [[REAddress alloc] init];
    address.countryCode = @"US";
    XCTAssertNil([address validate]);
}

- (void)testMissingCountryCode
{  
    REAddress *address = validAddress();
    address.countryCode = nil;
    XCTAssertEqualObjects([[address validate] localizedDescription], @"Invalid country code");

    address.countryCode = @"";
    XCTAssertEqualObjects([[address validate] localizedDescription], @"Invalid country code");

    address.countryCode = @"JJ";
    XCTAssertEqualObjects([[address validate] localizedDescription], @"Invalid country code");
}

@end
