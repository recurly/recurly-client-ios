//
//  Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "REPricingHandler.h"
#import "REAPIHandler.h"
#import "REPlanRequest.h"
#import "RECouponRequest.h"
#import "RETaxRequest.h"
#import "REMacros.h"
#import "REPrivate.h"
#import "RecurlyState.h"


@implementation REPricingHandler

- (instancetype)init
{
    self = [super init];
    if (self) {
        _currency = [[[RecurlyState sharedInstance] configuration] currency];
        _serialQueue = dispatch_queue_create("com.recurly.mobile.ios.sdk.pricing", NULL);
    }
    return self;
}


- (void)updateAddon:(NSString *)addonName quantity:(NSUInteger)quantity
{
    dispatch_sync(_serialQueue, ^{
        if(!self->_addons) {
            self->_addons = [NSMutableDictionary dictionary];
        }
        self->_addons[addonName] = @(quantity);
        [self setNeedsUpdate];
    });
}


- (void)setPlan:(REPlan *)aPlan
{
    dispatch_sync(_serialQueue, ^{
        self->_plan = aPlan;
        self->_coupon = nil;
        [self setNeedsUpdate];
    });
}

- (void)setCoupon:(RECoupon *)aCoupon
{
    dispatch_sync(_serialQueue, ^{
        self->_coupon = aCoupon;
        [self setNeedsUpdate];
    });
}


- (void)setTaxes:(RETaxes *)taxes
{
    dispatch_sync(_serialQueue, ^{
        self->_taxes = taxes;
        [self setNeedsUpdate];
    });
}

- (void)setAddons:(NSMutableDictionary *)addons
{
    dispatch_sync(_serialQueue, ^{
        self->_addons = addons;
        [self setNeedsUpdate];
    });
}

- (void)setError:(NSError *)aError
{
    _error = aError;
    _lastCartSummary = nil;
    [self dispatchPriceUpdated];
}


- (void)setLastCartSummary:(RECartSummary *)aPrice
{
    _lastCartSummary = aPrice;
    _error = nil;
    [self dispatchPriceUpdated];
}


- (void)dispatchPriceUpdated
{
    __strong id<REPricingHandlerDelegate> delegate = _delegate;
    
    NSAssert(delegate, @"Delegate must be set");
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self->_lastCartSummary) {
            [delegate priceDidUpdate:self->_lastCartSummary];
        }else{
            [delegate priceDidFail:self->_error];
        }
    });
}


#pragma mark - Price calculation

- (void)setNeedsUpdate
{
    const NSTimeInterval dl = 0.1;
    if(!_updateTask) {
        RELOGDEBUG(@"REPricing: Scheduling price recalculation");
        _updateTask = [NSTimer scheduledTimerWithTimeInterval:dl
                                              target:self
                                            selector:@selector(recalculatePrice)
                                            userInfo:nil
                                             repeats:NO];
        [_updateTask setTolerance:1];
    }else{
        RELOGDEBUG(@"REPricing: Rescheduling price recalculation");
        [_updateTask setFireDate:[[NSDate date] dateByAddingTimeInterval:dl]];
    }
}

- (void)recalculatePrice
{
    dispatch_sync(_serialQueue, ^{
        [self->_updateTask invalidate];
        self->_updateTask = nil;
        RELOGDEBUG(@"REPricing: Calculating new price");
        self.lastCartSummary = [[RECartSummary alloc] initWithNow:[self calculateNowSubtotal]
                                                        recurrent:[self calculateRecurrentSubtotal]];
    });
}


- (REPriceSummary *)calculateRecurrentSubtotal
{
    return [[REPriceSummary alloc] initWithTaxRate:[_taxes totalTax]
                                          currency:_currency
                                         planPrice:[self planCost]
                                          setupFee:[NSDecimalNumber zero]
                                       addonsPrice:[self addonsCost]
                                            coupon:_coupon];
}


- (REPriceSummary *)calculateNowSubtotal
{
    return [[REPriceSummary alloc] initWithTaxRate:[_taxes totalTax]
                                          currency:_currency
                                         planPrice:[self planCost]
                                          setupFee:[self setupFee]
                                       addonsPrice:[self addonsCost]
                                            coupon:_coupon];
}


- (NSDecimalNumber *)planCost
{
    REPlanPrice *planPrice = [_plan priceForCurrency:_currency];
    if(!planPrice) {
        return nil;
    }
    NSDecimalNumber *planCount = [NSDecimalNumber decimalNumberWithDecimal:[@(_planCount) decimalValue]];
    return [[planPrice unitAmount] decimalNumberByMultiplyingBy:planCount];
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
            cost = [cost decimalNumberByMultiplyingBy:quantity];
            addonsCost = [addonsCost decimalNumberByAdding:cost];
        }
    }
    return addonsCost;
}

@end
