//
//  Recurly.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "REPlanRequest.h"
#import "REMacros.h"
#import "REAPIRequest.h"
#import "REError.h"
#import "REAPIUtils.h"


@implementation REPlanRequest

- (instancetype)initWithPlanCode:(NSString *)plan
{
    self = [super init];
    if (self) {
        _plan = plan;
    }
    return self;
}

- (REAPIRequest *)request
{
    NSString *escapedPlan = [REAPIUtils escape:_plan];
    NSString *endpoint = [NSString stringWithFormat:@"/plans/%@", escapedPlan];
    return [REAPIRequest requestWithEndpoint:endpoint
                                      method:@"GET"
                                    URLquery:nil];
}


- (NSError *)validate
{
    if(IS_EMPTY(_plan))
        return [REError invalidFieldError:@"plan code" message:nil];

    return nil;
}

@end
