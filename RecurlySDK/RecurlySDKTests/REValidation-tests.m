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
