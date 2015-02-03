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


@interface REConfigurationTests : XCTestCase
@end

@implementation REConfigurationTests

- (REConfiguration *)validConfiguration
{
    return [[REConfiguration alloc] initWithPublicKey:@"aaaaa"];;
}

- (void)testDefaultConfiguration
{
    REConfiguration *config = [self validConfiguration];
    XCTAssertEqualObjects(config.currency, @"USD");
    XCTAssertEqualObjects(config.apiEndpoint, @"https://api.recurly.com/js/v1");
    XCTAssertEqualObjects(config.publicKey, @"aaaaa");
    XCTAssertEqual(config.timeout, 60000UL);
    XCTAssertNil([config validate]);
}

- (void)testCustomConfiguration
{
    REConfiguration *config = [[REConfiguration alloc] initWithPublicKey:@"aaa"
                                                                currency:@"EUR"
                                                             apiEndpoint:@"http://me.recurly.com"
                                                                 timeout:10];
    XCTAssertEqualObjects(config.currency, @"EUR");
    XCTAssertEqualObjects(config.apiEndpoint, @"http://me.recurly.com");
    XCTAssertEqualObjects(config.publicKey, @"aaa");
    XCTAssertEqual(config.timeout, 10UL);
    XCTAssertNil([config validate]);
}

- (void)testMissingPublicKey
{
    REConfiguration *config = [self validConfiguration];
    config.publicKey = nil;
    XCTAssertEqualObjects([[config validate] localizedDescription], @"Invalid public key");

    config.publicKey = @"";
    XCTAssertEqualObjects([[config validate] localizedDescription], @"Invalid public key");
}

- (void)testMissingCurrency
{
    REConfiguration *config = [self validConfiguration];
    config.currency = nil;
    XCTAssertEqualObjects([[config validate] localizedDescription], @"Invalid currency");

    config.currency = @"";
    XCTAssertEqualObjects([[config validate] localizedDescription], @"Invalid currency");
}

- (void)testMissingApiEndpoint
{
    REConfiguration *config = [self validConfiguration];
    config.apiEndpoint = nil;
    XCTAssertEqualObjects([[config validate] localizedDescription], @"Invalid API endpoint");

    config.apiEndpoint = @"";
    XCTAssertEqualObjects([[config validate] localizedDescription], @"Invalid API endpoint");
}

- (void)testMissingTimeout
{
    REConfiguration *config = [self validConfiguration];
    config.timeout = 0;
    XCTAssertEqualObjects([[config validate] localizedDescription], @"Invalid timeout");
}

@end
