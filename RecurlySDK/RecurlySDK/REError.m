//
//  Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "REError.h"
#import "REMacros.h"
#import "Foundation+Recurly.h"


@implementation REError ALLOC_DISABLED

+ (NSError *)errorWithCode:(NSInteger)aCode
               description:(NSString *)aDescription
                    reason:(NSString *)areason
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [userInfo setOptionalObject:aDescription forKey:NSLocalizedDescriptionKey];
    [userInfo setOptionalObject:areason forKey:NSLocalizedFailureReasonErrorKey];

    return [NSError errorWithDomain:REERROR_DOMAIN code:aCode userInfo:userInfo];
}

+ (NSError *)responseIsNotHTTP
{
    static NSError *error = nil;
    ASSIGN_ONCE(error, [self errorWithCode:kREErrorResponseIsNotHTTP
                               description:@"Connection's response is not valid HTTP"
                                    reason:nil]);
    return error;
}

+ (NSError *)unexpectedHTTPResponse
{
    static NSError *error = nil;
    ASSIGN_ONCE(error, [self errorWithCode:kREErrorUnexpectedHTTPResponse
                               description:@"Backend's response was unexpected, the SDK could not parse it"
                                    reason:nil]);
    return error;
}

+ (NSError *)missingPlan
{
    static NSError *error = nil;
    ASSIGN_ONCE(error, [self errorWithCode:kREErrorMissingPlan
                               description:@"Pricing plan is missing"
                                    reason:nil]);
    return error;
}

+ (NSError *)pricingMissing
{
    static NSError *error = nil;
    ASSIGN_ONCE(error, [self errorWithCode:kREErrorPricingMissing
                               description:@"Pricing data is missing"
                                    reason:nil]);
    return error;
}


+ (NSError *)apiOperationCancelled
{
    static NSError *error = nil;
    ASSIGN_ONCE(error, [self errorWithCode:kREErrorAPIOperationCancelled
                               description:@"API operation cancelled"
                                    reason:nil]);
    return error;
}

+ (NSError *)invalidFieldError:(NSString *)field message:(NSString *)message
{
    if(!field) {
        return nil;
    }
    NSString *reason = [NSString stringWithFormat:@"Invalid %@", field];
    if(message == nil) {
        message = [NSString stringWithFormat:@"Invalid %@", field];
    }
    return [self errorWithCode:kREErrorInvalidField description:message reason:reason];
}

+ (NSError *)backendErrorWithDictionary:(NSDictionary *)errorDict statusCode:(NSInteger)statusCode
{
    // TODO
    // remove goto
    NSString *message;
    NSString *reason;
    if(errorDict) {
        message = DYNAMIC_CAST(NSString, errorDict[@"message"]);
        reason = DYNAMIC_CAST(NSString, errorDict[@"code"]);
        if(message && reason) {
            goto end;
        }
    }
    if(statusCode >= 400){
        message = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
        reason = [NSString stringWithFormat:@"Code %ld", (long)statusCode];

    }else{
        return nil;
    }

end:
    return [self errorWithCode:kREErrorBackend description:message reason:reason];
}

@end
