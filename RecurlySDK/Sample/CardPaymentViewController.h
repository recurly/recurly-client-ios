//
//  ViewController.h
//  SampleApp
//
//  Created by Manuel Martinez-Almeida on 10/11/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormFieldViewCell.h"


@interface CardPaymentViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *tokenLabel;
@property (weak, nonatomic) IBOutlet FormFieldViewCell *firstNameField;
@property (weak, nonatomic) IBOutlet FormFieldViewCell *lastNameField;
@property (weak, nonatomic) IBOutlet FormFieldViewCell *countryField;
@property (weak, nonatomic) IBOutlet FormFieldViewCell *numberField;
@property (weak, nonatomic) IBOutlet FormFieldViewCell *cvvField;
@property (weak, nonatomic) IBOutlet FormFieldViewCell *monthField;
@property (weak, nonatomic) IBOutlet FormFieldViewCell *yearField;

+ (instancetype)createFromNib;

@end
