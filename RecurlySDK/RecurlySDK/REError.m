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
#import "REError.h"
#import "REMacros.h"
#import "Foundation+Recurly.h"


NSString *const RecurlyErrorDomain = @"com.recurly.mobile.ios.sdk";

@implementation REError ALLOC_DISABLED

+ (NSError *)errorWithCode:(NSInteger)aCode
               description:(NSString *)aDescription
                    reason:(NSString *)aReason
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [userInfo setOptionalObject:aDescription forKey:NSLocalizedDescriptionKey];
    [userInfo setOptionalObject:aReason forKey:NSLocalizedFailureReasonErrorKey];

    return [NSError errorWithDomain:RecurlyErrorDomain code:aCode userInfo:userInfo];
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
