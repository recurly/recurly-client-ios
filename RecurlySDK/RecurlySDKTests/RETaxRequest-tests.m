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
    RETaxRequest *request = [[RETaxRequest alloc] initWithPostalCode:@"94131" countryCode:@"ES"];

    XCTAssertEqualObjects(request.postalCode, @"94131");
    XCTAssertEqualObjects(request.countryCode, @"ES");
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
    XCTAssertEqualObjects(request.countryCode, @"US");
    XCTAssertNil([request validate]);
}

- (void)testInitializeTaxRequestManually
{
    RETaxRequest *request = [[RETaxRequest alloc] init];
    XCTAssertEqualObjects(request.currency, @"US"); // this is loaded from
    request.currency = @"EUR";
    request.postalCode = @"94132";
    request.countryCode = @"US";
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
    request.countryCode = @"US";

    XCTAssertEqualObjects([[request validate] localizedDescription], @"Invalid postal code");
}

- (void)testMissingCountry
{
    RETaxRequest *request = [[RETaxRequest alloc] init];
    request.postalCode = @"94132";

    XCTAssertEqualObjects([[request validate] localizedDescription], @"Invalid country code");
}

@end
