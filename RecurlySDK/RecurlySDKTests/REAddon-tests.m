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
