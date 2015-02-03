//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>
#import <RecurlySDK/REAddress.h>
#import <RecurlySDK/REProtocols.h>


@class RECardRequest;
@class REApplePayRequest;
@interface REPayment : NSObject <REPayable, RERequestable, RESerializable>

- (void)setAddress:(REAddress *)address forType:(NSString *)addressType;
- (void)setBillingAddress:(REAddress *)aAddress;
- (void)setShippingAddress:(REAddress *)aAddress;

- (REAddress *)billingAddress;
- (REAddress *)shippingAddress;
- (REAddress *)addressForType:(NSString *)addressType;

@end
