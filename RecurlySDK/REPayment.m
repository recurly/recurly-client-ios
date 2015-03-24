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
#import "REPayment.h"
#import "REError.h"


#define BILLING_ADDRESS @"billing_address"
#define SHIPPING_ADDRESS @"shipping_address"

@interface REPayment ()
{
    NSMutableDictionary *_addresses;
}
@end

@implementation REPayment
@dynamic billingAddress;
@dynamic shippingAddress;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _addresses = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    return self;
}

- (void)setAddress:(REAddress *)anAddress forType:(NSString *)addressType
{
    [_addresses setValue:anAddress forKey:addressType];
}

- (void)setBillingAddress:(REAddress *)anAddress
{
    [self setAddress:anAddress forType:BILLING_ADDRESS];
}

- (void)setShippingAddress:(REAddress *)anAddress
{
    [self setAddress:anAddress forType:SHIPPING_ADDRESS];
}

- (REAddress *)addressForType:(NSString *)addressType
{
    return _addresses[addressType];
}

- (REAddress *)billingAddress
{
    return [self addressForType:BILLING_ADDRESS];
}

- (REAddress *)shippingAddress
{
    return [self addressForType:SHIPPING_ADDRESS];
}

- (NSDictionary *)paymentPayload
{
    [NSException raise:@"RecurlyNotImplemented" format:@"Override this method"];
    return nil;
}

- (REAPIRequest *)request
{
    [NSException raise:@"RecurlyNotImplemented" format:@"Override this method"];
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    return @{@"addresses": [self addressesDict],
             @"payment_payload": [self paymentPayload] };
}

- (NSDictionary *)addressesDict
{
    NSMutableDictionary *output = [NSMutableDictionary dictionaryWithCapacity:[_addresses count]];
    [_addresses enumerateKeysAndObjectsUsingBlock:^(id type, id address, BOOL *stop) {
        NSDictionary *addressDict = [address JSONDictionary];
        if([addressDict count] > 0) {
            output[type] = addressDict;
        }
    }];
    return output;
}

- (void)paymentRequest:(void(^)(id<RERequestable> requestData, NSError *err))handler
{
    NSParameterAssert(handler);
    handler(self, nil);
}

- (NSError *)validate
{
    // TODO
    // add unit tests
    return [[self billingAddress] validate];
}

@end
