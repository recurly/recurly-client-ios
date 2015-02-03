//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RecurlySDK/REProtocols.h>
#import <RecurlySDK/REAPIOperation.h>


@class REAPIRequest;
@interface RENetworker : NSObject

@property (nonatomic, readonly) NSOperationQueue *queue;

- (REAPIOperation *)enqueueRequestable:(id<RERequestable>)aRequest
                            completion:(REAPICompletion)handler;

- (REAPIOperation *)enqueueRequest:(REAPIRequest *)request
                        completion:(REAPICompletion)handler;

@end
