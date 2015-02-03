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
#import "RENetworker.h"

//TODO
@interface RENetworkerTests : XCTestCase
{
    RENetworker *_networker;
}
@end

@implementation RENetworkerTests

- (void)setUp
{
    [super setUp];
    _networker = [[RENetworker alloc] init];
}

- (void)tearDown
{
    _networker = nil;
    [super tearDown];
}


- (void)testRequestEnqueueing
{
    // TODO
//    XCTestExpectation *expectation = [self expectationWithDescription:@"The completion handler was called"];
//
//    REAPIRequest *request = [[REAPIRequest alloc] initWithURL:[NSURL URLWithString:@"http://examples.org"]
//                                                  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                              timeoutInterval:0];
//
//    REAPIOperation *operation = [_networker enqueueRequest:request
//                                                completion:^(REAPIResponse *response, NSError *err)
//    {
//        XCTAssertEqual(request, [response request]);
//        XCTAssertEqual(response.error, err);
//        XCTAssertEqual(response.error, response.networkError);
//        [expectation fulfill];
//    }];
//    XCTAssertTrue([[[_networker queue] operations] containsObject:operation]);
//
//    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
//        XCTAssertNil(error);
//    }];
}


- (void)testCancelRequest
{
    // TODO

//    XCTestExpectation *expectation = [self expectationWithDescription:@"The completion handler was called"];
//    REAPIRequest *request = [REAPIRequest requestWithEndpoint:@"test" method:@"GET" payload:nil];
//    REAPIOperation *operation = [_networker enqueueRequest:request completion:^(REAPIResponse *response) {
//        //XCTAssertEqual([response error], [REError operationCancelled]);
//        XCTAssertTrue(NO);
//        [expectation fulfill];
//    }];
//    [operation cancel];
//
//    XCTAssertEqual([[_networker queue] operationCount], 0);
//
//    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
