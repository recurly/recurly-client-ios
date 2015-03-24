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
#import "REAPIResponse.h"


@interface REAPIResponseTests : XCTestCase
@end

@implementation REAPIResponseTests

- (REAPIRequest *)validRequest
{
    return [[REAPIRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.recurly.com/"]
                                      method:@"GET"
                                        data:nil
                                     timeout:100];
}

- (NSError *)emptyError:(NSInteger)code
{
    return [NSError errorWithDomain:@"com.recurly.sdk.ios.testing" code:code userInfo:nil];
}

- (void)testInitializeResponse
{
    NSDictionary *dict = @{@"foo": @"bar",
                           @"array": @[@"2"]};

    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    REAPIRequest *request = [self validRequest];

    REAPIResponse *response = [[REAPIResponse alloc] initWithRequest:request
                                                          statusCode:200
                                                            HTTPBody:data];

    XCTAssertEqual([response request], request);
    XCTAssertEqual([response HTTPBody], data);
    XCTAssertEqualObjects([response JSONDictionary], dict);
    XCTAssertNil([response JSONArray]);
    XCTAssertNil([response error]);
    XCTAssertEqual([response statusCode], 200);
}

- (void)testBadJSONBody
{
    NSData *data = [@"{\"foo\": \"bar'}" dataUsingEncoding:NSUTF8StringEncoding];
    REAPIResponse *response = [[REAPIResponse alloc] initWithRequest:[self validRequest]
                                                          statusCode:200
                                                            HTTPBody:data];

    XCTAssertNotNil(response.error);
    XCTAssertEqual(response.error, response.contentError);
}

- (void)testSeveralErrors
{
    NSData *data = [@"{\"foo\": \"bar'}" dataUsingEncoding:NSUTF8StringEncoding];
    REAPIResponse *response = [[REAPIResponse alloc] initWithRequest:[self validRequest]
                                                          statusCode:400
                                                            HTTPBody:data];

    XCTAssertNotNil(response.error);
    XCTAssertNotNil(response.contentError);
    XCTAssertEqual(response.error, response.backendError);
    XCTAssertNotEqual(response.error, response.contentError);
}

- (void)testParseBackendError
{
    NSDictionary *dict = @{@"error": @{@"message": @"This is an error message",
                                       @"code": @"This is a code"}};

    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    REAPIResponse *response = [[REAPIResponse alloc] initWithRequest:[self validRequest]
                                                          statusCode:200
                                                            HTTPBody:data];

    XCTAssertEqual(response.error, response.backendError);
    XCTAssertEqualObjects([[response error] localizedDescription], @"This is an error message");
    XCTAssertEqualObjects([[response error] localizedFailureReason], @"This is a code");
}

- (void)testParseEmptyBody
{
    REAPIResponse *response = [[REAPIResponse alloc] initWithRequest:[self validRequest]
                                                          statusCode:400
                                                            HTTPBody:nil];

    XCTAssertNil(response.contentError);
    XCTAssertNotNil(response.error);
    XCTAssertEqual(response.error, response.backendError);
}

- (void)testErrorsOrder
{
    NSError *networkError = [self emptyError:0];
    NSError *backendError = [self emptyError:1];
    NSError *sslError = [self emptyError:2];
    NSError *contentError = [self emptyError:3];

    REAPIResponse *response = [[REAPIResponse alloc] init];
    response.networkError = networkError;
    response.backendError = backendError;
    response.sslError = sslError;
    response.contentError = contentError;
    XCTAssertEqual([response error], networkError);

    response.networkError = nil;
    XCTAssertEqual([response error], sslError);

    response.sslError = nil;
    XCTAssertEqual([response error], backendError);

    response.backendError = nil;
    XCTAssertEqual([response error], contentError);

    response.contentError = nil;
    XCTAssertNil([response error]);
}

@end
