//
//  ViewController.m
//  SampleApp
//
//  Created by Manuel Martinez-Almeida on 10/11/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

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
    card.billingAddress.country = [_countryField textValue];
    card.billingAddress.postalCode = @"94131";

    return card;
}

- (IBAction)subscribePressed:(id)sender
{
    UIView *view = [self loadingView];
    [self.view addSubview:view];

    RECardRequest *req = [self cardRequestFromUI];
    [Recurly tokenWithRequest:req completion:^(NSString *token, NSError *error) {
        [view removeFromSuperview];
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

    // Custom behaviours
    [self configureFormBehaviour];
}


- (void)configureFormBehaviour
{
    // TODO
    // refactor setState:
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

@end
