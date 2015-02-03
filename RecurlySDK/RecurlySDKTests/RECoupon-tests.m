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
