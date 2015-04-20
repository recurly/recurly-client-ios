/*
 * The MIT License
 * Copyright (c) 2015 Recurly, Inc.

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


@interface REErrorTests : XCTestCase
@end

@implementation REErrorTests

- (void)testErrorDomain
{
    XCTAssertTrue([RecurlyErrorDomain length] > 5);

}

- (void)testInvalidFieldErrorWithoutMessage
{
    NSError *error = [REError invalidFieldError:@"country code" message:nil];
    XCTAssertEqual(error.code, kREErrorInvalidField);
    XCTAssertEqualObjects(error.domain, RecurlyErrorDomain);
    XCTAssertEqualObjects(error.localizedDescription, @"Invalid country code");
    XCTAssertEqualObjects(error.localizedFailureReason, @"Invalid country code");
}

- (void)testInvalidFieldErrorWithMessage
{
    NSError *error = [REError invalidFieldError:@"country code" message:@"hey! it is wrong"];
    XCTAssertEqualObjects(error.domain, RecurlyErrorDomain);
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
    XCTAssertEqualObjects(error.domain, RecurlyErrorDomain);
    XCTAssertEqual(error.code, kREErrorBackend);
    XCTAssertEqualObjects(error.localizedDescription, @"This is an error message");
    XCTAssertEqualObjects(error.localizedFailureReason, @"This is a code");
}

- (void)testBackendErrorWith400
{
    NSDictionary *dict = @{@"message": @"This is an error message",
                           @"code": @"This is a code"};

    NSError *error = [REError backendErrorWithDictionary:dict statusCode:400];
    XCTAssertEqualObjects(error.domain, RecurlyErrorDomain);
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
