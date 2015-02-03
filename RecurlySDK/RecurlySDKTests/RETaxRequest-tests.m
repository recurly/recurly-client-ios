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
#import "REPrivate.h"
#import "Shared-tests.h"


@interface RETaxRequestTests : XCTestCase
@end

@implementation RETaxRequestTests

- (void)testInitializeTaxRequest
{
    RETaxRequest *request = [[RETaxRequest alloc] initWithPostalCode:@"94131"
                                                             country:@"ES"];

    XCTAssertEqualObjects(request.postalCode, @"94131");
    XCTAssertEqualObjects(request.country, @"ES");
    XCTAssertEqualObjects(request.currency, @"US");
    XCTAssertNil(request.vatNumber);
    XCTAssertNil([request validate]);

    NSDictionary *json = [request JSONDictionary];
    NSDictionary *expected = @{@"postal_code": @"94131",
                               @"country": @"ES",
                               @"currency": @"US"};

    XCTAssertJSONSerializable(json);
    XCTAssertEqualObjects(json, expected);
}

- (void)testInitializeTaxRequestFromAddress
{
    REAddress *address = validAddress();
    RETaxRequest *request = [[RETaxRequest alloc] initWithAddress:address];
    XCTAssertEqualObjects(request.postalCode, @"94131");
    XCTAssertEqualObjects(request.country, @"US");
    XCTAssertNil([request validate]);
}

- (void)testInitializeTaxRequestManually
{
    RETaxRequest *request = [[RETaxRequest alloc] init];
    XCTAssertEqualObjects(request.currency, @"US"); // this is loaded from
    request.currency = @"EUR";
    request.postalCode = @"94132";
    request.country = @"US";
    request.vatNumber = @"ES12345667";

    XCTAssertNil([request validate]);

    NSDictionary *json = [request JSONDictionary];
    NSDictionary *expected = @{@"postal_code": @"94132",
                               @"country": @"US",
                               @"currency": @"EUR",
                               @"vat_number": @"ES12345667"};

    XCTAssertJSONSerializable(json);
    XCTAssertEqualObjects(json, expected);
}

- (void)testMissingPostalCode
{
    RETaxRequest *request = [[RETaxRequest alloc] init];
    request.country = @"US";

    XCTAssertEqualObjects([[request validate] localizedDescription], @"Invalid postal code");
}

- (void)testMissingCountry
{
    RETaxRequest *request = [[RETaxRequest alloc] init];
    request.postalCode = @"94132";

    XCTAssertEqualObjects([[request validate] localizedDescription], @"Invalid country code");
}

@end
