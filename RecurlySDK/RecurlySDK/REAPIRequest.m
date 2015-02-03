//
//  Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
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

+ (instancetype)requestWithEndpoint:(NSString *)endpoint
                             method:(NSString *)method
                            payload:(NSDictionary *)params
{
    NSData *data = nil;
    params = [self appendPublicKey:params];
    // TODO
    // handle error
    data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    return [self requestWithEndpoint:endpoint method:method data:data];
}


+ (instancetype)requestWithEndpoint:(NSString *)endpoint
                             method:(NSString *)method
                           URLquery:(NSDictionary *)params
{
    params = [self appendPublicKey:params];
    NSString *finalURL = [REAPIUtils buildURLQuery:endpoint parameters:params];

    if(!finalURL) {
        // TODO
        // handle error
        return nil;
    }
    return [self requestWithEndpoint:finalURL method:method data:nil];
}


+ (instancetype)requestWithEndpoint:(NSString *)endpoint
                             method:(NSString *)method
                               data:(NSData *)data
{
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
                                        [state version], @"version", nil];

    [finalParams addEntriesFromDictionary:params];
    return finalParams;
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
