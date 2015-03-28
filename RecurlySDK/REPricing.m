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
#import "REPricing.h"
#import "REPricingHandler.h"
#import "RECouponRequest.h"
#import "REPlan.h"
#import "REPlanRequest.h"
#import "RETaxRequest.h"
#import "REAddress.h"
#import "REAPIHandler.h"
#import "REError.h"
#import "RecurlyState.h"


@implementation REPricingResult

- (instancetype)initWithNow:(REPriceSummary *)now
                  recurrent:(REPriceSummary *)recurrent
                       cart:(RECartSummary *)cart
{
    self = [super init];
    if (self) {
        _now = now;
        _recurrent = recurrent;
        _cart = cart;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"REPricingResult{\n"
            @"\t-Now: %@\n"
            @"\t-Recurrent: %@\n}",
            _now, _recurrent];
}

@end

@interface REPricing ()
{
    REPricingHandler *_handler;
    NSOperation *_planOperation;
    NSOperation *_couponOperation;
    NSOperation *_taxesOperation;
}
@end


@implementation REPricing
@dynamic currency;
@dynamic planCount;
@dynamic addons;
@dynamic delegate;

- (instancetype)init
{
    NSString *currency = [[[RecurlyState sharedInstance] configuration] currency];
    return [self initWithCurrency:currency];
}

- (instancetype)initWithCurrency:(NSString *)currency
{
    self = [super init];
    if (self) {
        _handler = [[REPricingHandler alloc] initWithCurrency:currency];
    }
    return self;
}

- (void)setDelegate:(id<REPricingHandlerDelegate>) delegate
{
    [_handler setDelegate:delegate];
}
- (id<REPricingHandlerDelegate>)delegate
{
    return [_handler delegate];
}

- (NSString *)currency
{
    return [_handler currency];
}

- (void)setPlanCount:(NSUInteger)planCount
{
    [_handler setPlanCount:planCount];
}
- (NSUInteger)planCount
{
    return [_handler planCount];
}

- (void)setAddons:(NSDictionary *)addons
{
    [_handler setAddons:[addons mutableCopy]];
}
- (NSDictionary *)addons
{
    return [_handler addons];
}
- (void)updateAddon:(NSString *)addonName quantity:(NSUInteger)quantity
{
    [_handler updateAddon:addonName quantity:quantity];
}

- (void)setCouponCode:(NSString *)couponCode
{
    if(_couponOperation) {
        [_couponOperation cancel];
        _couponOperation = nil;
    }

    if(!couponCode) {
        [_handler setCoupon:nil];
        return;
    }
    _couponCode = couponCode;
    NSString *planName = _handler.plan.name;
    if(_couponCode && planName) {

        RECouponRequest *request = [[RECouponRequest alloc] initWithPlanCode:planName couponCode:_couponCode];
        _couponOperation = [REAPIHandler handleCouponRequest:request completion:^(RECoupon *coupon, NSError *error) {
            self->_couponOperation = nil;
            if(!error) {
                [self->_handler setCoupon:coupon];
            }else{
                [self->_handler setError:error];
            }
        }];
    }
}

- (void)setPlanCode:(NSString *)planCode
{
    if(_planOperation) {
        [_planOperation cancel];
        _planOperation = nil;
    }
    REPlanRequest *request = [[REPlanRequest alloc] initWithPlanCode:planCode];
    _planOperation = [REAPIHandler handlePlanRequest:request completion:^(REPlan *plan, NSError *error) {
        self->_planOperation = nil;
        if(!error) {
            [self->_handler setPlan:plan];
            [self setCouponCode:self->_couponCode]; // update coupon
        }else{
            [self->_handler setError:error];
        }
    }];
}

- (void)updateTaxes
{
    if(_taxesOperation) {
        [_taxesOperation cancel];
        _taxesOperation = nil;
    }
    RETaxRequest *request = [[RETaxRequest alloc] initWithPostalCode:_postalCode countryCode:_countryCode];
    request.vatNumber = _vatCode;
    request.currency = [self currency];
    
    _taxesOperation = [REAPIHandler handleTaxRequest:request completion:^(RETaxes *taxes, NSError *error) {
        self->_taxesOperation = nil;
        if(!error) {
            [self->_handler setTaxes:taxes];
        }else{
            [self->_handler setError:error];
        }
    }];
}

- (void)setAddress:(REAddress *)anAddress
{
    _countryCode = anAddress.countryCode;
    _postalCode = anAddress.postalCode;
    _vatCode = anAddress.vatCode;

    [self updateTaxes];
}

@end
