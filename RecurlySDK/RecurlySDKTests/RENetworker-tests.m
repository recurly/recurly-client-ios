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
