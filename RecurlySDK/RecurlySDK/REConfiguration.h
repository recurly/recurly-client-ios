//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RecurlySDK/REProtocols.h>


@interface REConfiguration : NSObject <REValidable>

@property (nonatomic, strong) NSString *currency;
@property (nonatomic, strong) NSString *publicKey;
@property (nonatomic, strong) NSString *apiEndpoint;
@property (nonatomic, assign) NSUInteger timeout;

- (instancetype)initWithPublicKey:(NSString *)aPublicKey NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithPublicKey:(NSString *)aPublicKey
                         currency:(NSString *)aCurrency
                      apiEndpoint:(NSString *)apiEndpoint
                          timeout:(NSUInteger)timeout NS_DESIGNATED_INITIALIZER;

@end
