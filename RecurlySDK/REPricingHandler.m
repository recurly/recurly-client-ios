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
#import "REPricingHandler.h"
#import "REAPIHandler.h"
#import "REPlanRequest.h"
#import "RECouponRequest.h"
#import "RETaxRequest.h"
#import "REMacros.h"
#import "REPrivate.h"
#import "RecurlyState.h"
#import "REError.h"


@implementation REPricingHandler

- (instancetype)initWithCurrency:(NSString *)currency
{
    self = [super init];
    if (self) {
        _dispachingEnabled = YES;
        _currency = currency;
        _planCount = 1;
    }
    return self;
}

- (void)setPlan:(REPlan *)aPlan
{
    _plan = aPlan;
    _coupon = nil;
    [self setNeedsUpdate];
}

- (void)setCoupon:(RECoupon *)aCoupon
{
    _coupon = aCoupon;
    [self setNeedsUpdate];
}

- (void)setPlanCount:(NSUInteger)planCount
{
    _planCount = planCount;
    [self setNeedsUpdate];
}


- (void)setTaxes:(RETaxes *)taxes
{
    _taxes = taxes;
    [self setNeedsUpdate];
}


- (void)updateAddon:(NSString *)addonName quantity:(NSUInteger)quantity
{
    if(!_addons) {
        _addons = [NSMutableDictionary dictionary];
    }
    if(quantity > 0) {
        _addons[addonName] = @(quantity);
    }else{
        [_addons removeObjectForKey:addonName];
    }
    [self setNeedsUpdate];
}


- (void)setAddons:(NSMutableDictionary *)addons
{
    _addons = addons;
    [self setNeedsUpdate];
}


- (RECartSummary *)cartSummary
{
    return [[RECartSummary alloc] initWithPlan:_plan
                                     planCount:_planCount
                                        addons:_addons
                                        coupon:_coupon
                                      currency:_currency];
}


#pragma mark - Price calculation

- (void)setNeedsUpdate
{
    RELOGDEBUG(@"REPricing: Calculating new price");

    NSError *error = nil;
    REPriceSummary *now = [self calculateNowWithError:&error];
    if(!now) {
        self.error = error;
        return;
    }
    REPriceSummary *recurrent = [self calculateRecurrentWithError:&error];
    if(!recurrent) {
        self.error = error;
        return;
    }
    self.lastPricingResult = [[REPricingResult alloc] initWithNow:now
                                                        recurrent:recurrent
                                                             cart:[self cartSummary]];
}


- (REPriceSummary *)calculateNowWithError:(NSError * __autoreleasing*)error
{
    return [self calculateSummaryWithSetupFee:[self setupFee] error:error];
}

- (REPriceSummary *)calculateRecurrentWithError:(NSError * __autoreleasing*)error
{
    return [self calculateSummaryWithSetupFee:[NSDecimalNumber zero] error:error];
}

- (REPriceSummary *)calculateSummaryWithSetupFee:(NSDecimalNumber *)fee
                                           error:(NSError * __autoreleasing*)error
{
    NSDecimalNumber *planCost = [self planCostWithError:error];
    if(!planCost) {
        return nil;
    }
    return [REPriceSummary summaryWithTaxRate:[self totalTax]
                                     currency:_currency
                                    planPrice:planCost
                                     setupFee:fee
                                  addonsPrice:[self addonsCost]
                                       coupon:_coupon
                                        error:error];
}


- (NSDecimalNumber *)planCostWithError:(NSError *__autoreleasing*)error
{
    NSParameterAssert(error);
    if(!_plan) {
        *error = [REError errorWithCode:kREErrorMissingPlan
                            description:@"Plan code was not specified"
                                 reason:nil];
        return nil;
    }
    
    REPlanPrice *planPrice = [_plan priceForCurrency:_currency];
    if(!planPrice) {
        NSString *message = [NSString stringWithFormat:@"There is not pricing available for currency: %@", _currency];
        *error = [REError errorWithCode:kREErrorMissingPlan
                            description:message
                                 reason:nil];
        return nil;
    }
    NSDecimalNumber *planCount = [NSDecimalNumber decimalNumberWithDecimal:[@(_planCount) decimalValue]];
    return [[planPrice unitAmount] decimalNumberByMultiplyingBy:planCount];
}


- (NSDecimalNumber *)totalTax
{
    NSDecimalNumber *taxRate = [_taxes totalTax];
    return (taxRate) ? taxRate : [NSDecimalNumber zero];
}


- (NSDecimalNumber *)setupFee
{
    return [[_plan priceForCurrency:_currency] setupFee];
}


- (NSDecimalNumber *)addonsCost
{
    NSDecimalNumber *addonsCost = [NSDecimalNumber zero];
    for(NSString *addonName in _addons) {
        REAddon *addon = [_plan addonForName:addonName];
        if(addon) {
            NSDecimalNumber *quantity = [NSDecimalNumber decimalNumberWithDecimal:[_addons[addonName] decimalValue]];
            NSDecimalNumber *cost = [addon priceForCurrency:_currency];
            if(cost) {
                cost = [cost decimalNumberByMultiplyingBy:quantity];
                addonsCost = [addonsCost decimalNumberByAdding:cost];
            }
        }
    }
    return addonsCost;
}


#pragma mark - Dispatching

- (void)setError:(NSError *)aError
{
    if(aError.code != kREErrorAPIOperationCancelled) {
        _error = aError;
        _lastPricingResult = nil;
        [self dispatchPriceUpdated];
    }
}


- (void)setLastPricingResult:(REPricingResult *)result
{
    _lastPricingResult = result;
    _error = nil;
    [self dispatchPriceUpdated];
}


- (void)dispatchPriceUpdated
{
    if(_dispachingEnabled) {
        __strong id<REPricingHandlerDelegate> delegate = _delegate;
        if(!delegate) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self->_lastPricingResult) {
                [delegate priceDidUpdate:self->_lastPricingResult];
            }else if([delegate respondsToSelector:@selector(priceDidFail:)]) {
                [delegate priceDidFail:self->_error];
            }
        });
    }
}

@end
