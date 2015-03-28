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
#import "REProtocols.h"


@interface REConfiguration : NSObject <REValidable>

/** Currency standarized code ISO 4217, by default it is "USD" */
@property (atomic, strong) NSString *currency;

/** Public key provided by the Recurly dashboard, there is not a default value for this property
 it must be specified in order to integrate this SDK properly. 
 */
@property (atomic, strong) NSString *publicKey;

/** It sets the base HTTP endpoint for connecting to the recurly's backend.
 @discussion Do not change this value unless you know what you are doing.
 */
@property (atomic, strong) NSString *apiEndpoint;

/** Maximun timeout in seconds when performing requests to the Recurly backend
 */
@property (atomic, assign) NSUInteger timeout;

/** Initializes REConfiguration with the specified public key and the default settings.
 You can use [Recurly configure:] directly.
 */
- (instancetype)initWithPublicKey:(NSString *)aPublicKey NS_DESIGNATED_INITIALIZER;

/** Initialized a REConfiguration with the public key and custom settings
 */
- (instancetype)initWithPublicKey:(NSString *)aPublicKey
                         currency:(NSString *)aCurrency
                      apiEndpoint:(NSString *)apiEndpoint
                          timeout:(NSUInteger)timeout NS_DESIGNATED_INITIALIZER;

@end
