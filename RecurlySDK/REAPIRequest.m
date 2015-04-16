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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "REAPIRequest.h"
#import "REAPIUtils.h"
#import "REMacros.h"
#import "RecurlyState.h"

// TODO
// this class should be refactored

@interface REAPIRequest (Private)
+ (NSDictionary *)appendPublicKey:(NSDictionary *)dict;

@end

@implementation REAPIRequest

+ (instancetype)GET:(NSString *)endpoint withQuery:(NSDictionary *)params
{
    params = [self appendPublicKey:params];
    NSString *finalURL = [REAPIUtils buildURLQuery:endpoint parameters:params];
    return [self requestWithEndpoint:finalURL method:@"GET" body:nil];
}


+ (instancetype)POST:(NSString *)endpoint withJSON:(NSDictionary *)params
{
    params = [self appendPublicKey:params];
    NSData *data = nil;
    if(params) {
        NSError *err;
        data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&err];
        if(data == nil) {
            RELOGERROR(@"REAPIRequest: JSON can't be serialized: %@", err);
            return nil;
        }
    }
    return [self requestWithEndpoint:endpoint method:@"POST" body:data];
}


+ (instancetype)POST:(NSString *)endpoint withBody:(NSData *)data
{
    return [self requestWithEndpoint:endpoint method:@"POST" body:data];
}


+ (instancetype)requestWithEndpoint:(NSString *)endpoint
                             method:(NSString *)method
                               body:(NSData *)data
{
    if(endpoint == nil) {
        return nil;
    }
    REConfiguration *config = [[RecurlyState sharedInstance] configuration];
    NSUInteger timeout = [config timeout];
    NSString *urlString = [REAPIUtils joinPath:[config apiEndpoint] secondPart:endpoint];
    return [[REAPIRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                      method:method
                                        data:data
                                     timeout:timeout];
}


+ (NSDictionary *)appendPublicKey:(NSDictionary *)params
{
    RecurlyState *state = [RecurlyState sharedInstance];
    NSString *publicKey = [[state configuration] publicKey];
    NSMutableDictionary *finalParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        publicKey, @"key",
                                        [RecurlyState version], @"version", nil];

    [finalParams addEntriesFromDictionary:params];
    return finalParams;
}


static inline NSString *empty(NSString *value) {
    return value ? [NSString stringWithFormat:@"/%@", value] : @"";
}

+ (NSString *)userAgent
{
    static NSString *userAgent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [netinfo subscriberCellularProvider];
        userAgent = [NSString stringWithFormat:@"recurly-ios/%@; "
                     @"device/%@; "
                     @"os/%@; "
                     @"carrierName%@; "
                     @"isoCountryCode%@; "
                     @"mobileCountryCode%@; "
                     @"mobileNetworkCode%@; "
                     @"appName/%@",
                     [RecurlyState version],
                     [REAPIUtils deviceModel],
                     [[UIDevice currentDevice] systemVersion],
                     empty([carrier carrierName]),
                     empty([carrier isoCountryCode]),
                     empty([carrier mobileCountryCode]),
                     empty([carrier mobileNetworkCode]),
                     [[NSBundle mainBundle] bundleIdentifier]];
    });
    return userAgent;
}


#pragma mark - Instance methods

- (instancetype)initWithURL:(NSURL *)url
                     method:(NSString *)method
                       data:(NSData *)data
                    timeout:(NSUInteger)timeout
{
    self = [super initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:timeout];
    if (self) {
        [self setHTTPMethod:method];
        [self setHTTPBody:data];
        [self setValue:[REAPIRequest userAgent] forHTTPHeaderField:@"User-Agent"];
        _timestamp = [REAPIUtils timestamp];
    }
    return self;
}


- (NSString *)description
{
    NSString *stringBody = [[NSString alloc] initWithData:[self HTTPBody] encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"REAPIRequest{\n"
            @"\t-URL: %@\n"
            @"\t-Method: %@\n"
            @"\t-Timeout: %.1f\n"
            @"\t-HTTP body: %@\n}",
            [[self URL] absoluteString], [self HTTPMethod], [self timeoutInterval], stringBody];
}

@end
