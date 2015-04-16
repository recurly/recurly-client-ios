/********************/
/** PRIVATE HEADER **/
/********************/
/*
 * The MIT License
 * Copyright (c) 2015 Recurly, Inc.

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


@class REAPIRequest;
@interface REAPIResponse : NSObject

@property (nonatomic, readonly) REAPIRequest *request;
@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, readonly) NSData *HTTPBody;
@property (nonatomic, readonly) id JSONObject;

@property (nonatomic, strong) NSError *networkError;
@property (nonatomic, strong) NSError *backendError;
@property (nonatomic, strong) NSError *contentError;
@property (nonatomic, strong) NSError *sslError;

- (instancetype)initWithRequest:(REAPIRequest *)request
                     statusCode:(NSInteger)statusCode
                       HTTPBody:(NSData *)receivedData NS_DESIGNATED_INITIALIZER;

- (NSDictionary *)JSONDictionary;
- (NSArray *)JSONArray;
- (NSError *)error;
- (double)responseTime;

@end
