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


@interface REAPIOperationTests : XCTestCase
@end

@implementation REAPIOperationTests

- (void)testInitializeOperation
{
    REAPIRequest *request = [[REAPIRequest alloc] init];
    REAPIOperation *operation = [[REAPIOperation alloc] initWithRequest:request];
    XCTAssertEqual([operation request], request);
}

- (void)testCreateOperation
{
    REAPICompletion callback = ^(REAPIResponse *response, NSError *error) {};
    REAPIRequest *request = [[REAPIRequest alloc] init];
    REAPIOperation *operation = [REAPIOperation operationWithRequest:request
                                                          completion:callback];

    XCTAssertEqual([operation request], request);
    XCTAssertEqual([operation completionHandler], callback);
}

@end
