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

#include <math.h>
#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "RecurlySDK.h"
#import "RecurlyState.h"


@interface RecurlyTests : XCTestCase
@end

@implementation RecurlyTests

- (void)testDefaultConfiguration
{
    [Recurly configure:@"bbbb"];
    XCTAssertEqualObjects([[Recurly configuration] publicKey], @"bbbb");
}

- (void)testCustomConfiguration
{
    REConfiguration *config = [[REConfiguration alloc] initWithPublicKey:@"abc"
                                                                currency:@"EUR"
                                                             apiEndpoint:@"http://basic.recurly.com/v2"
                                                                 timeout:100];
    [Recurly setConfiguration:config];

    REConfiguration *loadedConfig = [Recurly configuration];
    XCTAssertEqual(loadedConfig, config);
    XCTAssertEqualObjects(loadedConfig.publicKey, @"abc");
    XCTAssertEqualObjects(loadedConfig.currency, @"EUR");
    XCTAssertEqualObjects(loadedConfig.apiEndpoint, @"http://basic.recurly.com/v2");
    XCTAssertEqual(loadedConfig.timeout, 100UL);
}

- (void)testRecurlyVersion
{
    XCTAssertTrue([[RecurlyState version] length] >= 5 );
}

- (void)testRecurlyNumberVersion
{
    double expected = 0;
    NSArray *parts = [[RecurlyState version] componentsSeparatedByString:@"."];
    int level = 0;
    for(NSString *part in parts) {
        expected += [part doubleValue] * pow(100, -level);
        level++;
    }
    XCTAssertEqual([RecurlyState versionNumber], expected);
}

@end
