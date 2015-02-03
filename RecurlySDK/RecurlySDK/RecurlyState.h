//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RecurlySDK/REConfiguration.h>
#import <RecurlySDK/RENetworker.h>


@interface RecurlyState : NSObject

@property (nonatomic, readonly) RENetworker *networker;
@property (atomic, strong) REConfiguration *configuration;

+ (instancetype)sharedInstance;
- (NSString *)version;

@end
