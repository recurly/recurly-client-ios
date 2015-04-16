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


@interface REValidationTests : XCTestCase
@end

@implementation REValidationTests

- (void)testValidCardNumber
{
    XCTAssertTrue([REValidation validateCardNumber:@"4111111111111111"]);
    XCTAssertTrue([REValidation validateCardNumber:@"4111-1111-1111-1111"]);
    XCTAssertTrue([REValidation validateCardNumber:@"41 11 1111 1111 1111"]);
}

- (void)testInvalidCardNumber
{
    XCTAssertFalse([REValidation validateCardNumber:nil]);
    XCTAssertFalse([REValidation validateCardNumber:@""]);
    XCTAssertFalse([REValidation validateCardNumber:@"4111"]);
    XCTAssertFalse([REValidation validateCardNumber:@"4111111111111112"]);
    XCTAssertFalse([REValidation validateCardNumber:@"4111-1111-1111-1112"]);
    XCTAssertFalse([REValidation validateCardNumber:@"41111111111111111"]);
    XCTAssertFalse([REValidation validateCardNumber:@"4aa11111111111a1"]);
}


#pragma mark - Expiration Date Tests

- (void)testValidExpirationDate
{
    XCTAssertTrue([REValidation validateExpirationMonth:1 year:2020]);
    XCTAssertTrue([REValidation validateExpirationMonth:9 year:20]);
}

- (void)testBadExpirationDate
{
    XCTAssertFalse([REValidation validateExpirationMonth:1 year:2013], @"already expired");
    XCTAssertFalse([REValidation validateExpirationMonth:1 year:13], @"already expired");
}

- (void)testBadExpirationMonth
{
    XCTAssertFalse([REValidation validateExpirationMonth:0 year:20], @"0 natural number");
    XCTAssertFalse([REValidation validateExpirationMonth:-1 year:20], @"negative case");
    XCTAssertFalse([REValidation validateExpirationMonth:13 year:2020], @"greater than 12");
}

- (void)testBadExpirationYear
{
    XCTAssertFalse([REValidation validateExpirationMonth:5 year:0], @"year 0 doesn't exist");
}


#pragma mark - CVV tests

- (void)testValidCVV
{
    XCTAssertTrue([REValidation validateCVV:@"000"]);
    XCTAssertTrue([REValidation validateCVV:@"123"]);
    XCTAssertTrue([REValidation validateCVV:@"9999"]);
}

- (void)testValidCVVWithWhitespaces
{
    XCTAssertTrue([REValidation validateCVV:@" 000 "]);
    XCTAssertTrue([REValidation validateCVV:@"    123"]);
    XCTAssertTrue([REValidation validateCVV:@"   9999    "]);
}

- (void)testInvalidCVV
{
    XCTAssertFalse([REValidation validateCVV:nil]);
    XCTAssertFalse([REValidation validateCVV:@""]);
    XCTAssertFalse([REValidation validateCVV:@"11"]);
    XCTAssertFalse([REValidation validateCVV:@"11111"]);
    XCTAssertFalse([REValidation validateCVV:@"111a"]);
}

#pragma mark - Country code tests

- (void)testValidCountryCode
{
    XCTAssertTrue([REValidation validateCountryCode:@"US"]);
    XCTAssertTrue([REValidation validateCountryCode:@"ES"]);
    XCTAssertTrue([REValidation validateCountryCode:@"fr"]);
}

- (void)testInvalidCountryCodes
{
    XCTAssertFalse([REValidation validateCountryCode:nil]);
    XCTAssertFalse([REValidation validateCountryCode:@"A"]);
    XCTAssertFalse([REValidation validateCountryCode:@"AAA"]);
    XCTAssertFalse([REValidation validateCountryCode:@"AK"]);
}

@end
