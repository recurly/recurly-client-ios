//
//  REAddon.h
//  RecurlySDK
//
//  Created by Peter Hsu on 12/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "REProtocols.h"


@interface REAddon : NSObject

@property (nonatomic, readonly) NSString *code;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSUInteger quantity;
@property (nonatomic, readonly) NSDictionary *price; // key = currency, value = price

- (NSDecimalNumber *)priceForCurrency:(NSString *)aCurrency;

@end
