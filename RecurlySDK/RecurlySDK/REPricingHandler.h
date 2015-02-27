//
//  REPricingSummary.h
//  RecurlySDK
//
//  Created by Peter Hsu on 12/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RecurlySDK/REProtocols.h>


@class RETaxes;
@class REPlan;
@class RECartSummary;
@class RECoupon;
@class REPricingResult;
@interface REPricingHandler  : NSObject
{
    NSMutableDictionary *_addons;
}
@property (nonatomic, weak) id<REPricingHandlerDelegate> delegate;
@property (nonatomic, strong) REPlan *plan;
@property (nonatomic, strong) RECoupon *coupon;
@property (nonatomic, strong) RETaxes *taxes;
@property (nonatomic, strong) NSMutableDictionary *addons;
@property (nonatomic, readonly) NSString *currency;
@property (nonatomic, assign) NSUInteger planCount;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) REPricingResult *lastPricingResult;
@property (nonatomic, assign, getter=isDispachingEnabled) BOOL dispachingEnabled;

- (instancetype)initWithCurrency:(NSString *)currency;
- (void)updateAddon:(NSString *)addonName quantity:(NSUInteger)quantity;

@end
