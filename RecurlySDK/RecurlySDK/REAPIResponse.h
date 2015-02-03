//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@class REAPIRequest;
@interface REAPIResponse : NSObject

@property (nonatomic, readonly) REAPIRequest *request;
@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, readonly) NSData *HTTPBody;
@property (nonatomic, readonly) id JSONObject;

@property (nonatomic, strong) NSError *networkError;
@property (nonatomic, strong) NSError *backendError;
@property (nonatomic, strong) NSError *contentError;
@property (nonatomic, strong) NSError *sslError;

- (instancetype)initWithRequest:(REAPIRequest *)request
                     statusCode:(NSInteger)statusCode
                       HTTPBody:(NSData *)receivedData NS_DESIGNATED_INITIALIZER;

- (NSDictionary *)JSONDictionary;
- (NSArray *)JSONArray;
- (NSError *)error;
- (double)responseTime;

@end
