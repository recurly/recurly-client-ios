//
//  RECartSummary.m
//  RecurlySDK
//
//  Created by Peter Hsu on 12/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import "RECartSummary.h"
#import "REMacros.h"
#import "REPrivate.h"


@implementation RECartSummary

- (instancetype)initWithNow:(REPriceSummary *)now recurrent:(REPriceSummary *)recurrent
{
    self = [super init];
    if (self) {
        _now = now;
        _recurrent = recurrent;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"RECartSummary{\n"
            @"\t-Now: %@\n"
            @"\t-Recurrent: %@\n}",
            _now, _recurrent];
}

@end
