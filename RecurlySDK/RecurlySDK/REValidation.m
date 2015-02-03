//
//  Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "REValidation.h"
#import "REMacros.h"
#import "RECardRequest.h"
#import "Foundation+Recurly.h"


@implementation REValidation

+ (BOOL)validateCountryCode:(NSString *)countryCode
{
    if(!countryCode || [countryCode length] != 2) {
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
    // TODO
    // cache regex pattern
    NSRegularExpression *exp = REGEX(@"^\\d{3,4}$");
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


+ (NSString *)formatCardNumber:(NSString *)cardNumber
{
    // TODO
    // refactor this method
    cardNumber = [RECardRequest parseCardNumber:cardNumber];
    NSMutableString *formattedNumber = [NSMutableString stringWithCapacity:[cardNumber length]+1];
    for(NSUInteger i = 0; i < [cardNumber length]; i++) {
        unichar c = [cardNumber characterAtIndex:i];
        if(!isdigit(c)) {
            return cardNumber;
        }
        if(i>3 && (i%4) == 0)
            [formattedNumber appendString:@" "];

        [formattedNumber appendFormat:@"%c", c];
    }
    return formattedNumber;
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
