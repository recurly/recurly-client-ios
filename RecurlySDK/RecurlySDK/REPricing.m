//
//  Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

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
    // TODO
    // should be refactored
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

        RECouponRequest *request = [[RECouponRequest alloc] initWithPlan:planName coupon:_couponCode];
        _couponOperation = [REAPIHandler handleCouponRequest:request completion:^(RECoupon *coupon, NSError *error) {
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
    RETaxRequest *request = [[RETaxRequest alloc] initWithPostalCode:_postalCode country:_countryCode];
    request.vatNumber = _vatCode;
    request.currency = [self currency];
    
    _taxesOperation = [REAPIHandler handleTaxRequest:request completion:^(RETaxes *taxes, NSError *error) {
        if(!error) {
            [self->_handler setTaxes:taxes];
        }else{
            [self->_handler setError:error];
        }
    }];
}

- (void)setAddress:(REAddress *)anAddress
{
    _countryCode = anAddress.country;
    _postalCode = anAddress.postalCode;
    _vatCode = anAddress.vatCode;

    [self updateTaxes];
}

@end
