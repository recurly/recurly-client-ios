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

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#include <sys/sysctl.h> // needed for sysctlbyname()
#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
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
    if(obj == nil) {
        return nil;
    }
    if([obj isKindOfClass:[NSNumber class]]) {
        return [NSDecimalNumber decimalNumberWithDecimal:[obj decimalValue]];
    }
    if([obj isKindOfClass:[NSString class]]) {
        NSString *objString = (NSString *)obj;
        NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithString:objString];
        if(number == nil || [number isNaN]) {
            return nil;
        }
        return number;
    }
    return nil;
}


+ (NSNumber *)parseNumber:(id)obj
{
    if([obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }else{
        return [REAPIUtils parseDecimal:obj];
    }
}


+ (NSString *)deviceModel
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *model = (char*)malloc(size);
    sysctlbyname("hw.machine", model, &size, NULL, 0);
    NSString *deviceModel = @(model);
    free(model);
    return deviceModel;
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


+ (NSData*)SHA1:(NSData*)data
{
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([data bytes], (CC_LONG)[data length], digest);
    return [NSData dataWithBytes:digest length:sizeof(digest)];
}

//+ (NSString*)hexSHA1:(NSData*)data
//{
//    return [self hexEncoding:[self SHA1:data]];
//}


@end
