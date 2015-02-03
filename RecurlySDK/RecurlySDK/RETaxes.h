//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "REProtocols.h"


@interface RETax : NSObject

@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *region;
@property (nonatomic, readonly) NSDecimalNumber *rate;

@end


@interface RETaxes : NSObject

@property (nonatomic, readonly) NSArray *taxes;

- (NSDecimalNumber *)totalTax;

@end
