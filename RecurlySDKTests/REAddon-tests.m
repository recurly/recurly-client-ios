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
#import "Shared-tests.h"
#import "REPrivate.h"


@interface REAddonTests : XCTestCase
@end

@implementation REAddonTests

- (NSMutableDictionary *)validAddonsResponse
{
    NSDictionary *inmutable = @{@"code": @"sugar-light",
                                @"name": @"Sugar",
                                @"quantity": @12,
                                @"price": @{@"USD": @{@"unit_amount": @(10)},
                                            @"EUR": @{@"unit_amount": @(7.5)}}};
    return [inmutable mutableCopy];
}

- (REAddon *)createAddonWithoutField:(NSString *)field
{
    NSMutableDictionary *dict = [self validAddonsResponse];
    [dict removeObjectForKey:field];
    return [[REAddon alloc] initWithDictionary:dict];
}

- (void)testInitializeAddon
{
    NSDictionary *dict = [self validAddonsResponse];

    REAddon *addon = [[REAddon alloc] initWithDictionary:dict];
    XCTAssertEqualObjects(addon.code, @"sugar-light");
    XCTAssertEqualObjects(addon.name, @"Sugar");
    XCTAssertEqual(addon.quantity, 12UL);
    XCTAssertEqualObjects([addon priceForCurrency:@"USD"], @10);
    XCTAssertEqualObjects([addon priceForCurrency:@"EUR"], @7.5);
    XCTAssertNil([addon priceForCurrency:@"LIB"]);
}

- (void)testInitializeWithoutQuantity
{
    REAddon *addon = [self createAddonWithoutField:@"quantity"];
    XCTAssertNotNil(addon);
    XCTAssertEqual(addon.quantity, 0UL);
}

- (void)testMissingCode
{
    XCTAssertNil([self createAddonWithoutField:@"code"]);
}

- (void)testMissingName
{
    XCTAssertNil([self createAddonWithoutField:@"name"]);
}

- (void)testBadPrice
{
    NSMutableDictionary *dict = [self validAddonsResponse];
    dict[@"price"] = @{@"USD": @10,
                       @"EUR": @{@"unit_amount": @7.5}};

    REAddon *addon = [[REAddon alloc] initWithDictionary:dict];
    XCTAssertNil(addon);
}

@end
