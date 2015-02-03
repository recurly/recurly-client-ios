//
//  NSString+Foundation_Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 26/11/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

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


@implementation NSNumber (Recurly)

- (BOOL)isNaN
{
    return [self isEqualToNumber:[NSDecimalNumber notANumber]];
}

@end
