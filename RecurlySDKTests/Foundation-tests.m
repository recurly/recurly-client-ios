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
#import "Foundation+Recurly.h"
#import "Shared-tests.h"


@interface NSStringTests : XCTestCase
@end

@implementation NSStringTests

- (void)testFirstCharacter
{
    NSString *text = @"Hâlo";
    XCTAssertEqual([text firstCharacter], 'H');
    XCTAssertEqual([text firstCharacter], L'H');

    text = @"à";
    XCTAssertEqual([text firstCharacter], L'à');

    text = @" ";
    XCTAssertEqual([text firstCharacter], ' ');
}

- (void)testLastCharacter
{
    NSString *text = @"Hâlo";
    XCTAssertEqual([text lastCharacter], 'o');
    XCTAssertEqual([text lastCharacter], L'o');

    text = @"à";
    XCTAssertEqual([text lastCharacter], L'à');

    text = @" ";
    XCTAssertEqual([text lastCharacter], ' ');
}

- (void)testStringByTrimmingWhitespaces
{
    NSString *text = @"aaa     aa234";
    XCTAssertEqualObjects([text stringByTrimmingWhitespaces], @"aaa     aa234");

    text = @"aaa aa234  ";
    XCTAssertEqualObjects([text stringByTrimmingWhitespaces], @"aaa aa234");

    text = @"  aaa aa234";
    XCTAssertEqualObjects([text stringByTrimmingWhitespaces], @"aaa aa234");

    text = @" aaa aa234  ";
    XCTAssertEqualObjects([text stringByTrimmingWhitespaces], @"aaa aa234");

    text = @"   ";
    XCTAssertEqualObjects([text stringByTrimmingWhitespaces], @"");

    text = @"";
    XCTAssertEqualObjects([text stringByTrimmingWhitespaces], @"");
}


- (void)testStringByRemovingOccurrencesOfString
{
    NSString *text = @"aaa";
    XCTAssertEqualObjects([text stringByRemovingOccurrencesOfString:@"a"], @"");

    text = @"hi dude! how are you?";
    XCTAssertEqualObjects([text stringByRemovingOccurrencesOfString:@"dude"], @"hi ! how are you?");
}

@end



@interface NSDictionaryTests : XCTestCase
@end

@implementation NSDictionaryTests

- (void)testSetOptionalObject
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"key"] = @"value";
    [dict setOptionalObject:nil forKey:@"key"];
    XCTAssertEqualObjects(dict[@"key"], @"value");

    [dict setOptionalObject:@"value2" forKey:@"key"];
    [dict setOptionalObject:@"bar" forKey:@"foo"];
    XCTAssertEqualObjects(dict[@"key"], @"value2");
    XCTAssertEqualObjects(dict[@"foo"], @"bar");
}

@end


@interface NSRegularExpressionTests : XCTestCase
@end

@implementation NSRegularExpressionTests

- (void)testMatchesString
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^4[0-9]{3}?" options:0 error:nil];

    XCTAssertTrue([regex matchesString:@"4123"]);
    XCTAssertFalse([regex matchesString:@"3123"]);
}

@end


@interface NSNumberTests : XCTestCase
@end

@implementation NSNumberTests

- (void)testIfNumberIsNan
{
    NSDecimalNumber *nan = [NSDecimalNumber notANumber];
    XCTAssertTrue([nan isNaN]);

    nan = [NSDecimalNumber decimalNumberWithString:@"this is not a number"];
    XCTAssertTrue([nan isNaN]);

    nan = [NSDecimalNumber decimalNumberWithString:@"1.2345346456345645635"];
    XCTAssertFalse([nan isNaN]);
}

@end
