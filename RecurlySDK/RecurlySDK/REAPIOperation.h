//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@class REAPIRequest;
@class REAPIResponse;

typedef void (^REAPICompletion)(REAPIResponse *response, NSError *error);

@interface REAPIOperation : NSOperation <NSURLConnectionDataDelegate>

@property (nonatomic, readonly) REAPIRequest *request;
@property (nonatomic, strong) REAPICompletion completionHandler;

+ (instancetype)operationWithRequest:(REAPIRequest *)request completion:(REAPICompletion)handler;
- (instancetype)initWithRequest:(REAPIRequest *)request NS_DESIGNATED_INITIALIZER;

@end
