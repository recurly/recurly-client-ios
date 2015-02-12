//
//  Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "REAPIOperation.h"
#import "REAPIRequest.h"
#import "REAPIResponse.h"
#import "REMacros.h"
#import "REError.h"


@interface REAPIOperation ()
{
    NSURLConnection *_connection;
    NSMutableData *_receivedData;
    NSError *_connectionError;
    NSInteger _statusCode;
}
@end

@implementation REAPIOperation

+ (instancetype)operationWithRequest:(REAPIRequest *)request completion:(REAPICompletion)handler
{
    NSParameterAssert(request);

    REAPIOperation *newOperation = [[REAPIOperation alloc] initWithRequest:request];
    [newOperation setCompletionHandler:handler];
    return newOperation;
}


#pragma mark - Instance methods

- (instancetype)initWithRequest:(REAPIRequest *)request
{
    self = [super init];
    if (self) {
        _request = request;
    }
    return self;
}


- (void)main
{
    NSAssert(_request, @"Request can not be nil");

    @autoreleasepool {
        [self scheduleConnection];
        [self didEnd];
    }
}

- (void)cancel
{
    [super cancel];

    if(_connection) {
        [_connection cancel];
        _connection = nil;
    }
}



- (void)scheduleConnection
{
    RELOGINFO(@"TSAPIOperation: Start \"%@\"", [[_request URL] absoluteString]);
    RELOGDEBUG(@"TSAPIOperation: %@", _request);
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:NO];
    [_connection scheduleInRunLoop:runloop forMode:NSDefaultRunLoopMode];
    [_connection start];
    [runloop run];
}


- (void)didEnd
{
    REAPIResponse *response = [self buildAPIResponse];
    [self dispatchResponseInMainThread:response];

    RELOGDEBUG(@"TSAPIOperation: %@", response);
    RELOGINFO(@"TSAPIOperation: End \"%@\" in %.3fs",
              [[_request URL] absoluteString],
              [response responseTime]);
}


- (REAPIResponse *)buildAPIResponse
{
    REAPIResponse *response;
    if(_connection) {
        response = [[REAPIResponse alloc] initWithRequest:_request statusCode:_statusCode HTTPBody:_receivedData];
        [response setNetworkError:_connectionError];
    }else{
        response = [[REAPIResponse alloc] initWithRequest:_request statusCode:0 HTTPBody:nil];
        [response setNetworkError:[REError apiOperationCancelled]];
    }
    if([response error]) {
        RELOGERROR(@"REAPIOperation: %@", [response error]);
    }
    [self cleanup];
    return response;
}


- (void)dispatchResponseInMainThread:(REAPIResponse *)response
{
    // TODO
    // analyze if this produces a memory leak by circular reference
    if(_completionHandler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_completionHandler(response, [response error]);
            self->_completionHandler = nil;
        });
    }
}

- (void)cleanup
{
    // remove strong references so buffers can be released even so the operation
    // object still exists
    _connection = nil;
    _receivedData = nil;
}

@end


@implementation REAPIOperation (Networking)

#pragma mark NSURLConnection Delegate Implementation

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!_receivedData)
        _receivedData = [data mutableCopy];
    else
        [_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _connectionError = error;
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    return NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = DYNAMIC_CAST(NSHTTPURLResponse, response);
    if(!httpResponse) {
        _connectionError = [REError responseIsNotHTTP];
        return;
    }

    long long expectedSize = [httpResponse expectedContentLength];
    [self reserveMemory:expectedSize];
    _statusCode = [httpResponse statusCode];
}

- (void)reserveMemory:(long long)nuBytes
{
    if(_receivedData == nil && nuBytes > 0 && nuBytes < 20000) {
        _receivedData = [NSMutableData dataWithCapacity:(NSUInteger)nuBytes];
    }
}

@end
