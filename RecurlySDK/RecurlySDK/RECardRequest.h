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

#import <Foundation/Foundation.h>
#import "REPayment.h"


typedef NS_ENUM(NSInteger, RECardType) {
    RECardTypeVisa,
    RECardTypeMasterCard,
    RECardTypeAmericanExpress,
    RECardTypeDiscover,
    RECardTypeDinersClub,
    RECardTypeUnknown,
};

@interface RECardRequest : REPayment

/**  Parses the card number and returns the card type.
 @see RECardType
 */
+ (RECardType)cardTypeForNumber:(NSString *)cardNumber;

/**  Parses the card number removing whitespaces and dashes.
 @discussion Parsing "34  234-34 " returns "3423434"
 */
+ (NSString *)parseCardNumber:(NSString *)card;

/**  Formattes a card number by adding a separator each 4 numbers.
 @discussion Formatting "4111111111111111" returns "4111 1111 1111 1111"
 */
+ (NSString *)formatCardNumber:(NSString *)cardNumber;


@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *nameOnCard;
@property (nonatomic, strong) NSString *cvv;
@property (nonatomic, assign) NSInteger expirationMonth;
@property (nonatomic, assign) NSInteger expirationYear;

- (instancetype)initWithCardNumber:(NSString *)cardNumber
                               CVV:(NSString *)cvv
                             month:(NSInteger)month
                              year:(NSInteger)year
                         firstName:(NSString *)firstName
                          lastName:(NSString *)lastName
                       countryCode:(NSString *)countryCode;

- (RECardType)type;

@end
