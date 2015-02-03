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


@interface REPlanTests : XCTestCase
@end

@implementation REPlanTests

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
    return [NSMutableDictionary dictionaryWithDictionary:inmutable];
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

- (REPlan *)createWithoutField:(NSString *)field
{
    NSMutableDictionary *dict = [self validPlanResponse];
    [dict removeObjectForKey:field];
    return [[REPlan alloc] initWithDictionary:dict];
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
