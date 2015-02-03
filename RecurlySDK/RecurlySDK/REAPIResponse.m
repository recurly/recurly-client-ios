//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

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


- (NSString *)description
{
    NSString *stringBody = [[NSString alloc] initWithData:_HTTPBody encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"REAPIResponse{\n"
            @"\t-URL: %@\n"
            @"\t-Status code: %ld\n"
            @"\t-HTTP body: %@\n}",
            [[_request URL] absoluteString], (long)_statusCode, stringBody];
}


- (double)responseTime
{
    return (_timestamp-[_request timestamp]);
}

@end
