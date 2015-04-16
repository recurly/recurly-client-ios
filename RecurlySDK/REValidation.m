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

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import <Foundation/Foundation.h>
#import "REValidation.h"
#import "REMacros.h"
#import "RECardRequest.h"
#import "Foundation+Recurly.h"


@implementation REValidation

+ (BOOL)validateCountryCode:(NSString *)countryCode
{
    if(countryCode == nil || [countryCode length] != 2) {
        return NO;
    }
    countryCode = [countryCode uppercaseString];
    return [[NSLocale ISOCountryCodes] containsObject:countryCode];
}


+ (BOOL)validateCVV:(NSString *)cvv
{
    if(cvv == nil) {
        return NO;
    }
    static NSRegularExpression *exp = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        exp = REGEX(@"^\\d{3,4}$");
    });
    return [exp matchesString:[cvv stringByTrimmingWhitespaces]];
}


+ (BOOL)validateExpirationMonth:(NSInteger)month year:(NSInteger)year
{
    if(month < 1 || month > 12 || year < 1) {
        return NO;
    }
    year += year < 100 ? 2000 : 0;
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:1];

    NSDate *expirationDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    return [expirationDate timeIntervalSinceNow] > 0;
}


+ (BOOL)validateCardNumber:(NSString *)cardNumber
{
    cardNumber = [RECardRequest parseCardNumber:cardNumber];
    return [self luhnValidation:cardNumber];
}


+ (BOOL)luhnValidation:(NSString *)cardNumber
{
    // https://sites.google.com/site/abapexamples/javascript/luhn-validation
    int ca, sum = 0, mul = 1;
    NSInteger i = (NSInteger)[cardNumber length];

    while (i--) {
        unichar c = [cardNumber characterAtIndex:(NSUInteger)i];
        if(!isdigit(c)) {
            return NO;
        }
        ca = (c-'0') * mul;
        sum += ca - (ca > 9) * 9;
        mul ^= 3;
    }
    return sum % 10 == 0 && sum > 0;
}

@end
