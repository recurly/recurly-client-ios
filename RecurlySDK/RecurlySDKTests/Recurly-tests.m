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

@end
