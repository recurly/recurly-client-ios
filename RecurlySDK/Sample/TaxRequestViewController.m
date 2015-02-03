//
//  ViewController.m
//  SampleApp
//
//  Created by Manuel Martinez-Almeida on 10/11/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <RecurlySDK/RecurlySDK.h>
#import "TaxRequestViewController.h"


@implementation TaxRequestViewController

+ (instancetype)createFromNib
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TaxRequestViewController"
                                                         bundle:[NSBundle mainBundle]];
    return [storyboard instantiateInitialViewController];
}


- (IBAction)taxPressed:(id)sender
{
    NSString *postalCode = [_postalCodeField text];
    [Recurly taxForPostalCode:postalCode
                  countryCode:@"US"
                   completion:^(RETaxes *taxes, NSError *error)
    {
        if(!error) {
            NSString *text = [NSString stringWithFormat:@"Total tax: %@%%", [taxes totalTax]];
            [_postalCodeLabel setText:text];
        }else{
            [[Recurly alertViewWithError:error] show];
        }
    }];
}

@end
