//
//  Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

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

#pragma mark -

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
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[_addresses count]];
    [_addresses enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *address = [obj JSONDictionary];
        if([address count] > 0) {
            dict[key] = address;
        }
    }];
    return dict;
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
