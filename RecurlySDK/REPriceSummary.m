/*
 * The MIT License
 * Copyright (c) 2014-2015 Recurly, Inc.

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

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "REPriceSummary.h"
#import "RECoupon.h"
#import "REError.h"
#import "REMacros.h"


@implementation REPriceSummary

+ (instancetype)summaryWithTaxRate:(NSDecimalNumber *)taxRate
                          currency:(NSString *)currency
                         planPrice:(NSDecimalNumber *)planPrice
                          setupFee:(NSDecimalNumber *)setupFee
                       addonsPrice:(NSDecimalNumber *)addonsPrice
                            coupon:(RECoupon *)coupon
                             error:(NSError *__autoreleasing*)error
{
    NSParameterAssert(error);
    if(!taxRate || !currency || !planPrice || !setupFee || !addonsPrice) {
        *error = [REError pricingMissing];
        return nil;
    }
    return [[[self class] alloc] initWithTaxRate:taxRate
                                        currency:currency
                                       planPrice:planPrice
                                        setupFee:setupFee
                                     addonsPrice:addonsPrice
                                          coupon:coupon];

}


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
