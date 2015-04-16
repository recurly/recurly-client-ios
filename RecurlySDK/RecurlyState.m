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

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import <Foundation/Foundation.h>
#import "RecurlyState.h"
#import "REConfiguration.h"
#import "RENetworker.h"


static RecurlyState *__sharedInstance = nil;


@implementation RecurlyState
@synthesize configuration = _configuration;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[RecurlyState alloc] init];
    });
    return __sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _networker = [[RENetworker alloc] init];
        _configuration = nil;
    }
    return self;
}

- (REConfiguration *)configuration
{
    @synchronized(_configuration) {
        if(!_configuration) {
            [NSException raise:@"RecurlyWasNotInitialized" format:nil];
        }
        return _configuration;
    }
    return nil;
}

- (void)setConfiguration:(REConfiguration *)configuration
{
    @synchronized(_configuration) {
        _configuration = configuration;
    }
}

+ (NSString *)version
{
    return @"3.0.9";
}

+ (double)versionNumber
{
    return 3.0009;
}

@end
