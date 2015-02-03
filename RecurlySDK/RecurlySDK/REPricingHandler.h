//
//  REPricingSummary.h
//  RecurlySDK
//
//  Created by Peter Hsu on 12/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@class RETaxes;
@class REPlan;
@class RECartSummary;
@class RECoupon;

@protocol REPricingHandlerDelegate <NSObject>

- (void)priceDidUpdate:(RECartSummary *)summary;
- (void)priceDidFail:(NSError *)error;

@end

@interface REPricingHandler  : NSObject
{
    dispatch_queue_t _serialQueue;
    NSTimer *_updateTask;
    NSMutableDictionary *_addons;
}
@property (nonatomic, weak) id<REPricingHandlerDelegate> delegate;
@property (nonatomic, strong) REPlan *plan;
@property (nonatomic, strong) RECoupon *coupon;
@property (nonatomic, strong) RETaxes *taxes;
@property (nonatomic, strong) NSMutableDictionary *addons;
@property (nonatomic, strong) NSString *currency;
@property (nonatomic, assign) NSUInteger planCount;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) RECartSummary *lastCartSummary;

- (void)updateAddon:(NSString *)addonName quantity:(NSUInteger)quantity;

@end
