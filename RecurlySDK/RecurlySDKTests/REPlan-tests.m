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


@interface REPlanTests : XCTestCase
@end

@implementation REPlanTests

// TODO
// test bad parameters recursivelly
- (NSMutableDictionary *)validPlanResponse
{
    NSDictionary *inmutable = @{@"code": @"premium",
                                @"name": @"Premium",
                                @"tax_exempt": @YES,
                                @"period": @{@"interval": @"months", @"length": @1},
                                @"price": @{@"EUR": @{@"setup_fee": @1,
                                                      @"unit_amount": @10.1,
                                                      @"symbol": @"\u20ac"}}
                                };
    return [inmutable mutableCopy];
}

- (REPlan *)createWithoutField:(NSString *)field
{
    NSMutableDictionary *dict = [self validPlanResponse];
    [dict removeObjectForKey:field];
    return [[REPlan alloc] initWithDictionary:dict];
}

- (void)testInitializePlan
{
    NSDictionary *dict = [self validPlanResponse];
    REPlan *plan = [[REPlan alloc] initWithDictionary:dict];
    XCTAssertEqualObjects(plan.code, @"premium");
    XCTAssertEqualObjects(plan.name, @"Premium");
    XCTAssertEqualObjects(plan.interval, @"months");
    XCTAssertEqual(plan.length, 1UL);
    XCTAssertEqual(plan.isTaxExempt, YES);

    REPlanPrice *price = [plan priceForCurrency:@"EUR"];
    XCTAssertEqualObjects(price.currency, @"EUR");
    XCTAssertEqualObjects(price.setupFee, @1);
    XCTAssertEqualObjects(price.unitAmount, @10.1);
    XCTAssertEqual(plan.isTaxExempt, YES);
    
    XCTAssertNil([plan priceForCurrency:@"USD"]);
}

- (void)testMissingDictionary
{
    REPlan *taxes = [[REPlan alloc] initWithDictionary:nil];
    XCTAssertNil(taxes);
}

- (void)testMissingCode
{
    XCTAssertNil([self createWithoutField:@"code"]);
}

- (void)testMissingName
{
    XCTAssertNil([self createWithoutField:@"name"]);
}

- (void)testMissingTaxExempt
{
    XCTAssertNil([self createWithoutField:@"tax_exempt"]);
}

- (void)testMissingPeriod
{
    XCTAssertNil([self createWithoutField:@"period"]);
}

- (void)testMissingPrice
{
    XCTAssertNil([self createWithoutField:@"price"]);
}

@end
