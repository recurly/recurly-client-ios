//
//  AppDelegate.m
//  SampleApp
//
//  Created by Manuel Martinez-Almeida on 10/11/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <RecurlySDK/RecurlySDK.h>
#import "AppDelegate.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)app didFinishLaunchingWithOptions:(NSDictionary *)options
{
    [Recurly configure:@"sc-zBh5Z3Jcto0c3Z6YLGPMFb"]; // Manu's key
    //[Recurly configure:@"sc-30WYXJUzQ852w0kHEYQ7Rw"]; // Peter's key
    return YES;
}

@end
