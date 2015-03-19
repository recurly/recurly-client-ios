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

#import <Foundation/Foundation.h>


@class REPricingResult, REAPIRequest;

@protocol REPricingHandlerDelegate <NSObject>
- (void)priceDidUpdate:(REPricingResult *)result;

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
- (instancetype)initWithDictionary:(NSDictionary *)JSONDictionary;

@end


@protocol RERequestable <REValidable>
- (REAPIRequest *)request;

@end


@protocol REPayable <NSObject>
- (void)paymentRequest:(void(^)(id<RERequestable> requestData, NSError *error))handler;

@end
