//
//  PricingViewController.m
//  RecurlySDK
//
//  Created by Peter Hsu on 12/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <RecurlySDK/RecurlySDK.h>
#import "PricingViewController.h"


@interface PricingViewController ()
{
    REPricing *_pricing;
}
@end


@implementation PricingViewController

+ (instancetype)createFromNib
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PricingViewController"
                                                         bundle:[NSBundle mainBundle]];
    
    PricingViewController *instance = [storyboard instantiateInitialViewController];
    return instance;
}

- (void)initializePricing
{
    _pricing = [Recurly pricing];
    [_pricing setPricingCallback:^(RECartSummary *price, NSError *error) {
        if (!error) {
            NSLog(@"Pricing: %@", price);
        } else {
            [[Recurly alertViewWithError:error] show];
        }
    }];
}

- (void)doSomePricing
{
    if(!_pricing) {
        [self initializePricing];
    }
    NSString *planCode = @"premium";
    //NSString *couponCode = @"promo1234";
    NSString *postalCode = @"93131";
    NSString *countryCode = @"US";
    NSString *vatNumber = nil;


    [_pricing setPlanCode:planCode];
    //[_pricing setCouponCode:couponCode];
    [_pricing setCountryCode:countryCode
                  postalCode:postalCode
                     vatCode:vatNumber];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self doSomePricing];
}

@end
