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
#import <AddressBook/AddressBook.h>
#import "REProtocols.h"


@interface REAddress : NSObject <REValidable, RESerializable>

/** First name */
@property (nonatomic, strong) NSString *firstName;

/** Last name */
@property (nonatomic, strong) NSString *lastName;

/** Company name */
@property (nonatomic, strong) NSString *companyName;

/** VAT code */
@property (nonatomic, strong) NSString *vatCode;

/** Phone number */
@property (nonatomic, strong) NSString *phone;

/** Address line 1 */
@property (nonatomic, strong) NSString *address1;

/** Address line 2 */
@property (nonatomic, strong) NSString *address2;

/** Postal code */
@property (nonatomic, strong) NSString *postalCode;

/** City name */
@property (nonatomic, strong) NSString *city;

/** State */
@property (nonatomic, strong) NSString *state;

/** Country code */
@property (nonatomic, strong) NSString *countryCode;


/** Initializes a REAddress from an AddressBook reference
 @param record AddressBook's record
 */
- (instancetype)initWithABRecord:(ABRecordRef)record NS_DESIGNATED_INITIALIZER;

@end
