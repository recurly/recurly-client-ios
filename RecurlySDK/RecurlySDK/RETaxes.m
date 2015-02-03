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
#import "RETaxes.h"
#import "REMacros.h"
#import "REAPIUtils.h"


// TODO
// unit tests

@implementation RETax

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        if(![self loadWithDictionary:dict])
            return nil;
    }
    return self;
}


- (BOOL)loadWithDictionary:(NSDictionary *)dict
{
    NSString *type = DYNAMIC_CAST(NSString, dict[@"type"]);
    NSDecimalNumber *rateNumber = [REAPIUtils parseDecimal:dict[@"rate"]];
    if(!type || !rateNumber)
        return NO;

    _region = DYNAMIC_CAST(NSString, dict[@"region"]); //optional
    _type = type;
    _rate = rateNumber;
    return YES;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"RETax {\n"
            @"\t-Type: %@\n"
            @"\t-Rate: %@\n"
            @"\t-Regin: %@\n}",
            _type, _rate, _region];
}

@end


@implementation RETaxes

- (instancetype)initWithArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        if(![self loadWithArray:array])
            return nil;
    }
    return self;
}


- (BOOL)loadWithArray:(NSArray *)array
{
    if(!array) {
        return NO;
    }
    NSMutableArray *taxes = [NSMutableArray arrayWithCapacity:[array count]];
    for(id rawTax in array) {
        NSDictionary *dictTax = DYNAMIC_CAST(NSDictionary, rawTax);
        RETax *tax = [[RETax alloc] initWithDictionary:dictTax];
        if(tax) {
            [taxes addObject:tax];
        }else{
            return NO;
        }
    }
    _taxes = taxes;
    return YES;
}


- (NSDecimalNumber *)totalTax
{
    NSDecimalNumber *finalTax = [NSDecimalNumber one];
    for(RETax *tax in _taxes) {
        NSDecimalNumber *invTax = [[NSDecimalNumber one] decimalNumberBySubtracting:[tax rate]];
        finalTax = [finalTax decimalNumberByMultiplyingBy:invTax];
    }
    return [[NSDecimalNumber one] decimalNumberBySubtracting:finalTax];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"RETaxes {\n"
            @"\t-Total tax rate: %@\n}",
            [self totalTax]];
}

@end
