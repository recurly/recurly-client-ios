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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PricingViewController" bundle:nil];
    return [storyboard instantiateInitialViewController];
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

- (void)priceDidUpdate:(REPricingResult *)result
{
    _textBox.text = [result description];
}

- (void)priceDidFail:(NSError *)error
{
    [[Recurly alertViewWithError:error] show];
}


#pragma mark - UI

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
    [_pricing setPostalCode:sender.text];
}
- (IBAction)addsNewAddon:(id)sender
{
    NSString *name = [_addonNameField text];
    NSUInteger quantity = (NSUInteger)[[_addonQuantityField text] integerValue];
    [_pricing updateAddon:name quantity:quantity];
}

@end
