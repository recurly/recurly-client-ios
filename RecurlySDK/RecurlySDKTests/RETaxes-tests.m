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
