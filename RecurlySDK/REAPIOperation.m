/*
 * The MIT License
 * Copyright (c) 2014-2015 Recurly, Inc.

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

#import <Foundation/Foundation.h>
#import "REAPIOperation.h"
#import "REAPIRequest.h"
#import "REAPIResponse.h"
#import "REMacros.h"
#import "REError.h"


#define MAX_PREALLOCATION_BUFFER 65536

@interface REAPIOperation ()
{
    NSURLConnection *_connection;
    NSMutableData *_receivedData;
    NSError *_connectionError;
    NSInteger _statusCode;
}
@end

@implementation REAPIOperation

- (instancetype)initWithRequest:(REAPIRequest *)request completion:(REAPICompletion)handler
{
    NSParameterAssert(request);

    self = [super init];
    if (self) {
        _request = request;
        _completionHandler = handler;
    }
    return self;
}


- (void)main
{
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
        _connectionError = [REError apiOperationCancelled];
        _statusCode = 0;
        _receivedData = nil;
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
    REAPIResponse *response = [self createAPIResponse];
    [self dispatchResponseInMainThread:response];
    [self cleanup];

    if([response error]) {
        RELOGERROR(@"REAPIOperation: %@", [response error]);
    }
    RELOGDEBUG(@"TSAPIOperation: %@", response);
    RELOGINFO(@"TSAPIOperation: End \"%@\" in %.3fs",
              [[_request URL] absoluteString],
              [response responseTime]);
}


- (REAPIResponse *)createAPIResponse
{
    REAPIResponse *response = [[REAPIResponse alloc] initWithRequest:_request statusCode:_statusCode HTTPBody:_receivedData];
    [response setNetworkError:_connectionError];
    return response;
}


- (void)dispatchResponseInMainThread:(REAPIResponse *)response
{
    if(_completionHandler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_completionHandler(response, [response error]);
            self->_completionHandler = nil;
        });
    }
}

- (void)cleanup
{
    _connection = nil;
    _receivedData = nil;
}

@end


@implementation REAPIOperation (Networking)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (_receivedData == nil)
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
    if(httpResponse) {
        long long expectedSize = [httpResponse expectedContentLength];
        [self preallocateBuffer:expectedSize];
        _statusCode = [httpResponse statusCode];
    }else{
        _connectionError = [REError responseIsNotHTTP];
    }
}

- (void)preallocateBuffer:(long long)nuBytes
{
    if(_receivedData == nil && nuBytes > 0 && nuBytes < MAX_PREALLOCATION_BUFFER) {
        _receivedData = [NSMutableData dataWithCapacity:(NSUInteger)nuBytes];
    }
}

@end
