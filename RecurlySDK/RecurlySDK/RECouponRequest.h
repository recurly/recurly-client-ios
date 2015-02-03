//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RecurlySDK/REProtocols.h>


@interface RECouponRequest : NSObject <RERequestable>

@property (nonatomic, strong) NSString *plan;
@property (nonatomic, strong) NSString *coupon;

- (instancetype)initWithPlan:(NSString *)plan coupon:(NSString *)coupon NS_DESIGNATED_INITIALIZER;

@end
