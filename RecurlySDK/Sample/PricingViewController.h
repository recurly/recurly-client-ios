//
//  PricingViewController.h
//  RecurlySDK
//
//  Created by Peter Hsu on 12/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RecurlySDK/RecurlySDK.h>


@interface PricingViewController : UIViewController <REPricingHandlerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textBox;

+ (instancetype)createFromNib;

@end
