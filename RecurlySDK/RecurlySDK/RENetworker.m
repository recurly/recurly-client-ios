//
//  Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RENetworker.h"


#define SERIAL_QUEUE 1

@implementation RENetworker

- (instancetype)init
{
    self = [super init];
    if (self) {
        _queue = [[NSOperationQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:SERIAL_QUEUE];
    }
    return self;
}


- (REAPIOperation *)enqueueRequestable:(id<RERequestable>)aRequest
                            completion:(REAPICompletion)handler
{
    NSParameterAssert(aRequest);
    NSParameterAssert(handler);

    NSError *localError = [aRequest validate];
    if(localError) {
        handler(nil, localError);
        return nil;
    }
    REAPIRequest *apiRequest = [aRequest request];
    return [self enqueueRequest:apiRequest completion:handler];
}


- (REAPIOperation *)enqueueRequest:(REAPIRequest *)request
                        completion:(REAPICompletion)handler
{
    NSParameterAssert(request);
    NSParameterAssert(handler);

    REAPIOperation *newOperation = [REAPIOperation operationWithRequest:request completion:handler];
    [_queue addOperation:newOperation];
    return newOperation;
}

@end
