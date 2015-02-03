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


@interface REErrorTests : XCTestCase
@end

@implementation REErrorTests

- (void)testInvalidFieldErrorWithoutMessage
{
    NSError *error = [REError invalidFieldError:@"country code" message:nil];
    XCTAssertEqual(error.code, kREErrorInvalidField);
    XCTAssertEqualObjects(error.localizedDescription, @"Invalid country code");
    XCTAssertEqualObjects(error.localizedFailureReason, @"Invalid country code");
}

- (void)testInvalidFieldErrorWithMessage
{
    NSError *error = [REError invalidFieldError:@"country code" message:@"hey! it is wrong"];
    XCTAssertEqualObjects(error.localizedDescription, @"hey! it is wrong");
    XCTAssertEqualObjects(error.localizedFailureReason, @"Invalid country code");
}

- (void)testInvalidFieldErrorIsNill
{
    XCTAssertNil([REError invalidFieldError:nil message:nil]);
    XCTAssertNil([REError invalidFieldError:nil message:@"hello"]);
}

- (void)testBackendErrorWith200
{
    NSDictionary *dict = @{@"message": @"This is an error message",
                           @"code": @"This is a code"};

    NSError *error = [REError backendErrorWithDictionary:dict statusCode:200];
    XCTAssertEqual(error.code, kREErrorBackend);
    XCTAssertEqualObjects(error.localizedDescription, @"This is an error message");
    XCTAssertEqualObjects(error.localizedFailureReason, @"This is a code");
}

- (void)testBackendErrorWith400
{
    NSDictionary *dict = @{@"message": @"This is an error message",
                           @"code": @"This is a code"};

    NSError *error = [REError backendErrorWithDictionary:dict statusCode:400];
    XCTAssertEqual(error.code, kREErrorBackend);
    XCTAssertEqualObjects(error.localizedDescription, @"This is an error message");
    XCTAssertEqualObjects(error.localizedFailureReason, @"This is a code");
}

- (void)testNilBackendErrorWith200
{
    NSDictionary *dict = @{@"tax":@"this is not a error"};
    XCTAssertNil([REError backendErrorWithDictionary:dict statusCode:200]);
    XCTAssertNil([REError backendErrorWithDictionary:nil statusCode:200]);
}

- (void)testNilBackendErrorWith400_500
{
    NSDictionary *dict = @{@"tax":@"this is not a error"};
    NSError *error = [REError backendErrorWithDictionary:dict statusCode:400];
    XCTAssertEqual(error.code, kREErrorBackend);
    XCTAssertEqualObjects(error.localizedDescription, @"bad request");
    XCTAssertEqualObjects(error.localizedFailureReason, @"Code 400");

    error = [REError backendErrorWithDictionary:nil statusCode:500];
    XCTAssertEqualObjects(error.localizedDescription, @"internal server error");
    XCTAssertEqualObjects(error.localizedFailureReason, @"Code 500");
}

@end
