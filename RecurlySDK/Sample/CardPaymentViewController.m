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
#import "CardPaymentViewController.h"


@implementation CardPaymentViewController

+ (instancetype)createFromNib
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CardPaymentViewController" bundle:nil];
    return [storyboard instantiateInitialViewController];
}

- (RECardRequest *)cardRequestFromUI
{
    RECardRequest *card = [RECardRequest new];
    card.number = [_numberField textValue];
    card.cvv = [_cvvField textValue];
    card.expirationMonth = [[_monthField textValue] integerValue];
    card.expirationYear = [[_yearField textValue] integerValue];
    card.billingAddress.firstName = [_firstNameField textValue];
    card.billingAddress.lastName = [_lastNameField textValue];
    card.billingAddress.countryCode = [_countryField textValue];
    card.billingAddress.postalCode = @"94131";

    return card;
}

- (IBAction)subscribePressed:(id)sender
{
    UIView *loadingView = [self loadingView];
    [self.view addSubview:loadingView];

    RECardRequest *req = [self cardRequestFromUI];
    [Recurly tokenWithRequest:req completion:^(NSString *token, NSError *error) {
        [loadingView removeFromSuperview];
        if(!error) {
            [[[UIAlertView alloc] initWithTitle:@"Payment Done"
                                        message:[NSString stringWithFormat:@"Token: %@", token]
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
        }else{
            [[Recurly alertViewWithError:error] show];
        }
    }];
}


#pragma mark - UI stuff

- (UIView *)loadingView
{
    CGRect frame = self.view.bounds;
    UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    [view setFrame:frame];
    [view setUserInteractionEnabled:YES];
    [view setExclusiveTouch:YES];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height/2, frame.size.width, 20)];
    [label setText:@"loading... please wait"];
    [label setTextColor:[UIColor blackColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [view addSubview:label];

    return view;
}

- (IBAction)editingEnded:(id)sender
{
    [sender resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [_firstNameField setFieldName:@"First name"];
    [[_firstNameField textField] setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [_firstNameField setNextTextField:[_lastNameField textField]];

    [_lastNameField setFieldName:@"Last name"];
    [[_lastNameField textField] setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [_lastNameField setNextTextField:[_countryField textField]];

    [_countryField setFieldName:@"Country code"];
    [[_countryField textField] setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
    [_countryField setNextTextField:[_numberField textField]];

    [_numberField setFieldName:@"Card number"];
    [[_numberField textField] setKeyboardType:UIKeyboardTypeNumberPad];
    [_numberField setNextTextField:[_cvvField textField]];

    [_cvvField setFieldName:@"CVV"];
    [[_cvvField textField] setKeyboardType:UIKeyboardTypeNumberPad];
    [_cvvField setNextTextField:[_monthField textField]];

    [_monthField setFieldName:@"Expiration month"];
    [[_monthField textField] setKeyboardType:UIKeyboardTypeNumberPad];
    [_monthField setNextTextField:[_yearField textField]];

    [_yearField setFieldName:@"Expiration year"];
    [[_yearField textField] setKeyboardType:UIKeyboardTypeNumberPad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [_numberField setValueChanged:^BOOL(NSString *newValue){
        NSString *realValue = [RECardRequest formatCardNumber:newValue];
        [_numberField setTextValue:realValue];
        return NO;
    }];

    [_numberField setEditingEnded:^(NSString *value){
        if([REValidation validateCardNumber:value])
            [_numberField setState:1];
        else
            [_numberField setState:2];
    }];


    [_cvvField setEditingEnded:^(NSString *value){
        if([REValidation validateCVV:value])
            [_cvvField setState:1];
        else
            [_cvvField setState:2];
    }];

    [_countryField setEditingEnded:^(NSString *value){
        if([REValidation validateCountryCode:value])
            [_countryField setState:1];
        else
            [_countryField setState:2];
    }];

    [_monthField setEditingEnded:^(NSString *value){
        NSInteger i = [value integerValue];
        if(i >= 1 && i <= 12 ) {
            [_monthField setState:1];
        }else{
            [_monthField setState:2];
        }
    }];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    _monthField.editingEnded = nil;
    _countryField.editingEnded = nil;
    _cvvField.editingEnded = nil;
    _numberField.editingEnded = nil;
    _numberField.valueChanged = nil;
}

@end
