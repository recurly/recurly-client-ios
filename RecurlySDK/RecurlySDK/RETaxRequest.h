//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RecurlySDK/REProtocols.h>


@class REAddress;
@interface RETaxRequest : NSObject <RERequestable, RESerializable>

@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *vatNumber;
@property (nonatomic, strong) NSString *currency;

- (instancetype)initWithAddress:(REAddress *)anAddress;

- (instancetype)initWithPostalCode:(NSString *)postalCode
                           country:(NSString *)country;

@end
