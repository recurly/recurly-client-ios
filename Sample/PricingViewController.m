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
