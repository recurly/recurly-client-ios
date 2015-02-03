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
#import "REPlanRequest.h"
#import "REMacros.h"
#import "REAPIRequest.h"
#import "REError.h"
#import "REAPIUtils.h"


@implementation REPlanRequest

- (instancetype)initWithPlanCode:(NSString *)plan
{
    self = [super init];
    if (self) {
        _planCode = plan;
    }
    return self;
}

- (REAPIRequest *)request
{
    NSString *escapedPlan = [REAPIUtils escape:_planCode];
    NSString *endpoint = [NSString stringWithFormat:@"/plans/%@", escapedPlan];
    return [REAPIRequest requestWithEndpoint:endpoint
                                      method:@"GET"
                                    URLquery:nil];
}


- (NSError *)validate
{
    if(IS_EMPTY(_planCode))
        return [REError invalidFieldError:@"plan code" message:nil];

    return nil;
}

@end
