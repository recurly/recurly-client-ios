//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>



@class RECartSummary;
@protocol REPricingHandlerDelegate <NSObject>

- (void)priceDidUpdate:(RECartSummary *)summary;

@optional
- (void)priceDidFail:(NSError *)error;

@end


@protocol REValidable <NSObject>

- (NSError *)validate;

@end


@protocol RESerializable <REValidable>

- (NSDictionary *)JSONDictionary;

@end

@protocol REDeserializable

- (id)initWithDictionary:(NSDictionary *)JSONDictionary;

@end

@class REAPIRequest;
@protocol RERequestable <REValidable>

- (REAPIRequest *)request;

@end


@protocol REPayable <NSObject>
- (void)paymentRequest:(void(^)(id<RERequestable> requestData, NSError *err))handler;

@end
