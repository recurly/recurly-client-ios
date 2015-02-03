//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RecurlySDK/REPayment.h>


@interface REValidation : NSObject

+ (BOOL)validateCardNumber:(NSString *)cardNumber;
+ (BOOL)validateCVV:(NSString *)cvv;
+ (BOOL)validateExpirationMonth:(NSInteger)month year:(NSInteger)year;
+ (BOOL)validateCountryCode:(NSString *)countryCode;

@end
