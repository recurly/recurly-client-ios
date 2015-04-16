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
#import "REPrivate.h"


@interface RECouponRequestTests : XCTestCase
@end

@implementation RECouponRequestTests

- (void)testInitializeCouponRequest
{
    RECouponRequest *request = [[RECouponRequest alloc] initWithPlanCode:@"plan_code" couponCode:@"12345"];
    XCTAssertEqualObjects(request.planCode, @"plan_code");
    XCTAssertEqualObjects(request.couponCode, @"12345");
    XCTAssertNil([request validate]);
}

- (void)testInitializeCouponRequestManually
{
    RECouponRequest *request = [[RECouponRequest alloc] init];
    request.planCode = @"plan_code";
    request.couponCode = @"12345";
    XCTAssertNil([request validate]);
}

- (void)testMissingPlanCode
{
    RECouponRequest *request = [[RECouponRequest alloc] init];
    request.couponCode = @"12345";
    XCTAssertEqualObjects([[request validate] localizedDescription], @"Invalid plan code");

    request.planCode = @"";
    XCTAssertEqualObjects([[request validate] localizedDescription], @"Invalid plan code");
}


- (void)testMissingCouponCode
{
    RECouponRequest *request = [[RECouponRequest alloc] init];
    request.planCode = @"plan_code";
    XCTAssertEqualObjects([[request validate] localizedDescription], @"Invalid coupon code");

    request.couponCode = @"";
    XCTAssertEqualObjects([[request validate] localizedDescription], @"Invalid coupon code");
}

@end
