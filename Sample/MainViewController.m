/*
 * The MIT License
 * Copyright (c) 2015 Recurly, Inc.

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

#import "MainViewController.h"
#import "CardPaymentViewController.h"
#import "TaxRequestViewController.h"
#import "CouponViewController.h"
#import "PricingViewController.h"
#import "PlanViewController.h"


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

- (void)showPlanRequest
{
    UIViewController *controller = [PlanViewController createFromNib];
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
            [self showPlanRequest];
            break;
        case 4:
            [self showCouponRequest];
            break;
        case 5:
            [self showPricingRequest];
            break;
        default:
            break;
    }
}

@end
