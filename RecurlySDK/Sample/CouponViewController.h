//
//  PricingViewController.h
//  RecurlySDK
//
//  Created by Peter Hsu on 12/5/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CouponViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *planCodeLabel;
@property (weak, nonatomic) IBOutlet UITextField *couponCodeField;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;

+ (instancetype)createFromNib;

@end
