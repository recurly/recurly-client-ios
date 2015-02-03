//
//  Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "REAPIUtils.h"
#import "REMacros.h"
#import "Foundation+Recurly.h"


@implementation REAPIUtils ALLOC_DISABLED

+ (NSTimeInterval)timestamp
{
    return [[NSDate date] timeIntervalSince1970];
}


+ (NSDecimalNumber *)parseDecimal:(id)obj
{
    // TODO
    // refactor this method, Don't Repeat Yourself
    if(!obj) {
        return nil;
    }
    if([obj isKindOfClass:[NSNumber class]]) {
        return [NSDecimalNumber decimalNumberWithDecimal:[obj decimalValue]];
    }
    if([obj isKindOfClass:[NSString class]]) {
        NSString *objString = (NSString *)obj;
        NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithString:objString];
        if(!number || [number isNaN]) {
            return nil;
        }
        return number;
    }
    return nil;
}

+ (NSNumber *)parseNumber:(id)obj
{
    if(!obj) {
        return nil;
    }
    if([obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }
    if([obj isKindOfClass:[NSString class]]) {
        NSString *objString = (NSString *)obj;
        NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithString:objString];
        if(!number || [number isNaN]) {
            return nil;
        }
        return number;
    }
    return nil;
}


+ (NSString *)escape:(NSString *)component
{
    NSString *toEscape = @"!*'\"();:@&=+$,/?%#[]%+ ";
    CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
    CFStringRef result = CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)component,
                                                                 NULL, (__bridge CFStringRef)toEscape,
                                                                 encoding);
    return CFBridgingRelease(result);
}


+ (NSString *)buildURLQuery:(NSString *)baseURL parameters:(NSDictionary *)params
{
    if(!params) {
        return baseURL;
    }
    NSString *queryString = [self buildQueryString:params];
    return [NSString stringWithFormat:@"%@?%@", baseURL, queryString];
}


+ (NSString *)buildQueryString:(NSDictionary *)params
{
    NSMutableArray *parts = [NSMutableArray arrayWithCapacity:[params count]];
    NSArray *sortedKeys = [[params allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for(id key in sortedKeys) {
        NSString *part = [self encodeKey:[key description]
                                   value:params[key]];
        if(part != nil) {
            [parts addObject:part];
        }
    }
    return [parts componentsJoinedByString:@"&"];
}


+ (NSString *)encodeKey:(NSString *)key value:(id)value
{
    NSString *escapedKey = [self escape:[key description]];
    if([value isKindOfClass:[NSArray class]]) {
        return [self encodeArray:value key:key];

    }else if([value isKindOfClass:[NSNull class]]) {
        return nil;
        
    }else{
        NSString *escapedValue = [self escape:[value description]];
        return [NSString stringWithFormat:@"%@=%@", escapedKey, escapedValue];
    }
}


+ (NSString *)encodeArray:(NSArray *)array key:(NSString *)key
{
    NSMutableArray *parts = [NSMutableArray arrayWithCapacity:[array count]];
    for(id value in array) {
        if([value isKindOfClass:[NSNull class]]) {
            continue;
        }
        NSString *escapedValue = [self escape:[value description]];
        NSString *part = [NSString stringWithFormat:@"%@=%@", key, escapedValue];
        [parts addObject:part];
    }
    return [parts componentsJoinedByString:@"&"];
}


+ (NSString *)joinPath:(NSString *)firstPart secondPart:(NSString *)secondPart
{
    if([firstPart lastCharacter]=='/') {
        firstPart = [firstPart substringToIndex:[firstPart length]-1];
    }
    if([secondPart firstCharacter]=='/') {
        secondPart = [secondPart substringFromIndex:1];
    }
    return [NSString stringWithFormat:@"%@/%@", firstPart, secondPart];
}

@end
