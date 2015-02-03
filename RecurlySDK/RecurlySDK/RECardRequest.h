//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RecurlySDK/REPayment.h>


extern NSString *const RecurlyCardVisa;
extern NSString *const RecurlyCardMasterCard;
extern NSString *const RecurlyCardAmericanExpress;
extern NSString *const RecurlyCardDiscover;
extern NSString *const RecurlyCardDinersClub;
extern NSString *const RecurlyCardUnknown;

@interface RECardRequest : REPayment

@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *nameOnCard;
@property (nonatomic, strong) NSString *cvv;
@property (nonatomic, assign) NSInteger expirationMonth;
@property (nonatomic, assign) NSInteger expirationYear;

+ (NSString *)cardTypeForNumber:(NSString *)cardNumber;
+ (NSString *)parseCardNumber:(NSString *)card;
+ (NSString *)formatCardNumber:(NSString *)cardNumber;

- (instancetype)initWithCardNumber:(NSString *)cardNumber
                               CVV:(NSString *)cvv
                             month:(NSInteger)month
                              year:(NSInteger)year
                         firstName:(NSString *)firstName
                          lastName:(NSString *)lastName
                       countryCode:(NSString *)countryCode;

- (NSString *)type;

@end
