//
//  PricingViewController.m
//  RecurlySDK
//
//  Created by Peter Hsu on 12/5/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import "CouponViewController.h"
#import "RecurlySDK.h"
#import "RECoupon.h"

@interface CouponViewController ()

@end

@implementation CouponViewController

+ (instancetype)createFromNib
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CouponViewController"
                                                         bundle:[NSBundle mainBundle]];
    return [storyboard instantiateInitialViewController];
}


- (IBAction)buttonPressed:(id)sender
{
    NSString *planCode = [_planCodeLabel text];
    NSString *couponCode = [_couponCodeField text];
    
    [Recurly couponForPlan:planCode
                      code:couponCode
                completion:^(RECoupon *coupon, NSError *error)
     {
         if(!error) {
             [self handleCoupon:coupon];
         }else{
             [[Recurly alertViewWithError:error] show];
         }
     }];
}


- (void)handleCoupon:(RECoupon *)coupon
{
    NSString *discountInfo;

    if ([coupon.type isEqualToString:RecurlyCouponTypeFixed]) {

        NSMutableArray *discountAmount = [[NSMutableArray alloc] init];
        [coupon.discountAmount enumerateKeysAndObjectsUsingBlock:^(id currency, NSNumber *value, BOOL *stop) {
            NSString *entry = [NSString stringWithFormat:@"%.2f %@", [value floatValue], currency];
            [discountAmount addObject:entry];
        }];

        discountInfo = [discountAmount componentsJoinedByString:@","];

    } else if ([coupon.type isEqualToString:RecurlyCouponTypePercent]) {
        discountInfo = [NSString stringWithFormat:@"%2.1f%%", ([coupon.discountRate floatValue] * 100)];
    }

    NSString *text = [NSString stringWithFormat:@"Discount type: %@\n%@", coupon.type, discountInfo];
    [_discountLabel setText:text];
}

@end
