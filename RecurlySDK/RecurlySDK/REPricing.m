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


@interface REPricing () <REPricingHandlerDelegate>
{
    REPricingHandler *_handler;
    NSOperation *_planOperation;
    NSOperation *_couponOperation;
    NSOperation *_taxesOperation;
}
@end


@implementation REPricing
@dynamic plan;
@dynamic taxes;
@dynamic currency;
@dynamic planCount;
@dynamic addons;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _handler = [[REPricingHandler alloc] init];
        [_handler setDelegate:self];
    }
    return self;
}

- (void)setPlan:(REPlan *)plan
{
    [_handler setPlan:plan];
}
- (REPlan *)plan
{
    return [_handler plan];
}


- (void)setTaxes:(RETaxes *)taxes
{
    [_handler setTaxes:taxes];
}
- (RETaxes *)taxes
{
    return [_handler taxes];
}


- (void)setCurrency:(NSString *)currency
{
    [_handler setCurrency:currency];
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
    [self cancelOperation:_couponOperation];

    if(!couponCode) {
        [_handler setCoupon:nil];
        return;
    }
    NSString *planName = _handler.plan.name;
    _couponCode = couponCode;
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
    [self cancelOperation:_planOperation];

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

- (void)setCountryCode:(NSString *)country postalCode:(NSString *)postalCode vatCode:(NSString *)vat
{
    [self cancelOperation:_taxesOperation];

    RETaxRequest *request = [[RETaxRequest alloc] initWithPostalCode:postalCode country:country];
    request.vatNumber = vat;
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
    [self setCountryCode:anAddress.country
              postalCode:anAddress.postalCode
                 vatCode:anAddress.vatCode];
}

- (void)cancelOperation:(NSOperation *)operation
{
    if(operation) {
        [operation cancel];
    }
}


#pragma mark REPricingHandlerDelegate protocol

- (void)priceDidFail:(NSError *)error
{
    _pricingCallback(nil, error);
}

- (void)priceDidUpdate:(RECartSummary *)summary
{
    _pricingCallback(summary, nil);
}

@end
