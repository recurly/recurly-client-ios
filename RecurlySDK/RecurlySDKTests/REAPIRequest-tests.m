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
#import "REAPIUtils.h"


@interface REAPIRequestTests : XCTestCase
@end

@implementation REAPIRequestTests

- (void)configRecurly
{
    [Recurly setConfiguration:[[REConfiguration alloc] initWithPublicKey:@"aaa"
                                                                currency:@"US"
                                                             apiEndpoint:@"http://api.recurly.com/dev/v2"
                                                                 timeout:1000]];
}

- (void)testInitializeRequest
{
    REAPIRequest *request = [[REAPIRequest alloc] initWithURL:[NSURL URLWithString:@"http://google.com"]
                                                       method:@"HEAD"
                                                         data:nil
                                                      timeout:10];

    XCTAssertEqualObjects([[request URL] absoluteString], @"http://google.com");
    XCTAssertEqualObjects([request HTTPMethod], @"HEAD");
    XCTAssertEqualWithAccuracy([request timestamp], [REAPIUtils timestamp], 1);
    XCTAssertNil([request HTTPBody]);
    XCTAssertEqual([request timeoutInterval], 10);
}


- (void)testCreatePayloadRequest
{
    [self configRecurly];

    NSDictionary *dict = @{@"foo": @"bar",
                           @"nu": @"123" };

    REAPIRequest *request = [REAPIRequest requestWithEndpoint:@"/payment"
                                                       method:@"POST"
                                                      payload:dict];

    NSDictionary *expectedDict = @{@"foo": @"bar",
                           @"nu": @"123",
                           @"key": @"aaa",
                           @"version": @"3.0.9"};


    XCTAssertEqualObjects([[request URL] absoluteString], @"http://api.recurly.com/dev/v2/payment");
    XCTAssertEqualObjects([request HTTPMethod], @"POST");
    XCTAssertEqualObjects([request HTTPBody], [NSJSONSerialization dataWithJSONObject:expectedDict options:0 error:nil]);
    XCTAssertEqual([request timeoutInterval], 1000);
}


- (void)testCreateQueryStringRequest
{
    [self configRecurly];

    REAPIRequest *request = [REAPIRequest requestWithEndpoint:@"tax"
                                                       method:@"GET"
                                                     URLquery:@{@"foo": @"bar",
                                                                @"nu": @"123" }];

    XCTAssertEqualObjects([[request URL] absoluteString], @"http://api.recurly.com/dev/v2/tax?foo=bar&key=aaa&nu=123&version=3.0.9");
    XCTAssertEqualObjects([request HTTPMethod], @"GET");
    XCTAssertNil([request HTTPBody]);
    XCTAssertEqual([request timeoutInterval], 1000);
}

- (void)testCreateDataRequest
{
    [self configRecurly];

    NSData *body = [NSData dataWithBytes:"1234" length:4];
    REAPIRequest *request = [REAPIRequest requestWithEndpoint:@"/tax" method:@"GET" data:body];

    XCTAssertEqualObjects([[request URL] absoluteString], @"http://api.recurly.com/dev/v2/tax");
    XCTAssertEqualObjects([request HTTPMethod], @"GET");
    XCTAssertEqualObjects([request HTTPBody], body);
    XCTAssertEqual([request timeoutInterval], 1000);
}


- (void)testCreateNULLPayloadRequest
{
    [self configRecurly];

    NSData *body = [@"{\"key\":\"aaa\",\"version\":\"3.0.9\"}" dataUsingEncoding:NSUTF8StringEncoding];
    REAPIRequest *request = [REAPIRequest requestWithEndpoint:@"payment" method:@"POST" payload:nil];

    XCTAssertEqualObjects([[request URL] absoluteString], @"http://api.recurly.com/dev/v2/payment");
    XCTAssertEqualObjects([request HTTPBody], body);
}


- (void)testCreateNULLQueryStringRequest
{
    [self configRecurly];

    REAPIRequest *request = [REAPIRequest requestWithEndpoint:@"/tax" method:@"GET" URLquery:nil];
    XCTAssertEqualObjects([[request URL] absoluteString], @"http://api.recurly.com/dev/v2/tax?key=aaa&version=3.0.9");
    XCTAssertNil([request HTTPBody]);
}


@end
