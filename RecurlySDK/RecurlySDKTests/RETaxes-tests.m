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
#import "RecurlySDK.h"
#import "REPrivate.h"


@interface RETaxesTests : XCTestCase
@end

@implementation RETaxesTests

- (void)testInitializeTaxes
{
    NSArray *array = @[@{@"type": @"us", @"region": @"CA", @"rate": @"0.085"},
                       @{@"type": @"vat", @"rate": @0.21}];

    RETaxes *taxes = [[RETaxes alloc] initWithArray:array];
    XCTAssertEqualObjects([taxes totalTax], [NSDecimalNumber decimalNumberWithString:@"0.27715"]);

    RETax *taxUS = taxes.taxes[0];
    XCTAssertEqualObjects(taxUS.type, @"us");
    XCTAssertEqualObjects(taxUS.region, @"CA");
    XCTAssertEqualObjects(taxUS.rate, [NSDecimalNumber decimalNumberWithString:@"0.085"]);

    RETax *taxEU = taxes.taxes[1];
    XCTAssertEqualObjects(taxEU.type, @"vat");
    XCTAssertNil(taxEU.region);
    XCTAssertEqualObjects(taxEU.rate, [NSDecimalNumber decimalNumberWithString:@"0.21"]);
}

- (void)testInitializeEmptyTaxes
{
    NSArray *array = @[];
    RETaxes *taxes = [[RETaxes alloc] initWithArray:array];
    XCTAssertEqualObjects([taxes totalTax], [NSDecimalNumber zero]);
}

- (void)testMissingDictionary
{
    RETaxes *taxes = [[RETaxes alloc] initWithArray:nil];
    XCTAssertNil(taxes);
}

- (void)testMissingType
{
    NSArray *array = @[@{@"type": @"us", @"rate": @"0.085"},
                       @{@"rate": @0.21}];

    RETaxes *taxes = [[RETaxes alloc] initWithArray:array];
    XCTAssertNil(taxes);
}


- (void)testMissingRate
{
    NSArray *array = @[@{@"type": @"us"},
                       @{@"type": @"vat", @"rate": @0.21}];

    RETaxes *taxes = [[RETaxes alloc] initWithArray:array];
    XCTAssertNil(taxes);
}

@end
