//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RecurlySDK/REProtocols.h>


@interface REAPIRequest : NSMutableURLRequest

@property (nonatomic, readonly) NSTimeInterval timestamp;

+ (instancetype)requestWithEndpoint:(NSString *)endpoint
                             method:(NSString *)method
                            payload:(NSDictionary *)params;

+ (instancetype)requestWithEndpoint:(NSString *)endpoint
                             method:(NSString *)method
                           URLquery:(NSDictionary *)params;

+ (instancetype)requestWithEndpoint:(NSString *)endpoint
                             method:(NSString *)method
                               data:(NSData *)data;

- (instancetype)initWithURL:(NSURL *)endpoint
                     method:(NSString *)method
                       data:(NSData *)data
                    timeout:(NSUInteger)timeout NS_DESIGNATED_INITIALIZER;

@end
