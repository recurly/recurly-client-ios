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


@interface RECouponRequestTests : XCTestCase
@end

@implementation RECouponRequestTests

- (void)testInitializeCouponRequest
{
    RECouponRequest *request = [[RECouponRequest alloc] initWithPlan:@"plan_code" coupon:@"12345"];
    XCTAssertEqualObjects(request.plan, @"plan_code");
    XCTAssertEqualObjects(request.coupon, @"12345");
    XCTAssertNil([request validate]);
}

- (void)testInitializeCouponRequestManually
{
    RECouponRequest *request = [[RECouponRequest alloc] init];
    request.plan = @"plan_code";
    request.coupon = @"12345";
    XCTAssertNil([request validate]);
}

- (void)testMissingPlanCode
{
    RECouponRequest *request = [[RECouponRequest alloc] init];
    request.coupon = @"12345";
    XCTAssertEqualObjects([[request validate] localizedDescription], @"Invalid plan code");

    request.plan = @"";
    XCTAssertEqualObjects([[request validate] localizedDescription], @"Invalid plan code");
}


- (void)testMissingCouponCode
{
    RECouponRequest *request = [[RECouponRequest alloc] init];
    request.plan = @"plan_code";
    XCTAssertEqualObjects([[request validate] localizedDescription], @"Invalid coupon code");

    request.coupon = @"";
    XCTAssertEqualObjects([[request validate] localizedDescription], @"Invalid coupon code");
}

@end
