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
#import "REProtocols.h"


@class REAddress;
@interface RETaxRequest : NSObject <RERequestable, RESerializable>

/** Postal code */
@property (nonatomic, strong) NSString *postalCode;

/** Country code */
@property (nonatomic, strong) NSString *countryCode;

/** VAT number */
@property (nonatomic, strong) NSString *vatNumber;

/** Currency */
@property (nonatomic, strong) NSString *currency;


/** Initializes a tax request using an address.
 It takes the postal code, country code and the VAT number from the address object.
 @param anAddress Address object used to populate the tax request (postal, country, vat codes)
 */
- (instancetype)initWithAddress:(REAddress *)anAddress;


/** Initializes a tax request using the postal code and the country code, the currency is the default one.
 @param postalCode Postal code
 @param country
 @see REConfiguration
 */
- (instancetype)initWithPostalCode:(NSString *)postalCode
                       countryCode:(NSString *)country;

@end
