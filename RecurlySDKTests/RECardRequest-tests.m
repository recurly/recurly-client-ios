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


@interface RECardRequestTests : XCTestCase
@end

@implementation RECardRequestTests

- (RECardRequest *)validCardRequest
{
    RECardRequest *payment = [RECardRequest requestWithCardNumber:@"4111111111111111"
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
    XCTAssertEqualObjects(payment.billingAddress.countryCode, @"ES");
    XCTAssertEqual(payment.expirationMonth, 5);
    XCTAssertEqual(payment.expirationYear, 20);
    XCTAssertEqual(payment.type, RECardTypeVisa);
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
    payment.billingAddress.countryCode = @"US";

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
    payment.billingAddress.countryCode = @"US";

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
    XCTAssertEqual([RECardRequest cardTypeForNumber:@"4111-1111-1111-1111"], RECardTypeVisa);
}

- (void)testCardTypeAmericanExpress
{
    XCTAssertEqual([RECardRequest cardTypeForNumber:@"372546612345678"], RECardTypeAmericanExpress);
}

- (void)testCardTypeUnknown
{
    XCTAssertEqual([RECardRequest cardTypeForNumber:@"867-5309-jenny"], RECardTypeUnknown);
    XCTAssertEqual([RECardRequest cardTypeForNumber:nil], RECardTypeUnknown);
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
