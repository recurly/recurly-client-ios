//
//  NSString+Foundation_Recurly.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 26/11/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Recurly)

- (unichar)firstCharacter;
- (unichar)lastCharacter;
- (NSString *)stringByTrimmingWhitespaces;
- (NSString *)stringByRemovingOccurrencesOfString:(NSString *)target;

@end

@interface NSMutableDictionary (Recurly)

- (void)setOptionalObject:(id)anObject forKey:(id<NSCopying>)aKey;

@end

@interface NSRegularExpression (Recurly)

- (BOOL)matchesString:(NSString *)str;

@end


@interface NSDecimalNumber (Recurly)

- (BOOL)isNaN;

@end
