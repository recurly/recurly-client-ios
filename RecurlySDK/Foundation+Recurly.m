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

#import "Foundation+Recurly.h"


@implementation NSString (Recurly)

- (unichar)firstCharacter
{
    return [self characterAtIndex:0];
}

- (unichar)lastCharacter
{
    return [self characterAtIndex:[self length]-1];
}

- (NSString *)stringByTrimmingWhitespaces
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)stringByRemovingOccurrencesOfString:(NSString *)target
{
    return [self stringByReplacingOccurrencesOfString:target withString:@""];
}

@end


@implementation NSMutableDictionary (Recurly)

- (void)setOptionalObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if(anObject) {
        self[aKey] = anObject;
    }
}

@end


@implementation NSRegularExpression (Recurly)

- (BOOL)matchesString:(NSString *)str
{
    return [self numberOfMatchesInString:str options:0 range:NSMakeRange(0, [str length])] == 1;
}

@end


@implementation NSDecimalNumber (Recurly)

- (BOOL)isNaN
{
    return [self isEqualToNumber:[NSDecimalNumber notANumber]];
}

@end
