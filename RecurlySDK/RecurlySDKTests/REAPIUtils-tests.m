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


@interface REAPIUtilsTests : XCTestCase
@end

@implementation REAPIUtilsTests

- (void)testTimestampGeneration
{
    NSTimeInterval timestamp = [REAPIUtils timestamp];
    NSTimeInterval expected = [[NSDate date] timeIntervalSince1970];

    XCTAssertEqualWithAccuracy(timestamp, expected, 1);
}

- (void)testBuildURLQuery
{
    NSString *finalURLQuery = [REAPIUtils buildURLQuery:@"http://example.com/"
                                             parameters:@{@"foo": @"bar"}];

    XCTAssertEqualObjects(finalURLQuery, @"http://example.com/?foo=bar");
}


- (void)testQueryString
{
    NSString *query = [REAPIUtils buildQueryString:@{@"foo": @"bar",
                                                     @"zeta": @1,
                                                     @"test": [NSNull null],
                                                     @"12": @"some value",
                                                     @"Zata": @2,
                                                     @"aA-&": @"start"}];
    NSString *expected =
    @"12=some%20value&"
    @"aA-%26=start&"
    @"foo=bar&"
    @"Zata=2&"
    @"zeta=1";

    XCTAssertEqualObjects(query, expected);
}

- (void)testQueryStringWithArrays
{
    NSString *query = [REAPIUtils buildQueryString:@{@"foo": @"bar",
                                                     @"zeta": @1,
                                                     @"zz": @[@"z22", @2, @"a four"],
                                                     @"12": @"some value",
                                                     @"a": @[@"1", @2, @"tres"]}];
    NSString *expected =
    @"12=some%20value&"
    @"a=1&a=2&a=tres&"
    @"foo=bar&"
    @"zeta=1&"
    @"zz=z22&zz=2&zz=a%20four";

    XCTAssertEqualObjects(query, expected);
}

- (void)testEncodeArray
{
    NSString *string = [REAPIUtils encodeArray:@[@"1", @"2", [NSNull null], @"Zaa", @"Abce"] key:@"key"];
    XCTAssertEqualObjects(string, @"key=1&key=2&key=Zaa&key=Abce");
}

- (void)testEncodeArrayEscaping
{
    NSString *string = [REAPIUtils encodeArray:@[@"1", @"2./", @"Zaa", @"Abce"] key:@"key"];
    XCTAssertEqualObjects(string, @"key=1&key=2.%2F&key=Zaa&key=Abce");
}

- (void)testJoinPath
{
    NSString *path;
    path = [REAPIUtils joinPath:@"http://recurly.com" secondPart:@"go/a?"];
    XCTAssertEqualObjects(path, @"http://recurly.com/go/a?");

    path = [REAPIUtils joinPath:@"http://recurly.com/" secondPart:@"go/a?"];
    XCTAssertEqualObjects(path, @"http://recurly.com/go/a?");

    path = [REAPIUtils joinPath:@"http://recurly.com" secondPart:@"/go/a?"];
    XCTAssertEqualObjects(path, @"http://recurly.com/go/a?");

    path = [REAPIUtils joinPath:@"http://recurly.com/" secondPart:@"/go/a?"];
    XCTAssertEqualObjects(path, @"http://recurly.com/go/a?");
}

- (void)testParseNumberInvalidInput
{
    XCTAssertNil([REAPIUtils parseNumber:nil]);
    XCTAssertNil([REAPIUtils parseNumber:[NSNull null]]);
    XCTAssertNil([REAPIUtils parseNumber:@{}]);
    XCTAssertNil([REAPIUtils parseNumber:@"hello"]);
    XCTAssertNil([REAPIUtils parseNumber:@"A10"]);
    XCTAssertNil([REAPIUtils parseNumber:@""]);
}

- (void)testParseNumberFromNumber
{
    XCTAssertEqualObjects([REAPIUtils parseNumber:@10], @10);

    NSNumber *number;
    number = @102.0;
    XCTAssertEqual([REAPIUtils parseNumber:number], number);

    number = [[NSDecimalNumber alloc] initWithString:@"10.45"];
    XCTAssertEqual([REAPIUtils parseNumber:number], number);
}

- (void)testParseNumberFromString
{
    XCTAssertEqualObjects([REAPIUtils parseNumber:@"10a"], @10);
    XCTAssertEqualObjects([REAPIUtils parseNumber:@"10.2"], @10.2);
    XCTAssertEqualObjects([REAPIUtils parseNumber:@"-12.1"], @(-12.1));
}

@end
