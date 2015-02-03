//
//  Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecurlyState.h"


static RecurlyState *__sharedInstance = nil;

@implementation RecurlyState

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[RecurlyState alloc] init];
    });
    return __sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _networker = [[RENetworker alloc] init];
    }
    return self;
}

- (NSString *)version
{
    // TODO
    // version should not be hardcoded
    return @"3.0.9";
}

@end
