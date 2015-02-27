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


@interface REPriceSummaryTests : XCTestCase
@end

@implementation REPriceSummaryTests

- (REPriceSummary *)validPriceSummary
{
    NSError *error;
    return [REPriceSummary summaryWithTaxRate:[NSDecimalNumber decimalNumberWithString:@"0.3"]
                                     currency:@"USD"
                                    planPrice:[NSDecimalNumber decimalNumberWithString:@"10"]
                                     setupFee:[NSDecimalNumber decimalNumberWithString:@"2"]
                                  addonsPrice:[NSDecimalNumber decimalNumberWithString:@"4.2"]
                                       coupon:nil
                                        error:&error];
}

- (void)testCreatePriceSummary
{
    REPriceSummary *summary = [self validPriceSummary];
    XCTAssertEqualObjects(summary.taxRate, @0.3);
    XCTAssertEqualObjects(summary.currency, @"USD");
    XCTAssertEqualObjects(summary.planPrice, @10);
    XCTAssertEqualObjects(summary.setupFee, @2);
    XCTAssertEqualObjects(summary.addonsPrice, @4.2);

    XCTAssertEqualObjects(summary.subtotal, @16.2);
    XCTAssertEqualObjects(summary.tax, @4.86);
    XCTAssertEqualObjects(summary.total, @21.06);
}

- (void)test

@end
