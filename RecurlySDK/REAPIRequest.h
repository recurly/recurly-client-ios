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
#import "REProtocols.h"


@interface REAPIRequest : NSMutableURLRequest

@property (nonatomic, readonly) NSTimeInterval timestamp;

/** Creates a GET HTTP request with the specified URL params.
 @param endpoint The relative path
 @param params URL query parameters
 @return nil if the query can not be converted to a URL encoded query.
 */
+ (instancetype)GET:(NSString *)endpoint withQuery:(NSDictionary *)params;

/** Creates a POST HTTP request and the query is serialized as a JSON in the HTTP's body.
 @param endpoint The relative path
 @param params JSON paramaters
 @return nil if the query can not be serialized to JSON.
 */
+ (instancetype)POST:(NSString *)endpoint withJSON:(NSDictionary *)params;

/** Creates a POST HTTP request with the specified body.
 @param endpoint The relative path
 @param data raw data included in the body
 */
+ (instancetype)POST:(NSString *)endpoint withBody:(NSData *)data;


- (instancetype)initWithURL:(NSURL *)endpoint
                     method:(NSString *)method
                       data:(NSData *)data
                    timeout:(NSUInteger)timeout NS_DESIGNATED_INITIALIZER;

@end
