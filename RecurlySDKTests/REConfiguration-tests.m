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
#import "RecurlySDK.h"


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
