//
//  ViewController.h
//  SampleApp
//
//  Created by Manuel Martinez-Almeida on 10/11/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TaxRequestViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *postalCodeField;
@property (weak, nonatomic) IBOutlet UILabel *postalCodeLabel;

+ (instancetype)createFromNib;

@end
