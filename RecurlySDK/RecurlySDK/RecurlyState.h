//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "REConfiguration.h"


@class RENetworker;
@interface RecurlyState : NSObject

@property (nonatomic, readonly) RENetworker *networker;
@property (atomic, strong) REConfiguration *configuration;

+ (instancetype)sharedInstance;
- (NSString *)version;

@end
