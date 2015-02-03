//
//  REPlanPricing.m
//  RecurlySDK
//
//  Created by Peter Hsu on 12/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import "REPriceSummary.h"
#import "RECoupon.h"
#import "REMacros.h"


@implementation REPriceSummary

- (instancetype)initWithTaxRate:(NSDecimalNumber *)taxRate
                       currency:(NSString *)currency
                      planPrice:(NSDecimalNumber *)planPrice
                       setupFee:(NSDecimalNumber *)setupFee
                    addonsPrice:(NSDecimalNumber *)addonsPrice
                         coupon:(RECoupon *)coupon
{
    self = [super init];
    if (self) {
        NSParameterAssert(taxRate);
        NSParameterAssert(currency);
        NSParameterAssert(planPrice);
        NSParameterAssert(setupFee);
        NSParameterAssert(addonsPrice);

        _currency = currency;
        _taxRate = taxRate;
        _planPrice = planPrice;
        _setupFee = setupFee;
        _addonsPrice = addonsPrice;
        [self calculateBalanceWithCoupon:coupon];
    }
    return self;
}


- (void)calculateBalanceWithCoupon:(RECoupon *)coupon
{
    NSDecimalNumber *subtotal = _planPrice;
    subtotal = [subtotal decimalNumberByAdding:_addonsPrice];
    subtotal = [subtotal decimalNumberByAdding:_setupFee];

    NSDecimalNumber *discount = nil;
    if(coupon) {
        discount = [coupon discountForSubtotal:subtotal currency:_currency];
        subtotal = [subtotal decimalNumberBySubtracting:_discount];
    }else{
        discount = [NSDecimalNumber zero];
    }

    NSDecimalNumber *tax = [subtotal decimalNumberByMultiplyingBy:_taxRate];
    NSDecimalNumber *total = [subtotal decimalNumberByAdding:tax];

    _subtotal = subtotal;
    _discount = discount;
    _tax = tax;
    _total = total;
}


- (NSString *)localizedWithDecimal:(NSDecimalNumber *)decimal
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setCurrencyCode:_currency];
    return [formatter stringFromNumber:decimal];
}

- (NSString *)localizedSubtotal
{
    return [self localizedWithDecimal:_subtotal];
}

- (NSString *)localizedTotal
{
    return [self localizedWithDecimal:_total];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"REPriceSummary{\n"
            @"\t-Currency code: %@\n"
            @"\t-Plan price: %@\n"
            @"\t-Setup price: %@\n"
            @"\t-Addons price: %@\n"
            @"\t-Discount: %@\n"
            @"\t-Tax rate: %@\n"
            @"\t-Subtotal: %@\n"
            @"\t-Total: %@\n}",
            _currency, _planPrice,
            _setupFee, _addonsPrice,
            _discount, _taxRate,
            _subtotal, _total];
}

@end
