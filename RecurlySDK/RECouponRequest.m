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
#import "RECouponRequest.h"
#import "REAPIRequest.h"
#import "REMacros.h"
#import "REError.h"
#import "REAPIUtils.h"


@implementation RECouponRequest

- (instancetype)initWithPlanCode:(NSString *)plan couponCode:(NSString *)coupon
{
    self = [super init];
    if (self) {
        _planCode = plan;
        _couponCode = coupon;
    }
    return self;
}


- (REAPIRequest *)request
{
    NSString *escapedPlan = [REAPIUtils escape:_planCode];
    NSString *escapedCoupon = [REAPIUtils escape:_couponCode];
    NSString *url = [NSString stringWithFormat:@"/plans/%@/coupons/%@", escapedPlan, escapedCoupon];
    return [REAPIRequest GET:url withQuery:nil];
}


- (NSError *)validate
{
    if(IS_EMPTY(_planCode)) {
        return [REError invalidFieldError:@"plan code" message:nil];
    }
    if(IS_EMPTY(_couponCode)) {
        return [REError invalidFieldError:@"coupon code" message:nil];
    }
    return nil;
}

@end
