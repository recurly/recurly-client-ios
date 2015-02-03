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

#import <Foundation/Foundation.h>
#import "RECardRequest.h"
#import "REAPIRequest.h"
#import "REValidation.h"
#import "REMacros.h"
#import "REError.h"
#import "Foundation+Recurly.h"


@implementation RECardRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.billingAddress = [[REAddress alloc] init];
    }
    return self;
}


- (instancetype)initWithCardNumber:(NSString *)cardNumber
                               CVV:(NSString *)cvv
                             month:(NSInteger)month
                              year:(NSInteger)year
                         firstName:(NSString *)firstName
                          lastName:(NSString *)lastName
                       countryCode:(NSString *)countryCode
{
    self = [self init];
    if (self) {
        _number = cardNumber;
        _cvv = cvv;
        _expirationMonth = month;
        _expirationYear = year;
        REAddress *address = [self billingAddress];
        address.firstName = firstName;
        address.lastName = lastName;
        address.countryCode = countryCode;
    }
    return self;
}


- (REAPIRequest *)request
{
    return  [REAPIRequest requestWithEndpoint:@"/token"
                                       method:@"GET"
                                     URLquery:[self JSONDictionary]];
}


- (NSDictionary *)JSONDictionary
{
    REAddress *address = [self billingAddress];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[address JSONDictionary]];
    [dict setOptionalObject:[RECardRequest parseCardNumber:_number] forKey:@"number"];
    [dict setOptionalObject:_cvv forKey:@"cvv"];
    [dict setOptionalObject:@(_expirationMonth) forKey:@"month"];
    [dict setOptionalObject:@(_expirationYear) forKey:@"year"];
    return dict;
}


- (RECardType)type
{
    return [RECardRequest cardTypeForNumber:_number];
}


- (NSError *)validate
{
    NSError *err = [super validate];
    if(err) {
        return err;
    }
    if(![REValidation validateCardNumber:_number]) {
        return [REError invalidFieldError:@"card number" message:nil];
    }
    if(![REValidation validateCVV:_cvv]) {
        return [REError invalidFieldError:@"cvv" message:nil];
    }
    if(![REValidation validateExpirationMonth:_expirationMonth year:_expirationYear]) {
        return [REError invalidFieldError:@"expiration date" message:nil];
    }
    return nil;
}


#pragma mark - Validation methods

static BOOL shouldSeparateAtIndex(NSUInteger index) {
    return (index > 3 && (index%4) == 0);
}

+ (NSString *)formatCardNumber:(NSString *)cardNumber
{
    cardNumber = [self parseCardNumber:cardNumber];

    NSMutableString *formattedNumber = [NSMutableString stringWithCapacity:[cardNumber length]+4];
    for(NSUInteger i = 0; i < [cardNumber length]; i++) {
        unichar character = [cardNumber characterAtIndex:i];
        if(!isdigit(character)) {
            return cardNumber;
        }
        if(shouldSeparateAtIndex(i)) {
            [formattedNumber appendString:@" "];
        }
        [formattedNumber appendFormat:@"%c", character];
    }
    return formattedNumber;
}


+ (NSDictionary *)cardTypes
{
    static NSDictionary *cardTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cardTypes = @{@(RECardTypeVisa): REGEX(@"^4[0-9]{3}?"),
                      @(RECardTypeMasterCard): REGEX(@"^5[1-5][0-9]{2}"),
                      @(RECardTypeAmericanExpress): REGEX(@"^3[47][0-9]{2}"),
                      @(RECardTypeDinersClub): REGEX(@"^3(?:0[0-5]|[68][0-9])[0-9]"),
                      @(RECardTypeDiscover): REGEX(@"^6(?:011|5[0-9]{2})")};
    });
    return cardTypes;
}


+ (RECardType)cardTypeForNumber:(NSString *)cardNumber
{
    cardNumber = [self parseCardNumber:cardNumber];
    NSDictionary *patterns = [self cardTypes];
    for(NSNumber *cardType in patterns) {
        if([patterns[cardType] matchesString:cardNumber])
            return (RECardType)[cardType integerValue];
    }
    return RECardTypeUnknown;
}


+ (NSString *)parseCardNumber:(NSString *)card
{
    if(!card) {
        return @"";
    }
    card = [card stringByRemovingOccurrencesOfString:@" "];
    card = [card stringByRemovingOccurrencesOfString:@"-"];
    return card;
}

@end
