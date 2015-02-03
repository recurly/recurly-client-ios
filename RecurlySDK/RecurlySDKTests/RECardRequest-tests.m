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


@interface RECardRequestTests : XCTestCase
@end

@implementation RECardRequestTests

- (RECardRequest *)validCardRequest
{
    RECardRequest *payment = [[RECardRequest alloc] initWithCardNumber:@"4111111111111111"
                                                                   CVV:@"123"
                                                                 month:5
                                                                  year:20
                                                             firstName:@"Manu"
                                                              lastName:@"Martinez-Almeida"
                                                           countryCode:@"ES"];
    return payment;
}

- (void)testInitializeCardRequest
{
    RECardRequest *payment = [self validCardRequest];
    XCTAssertEqualObjects(payment.number, @"4111111111111111");
    XCTAssertEqualObjects(payment.cvv, @"123");
    XCTAssertEqualObjects(payment.billingAddress.firstName, @"Manu");
    XCTAssertEqualObjects(payment.billingAddress.lastName, @"Martinez-Almeida");
    XCTAssertEqualObjects(payment.billingAddress.country, @"ES");
    XCTAssertEqual(payment.expirationMonth, 5);
    XCTAssertEqual(payment.expirationYear, 20);
    XCTAssertEqualObjects(payment.type, @"visa");
    XCTAssertNil([payment validate]);
}

- (void)testInitializeCardRequestManually
{
    RECardRequest *payment = [RECardRequest new];
    payment.number = @"4111111111111111";
    payment.cvv = @"123";
    payment.expirationMonth = 5;
    payment.expirationYear = 2020;
    payment.billingAddress.firstName = @"Manu";
    payment.billingAddress.lastName = @"Martinez-Almeida";
    payment.billingAddress.country = @"US";

    XCTAssertNil([payment validate]);

    NSDictionary *json = [payment JSONDictionary];
    NSDictionary *expected = @{@"first_name": @"Manu",
                               @"last_name": @"Martinez-Almeida",
                               @"number": @"4111111111111111",
                               @"cvv": @"123",
                               @"country": @"US",
                               @"month": @5,
                               @"year": @2020 };

    XCTAssertJSONSerializable(json);
    XCTAssertEqualObjects(json, expected);
}

- (void)testInitializeCardRequestMinimun
{
    RECardRequest *payment = [RECardRequest new];
    payment.number = @"4111 1111 1111-1111";
    payment.cvv = @"123";
    payment.expirationMonth = 5;
    payment.expirationYear = 2020;
    payment.billingAddress.country = @"US";

    XCTAssertNil([payment validate]);

    NSDictionary *json = [payment JSONDictionary];
    NSDictionary *expected = @{@"number": @"4111111111111111",
                               @"cvv": @"123",
                               @"country": @"US",
                               @"month": @5,
                               @"year": @2020 };

    XCTAssertJSONSerializable(json);
    XCTAssertEqualObjects(json, expected);}


#pragma mark - Card Number Tests

- (void)testParseCard
{
    NSString *result = [RECardRequest parseCardNumber:@"    1111-0000 0000--22   22 "];
    NSString *expected = @"1111000000002222";
    XCTAssertEqualObjects(result, expected);

    XCTAssertEqualObjects([RECardRequest parseCardNumber:nil], @"");
}

- (void)testCardTypeVisa
{
    XCTAssertEqualObjects([RECardRequest cardTypeForNumber:@"4111-1111-1111-1111"], @"visa");
}

- (void)testCardTypeAmericanExpress
{
    XCTAssertEqualObjects([RECardRequest cardTypeForNumber:@"372546612345678"], @"american_express");
}

- (void)testCardTypeUnknown
{
    XCTAssertEqualObjects([RECardRequest cardTypeForNumber:@"867-5309-jenny"], @"unknown");
    XCTAssertEqualObjects([RECardRequest cardTypeForNumber:nil], @"unknown");
}


#pragma mark - Card number formatting

- (void)testCardFormatting
{
    XCTAssertEqualObjects(@"0123 4567 8987 6543", [RECardRequest formatCardNumber:@"0123456789876543"]);
    XCTAssertEqualObjects(@"1234 5678 9876 5432", [RECardRequest formatCardNumber:@"12  34-5678 987 65432"]);
    XCTAssertEqualObjects(@"123", [RECardRequest formatCardNumber:@"123   "]);
    XCTAssertEqualObjects(@"1234 5", [RECardRequest formatCardNumber:@"123-45 "]);
    XCTAssertEqualObjects(@"1234567a", [RECardRequest formatCardNumber:@"1234  567a"]);
    XCTAssertEqualObjects(@"a0232323", [RECardRequest formatCardNumber:@"a0232323"]);
    XCTAssertEqualObjects(@"", [RECardRequest formatCardNumber:@""]);
    XCTAssertEqualObjects(@"", [RECardRequest formatCardNumber:nil]);
}

@end
