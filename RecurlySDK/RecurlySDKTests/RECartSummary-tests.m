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


@interface RECartSummaryTests : XCTestCase
@end

@implementation RECartSummaryTests

- (void)testCreateCartSummary
{
    REPlan *plan = [[REPlan alloc] init];
    RECoupon *coupon = [[RECoupon alloc] init];
    NSDictionary *addons = @{@"orange": @2};
    RECartSummary *summary = [[RECartSummary alloc] initWithPlan:plan
                                                       planCount:2
                                                          addons:addons
                                                          coupon:coupon
                                                        currency:@"EUR"];
    XCTAssertEqual(summary.plan, plan);
    XCTAssertEqual(summary.coupon, coupon);
    XCTAssertEqual(summary.addons, addons);
    XCTAssertEqual(summary.planCount, 2LU);
    XCTAssertEqualObjects(summary.currency, @"EUR");
}

@end
