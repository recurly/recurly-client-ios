//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define REERROR_DOMAIN @"com.recurly.mobile.ios.sdk"


typedef NS_ENUM(NSInteger, REErrorCode) {
    kREErrorResponseIsNotHTTP,
    kREErrorInvalidField,
    kREErrorBackend,
    kREErrorUnexpectedHTTPResponse,
    kREErrorMissingPlan,
    kREErrorAPIOperationCancelled,
    kREErrorPricingMissing
};

@interface REError : NSObject

+ (NSError *)errorWithCode:(NSInteger)aCode
               description:(NSString *)aDescription
                    reason:(NSString *)areason;
+ (NSError *)invalidFieldError:(NSString *)field message:(NSString *)message;
+ (NSError *)responseIsNotHTTP;
+ (NSError *)unexpectedHTTPResponse;
+ (NSError *)apiOperationCancelled;
+ (NSError *)missingPlan;
+ (NSError *)pricingMissing;
+ (NSError *)backendErrorWithDictionary:(NSDictionary *)errorDict statusCode:(NSInteger)statusCode;

@end
