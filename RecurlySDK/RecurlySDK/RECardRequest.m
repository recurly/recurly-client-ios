//
//  Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RECardRequest.h"
#import "REAPIRequest.h"
#import "REValidation.h"
#import "REMacros.h"
#import "REError.h"
#import "Foundation+Recurly.h"


NSString *const RecurlyCardVisa = @"visa";
NSString *const RecurlyCardMasterCard = @"master";
NSString *const RecurlyCardAmericanExpress = @"american_express";
NSString *const RecurlyCardDiscover = @"discover";
NSString *const RecurlyCardDinersClub = @"diners_club";
NSString *const RecurlyCardUnknown = @"unknown";


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
        address.country = countryCode;
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


- (NSString *)type
{
    return [RECardRequest cardTypeForNumber:_number];
}


- (NSError *)validate
{
    NSError *err = [super validate];
    if(err)
        return err;

    if(![REValidation validateCardNumber:_number])
        return [REError invalidFieldError:@"card number" message:nil];

    if(![REValidation validateCVV:_cvv])
        return [REError invalidFieldError:@"cvv" message:nil];

    if(![REValidation validateExpirationMonth:_expirationMonth year:_expirationYear])
        return [REError invalidFieldError:@"expiration date" message:nil];

    return nil;
}


#pragma mark - Validation methods

+ (NSString *)formatCardNumber:(NSString *)cardNumber
{
    cardNumber = [self parseCardNumber:cardNumber];
    NSMutableString *formattedNumber = [NSMutableString stringWithCapacity:[cardNumber length]+1];
    for(NSUInteger i = 0; i < [cardNumber length]; i++) {
        unichar c = [cardNumber characterAtIndex:i];
        if(!isdigit(c)) {
            return cardNumber;
        }
        if([self shouldSeparateAtIndex:i]) {
            [formattedNumber appendString:@" "];
        }
        [formattedNumber appendFormat:@"%c", c];
    }
    return formattedNumber;
}


+ (BOOL)shouldSeparateAtIndex:(NSUInteger)index
{
    return (index > 3 && (index%4) == 0);
}


+ (NSDictionary *)cardTypes
{
    static NSDictionary *cardTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cardTypes = @{RecurlyCardVisa: REGEX(@"^4[0-9]{3}?"),
                      RecurlyCardMasterCard: REGEX(@"^5[1-5][0-9]{2}"),
                      RecurlyCardAmericanExpress: REGEX(@"^3[47][0-9]{2}"),
                      RecurlyCardDinersClub: REGEX(@"^3(?:0[0-5]|[68][0-9])[0-9]"),
                      RecurlyCardDiscover: REGEX(@"^6(?:011|5[0-9]{2})")};
    });
    return cardTypes;
}


+ (NSString *)cardTypeForNumber:(NSString *)cardNumber
{
    cardNumber = [self parseCardNumber:cardNumber];
    if([cardNumber length] < 4) {
        return RecurlyCardUnknown;
    }
    NSDictionary *patterns = [self cardTypes];
    for(NSString *cardType in patterns) {
        if([patterns[cardType] matchesString:cardNumber])
            return cardType;
    }
    return RecurlyCardUnknown;
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
