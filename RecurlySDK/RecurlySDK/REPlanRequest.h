//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RecurlySDK/REProtocols.h>


// TODO
// add unit tests

@interface REPlanRequest : NSObject <RERequestable>

@property (nonatomic, strong) NSString *plan;

- (instancetype)initWithPlanCode:(NSString *)plan NS_DESIGNATED_INITIALIZER;

@end
