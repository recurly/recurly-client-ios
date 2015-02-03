//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface REAPIUtils : NSObject

+ (NSTimeInterval)timestamp;
+ (NSDecimalNumber *)parseDecimal:(id)obj;
+ (NSNumber *)parseNumber:(id)obj;
+ (NSString *)escape:(NSString *)component;
+ (NSString *)buildQueryString:(NSDictionary *)params;
+ (NSString *)encodeArray:(NSArray *)array key:(NSString *)key;
+ (NSString *)buildURLQuery:(NSString *)baseURL parameters:(NSDictionary *)params;
+ (NSString *)joinPath:(NSString *)firstPart secondPart:(NSString *)secondPart;

@end
