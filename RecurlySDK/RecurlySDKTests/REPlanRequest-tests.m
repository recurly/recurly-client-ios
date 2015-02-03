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


@interface REPlanRequestTests : XCTestCase
@end

@implementation REPlanRequestTests

- (void)testInitializePlanRequest
{
    REPlanRequest *request = [[REPlanRequest alloc] initWithPlanCode:@"plan_code"];
    XCTAssertEqualObjects(request.plan, @"plan_code");
    XCTAssertNil([request validate]);
}

- (void)testInitializePlanRequestManually
{
    REPlanRequest *request = [[REPlanRequest alloc] init];
    request.plan = @"plan_code";
    XCTAssertNil([request validate]);
}

- (void)testMissingPlanCode
{
    REPlanRequest *request = [[REPlanRequest alloc] init];
    XCTAssertEqualObjects([[request validate] localizedDescription], @"Invalid plan code");
}

@end
