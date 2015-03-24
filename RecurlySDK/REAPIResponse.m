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
#import "REAPIResponse.h"
#import "REAPIRequest.h"
#import "REAPIUtils.h"
#import "REMacros.h"
#import "REError.h"


@interface REAPIResponse ()
{
    NSTimeInterval _timestamp;
}
@end

@implementation REAPIResponse

- (instancetype)initWithRequest:(REAPIRequest *)request
                     statusCode:(NSInteger)statusCode
                       HTTPBody:(NSData *)receivedData
{
    self = [super init];
    if (self) {
        _request = request;
        _statusCode = statusCode;
        _HTTPBody = receivedData;
        _timestamp = [REAPIUtils timestamp];
        [self parseHTTPBody];
        [self checkForBackendError];
    }
    return self;
}


- (void)parseHTTPBody
{
    if([_HTTPBody length] > 0) {
        NSError *error = nil;
        _JSONObject = [NSJSONSerialization JSONObjectWithData:_HTTPBody options:0 error:&error];
        if(error) {
            _contentError = error;
            _JSONObject = nil;
        }
    }
}


- (void)checkForBackendError
{
    NSDictionary *rootDict = [self JSONDictionary];
    NSDictionary *errorDict = DYNAMIC_CAST(NSDictionary, rootDict[@"error"]);
    _backendError = [REError backendErrorWithDictionary:errorDict statusCode:_statusCode];
}


- (NSDictionary *)JSONDictionary
{
    return DYNAMIC_CAST(NSDictionary, _JSONObject);
}


- (NSArray *)JSONArray
{
    return DYNAMIC_CAST(NSArray, _JSONObject);
}


- (NSError *)error
{
    if(_networkError)
        return _networkError;

    if(_sslError)
        return _sslError;

    if(_backendError)
        return _backendError;

    if(_contentError)
        return _contentError;

    return nil;
}


- (double)responseTime
{
    return (_timestamp-[_request timestamp]);
}


- (NSString *)description
{
    NSString *stringBody = [[NSString alloc] initWithData:_HTTPBody encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"REAPIResponse{\n"
            @"\t-URL: %@\n"
            @"\t-Status code: %ld\n"
            @"\t-HTTP body: %@\n}",
            [[_request URL] absoluteString], (long)_statusCode, stringBody];
}

@end
