//
//  MainViewController.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 04/12/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import "MainViewController.h"
#import "CardPaymentViewController.h"
#import "TaxRequestViewController.h"
#import "CouponViewController.h"
#import "PricingViewController.h"


@implementation MainViewController

- (void)showCardPayment
{
    UIViewController *controller = [CardPaymentViewController createFromNib];
    [[self navigationController] pushViewController:controller animated:YES];
}

- (void)showTaxRequest
{
    UIViewController *controller = [TaxRequestViewController createFromNib];
    [[self navigationController] pushViewController:controller animated:YES];
}

- (void)showCouponRequest
{
    UIViewController *controller = [CouponViewController createFromNib];
    [[self navigationController] pushViewController:controller animated:YES];
}

- (void)showPricingRequest
{
    UIViewController *controller = [PricingViewController createFromNib];
    [[self navigationController] pushViewController:controller animated:YES];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (cell.tag) {
        case 0:
            [self showCardPayment];
            break;
        case 2:
            [self showTaxRequest];
            break;
        case 3:
            [self showCouponRequest];
            break;
        case 4:
            [self showPricingRequest];
            break;
        default:
            break;
    }
}

@end
