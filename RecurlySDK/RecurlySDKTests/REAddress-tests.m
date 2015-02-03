//
//  REConfiguration-tests.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 28/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <RecurlySDK/RecurlySDK.h>
#import "Shared-tests.h"


REAddress *validAddress() {
    REAddress *address = [[REAddress alloc] init];
    address.firstName = @"Manu";
    address.lastName = @"Martinez-Almeida";
    address.country = @"US";

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
    CFDictionaryRef dicref = CFDictionaryCreate(kCFAllocatorDefault, (void *)keys, (void *)values, 5, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

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
    XCTAssertEqualObjects(address.country, @"US");

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
    address.country = @"US";
    XCTAssertNil([address validate]);
}

- (void)testMissingCountryCode
{  
    REAddress *address = validAddress();
    address.country = nil;
    XCTAssertEqualObjects([[address validate] localizedDescription], @"Invalid country code");

    address.country = @"";
    XCTAssertEqualObjects([[address validate] localizedDescription], @"Invalid country code");

    address.country = @"JJ";
    XCTAssertEqualObjects([[address validate] localizedDescription], @"Invalid country code");
}

@end
