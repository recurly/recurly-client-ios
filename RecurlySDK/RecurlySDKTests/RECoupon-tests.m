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


@interface RECouponTests : XCTestCase
@end

@implementation RECouponTests

- (void)testInitializeCoupon
{
    NSDictionary *dict = @{@"code": @"premium",
                           @"name": @"Premium",
                           @"discount": @{@"type": @"percent",
                                          @"rate": @"0.10",
                                          @"amount": @{@"USD": @11,
                                                       @"EUR": @"6"}}
                           };
    RECoupon *coupon = [[RECoupon alloc] initWithDictionary:dict];
    XCTAssertEqualObjects(coupon.code, @"premium");
    XCTAssertEqualObjects(coupon.name, @"Premium");
    XCTAssertEqualObjects(coupon.type, RecurlyCouponTypePercent);
    XCTAssertEqualObjects(coupon.discountRate, [NSDecimalNumber decimalNumberWithString:@"0.10"]);
    NSDictionary *expected = @{@"USD": @11, @"EUR": @6};
    XCTAssertEqualObjects(coupon.discountAmount, expected);
}

- (void)testMissingDictionary
{
    RETaxes *taxes = [[RETaxes alloc] initWithArray:nil];
    XCTAssertNil(taxes);
}

// TODO
// MORE UNIT TEST bad cases

@end
