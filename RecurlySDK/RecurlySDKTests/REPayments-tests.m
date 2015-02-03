//
//  REConfiguration-tests.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 28/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <AddressBook/AddressBook.h>
#import <RecurlySDK/RecurlySDK.h>


@interface REPaymentTests : XCTestCase
@end

@implementation REPaymentTests

- (void)testSetBillingAddress
{
    REAddress *address = [[REAddress alloc] init];
    REPayment *payment = [[REPayment alloc] init];
    [payment setBillingAddress:address];
    [payment setShippingAddress:nil];

    XCTAssertEqual([payment billingAddress], address);

    [payment setBillingAddress:nil];
    XCTAssertNil([payment billingAddress]);
}

- (void)testSetShippingAddress
{
    REAddress *address = [[REAddress alloc] init];
    REPayment *payment  = [[REPayment alloc] init];
    [payment setShippingAddress:address];
    [payment setBillingAddress:nil];

    XCTAssertEqual([payment shippingAddress], address);

    [payment setShippingAddress:nil];
    XCTAssertNil([payment shippingAddress]);
}

@end
