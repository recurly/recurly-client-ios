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

    [[Recurly configuration] setCurrency:@"EUR"];

    PricingViewController *instance = [storyboard instantiateInitialViewController];
    return instance;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _pricing = [Recurly pricing];
        [_pricing setDelegate:self];
    }
    return self;
}

- (IBAction)planCodeChanged:(UITextField *)sender
{
    [_pricing setPlanCode:sender.text];
}
- (IBAction)planCountChanged:(UITextField *)sender
{
    [_pricing setPlanCount:(NSUInteger)[sender.text integerValue]];
}
- (IBAction)couponCodeChanged:(UITextField *)sender
{
    [_pricing setCouponCode:sender.text];
}
- (IBAction)countryCodeChanged:(UITextField *)sender
{
    [_pricing setCountryCode:sender.text];
}
- (IBAction)postalCodeChanged:(UITextField *)sender
{
    [_pricing setCountryCode:sender.text];
}

- (void)priceDidUpdate:(RECartSummary *)summary
{
    _textBox.text = [summary description];
}

@end
