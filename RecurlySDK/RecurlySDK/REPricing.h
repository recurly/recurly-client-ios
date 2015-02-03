//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RECartSummary;
@class REPlan;
@class RETaxes;
@class REAddress;
typedef void (^REPricingBlock)(RECartSummary *price, NSError *error);

@interface REPricing : NSObject

@property (nonatomic, strong) REPlan *plan;
@property (nonatomic, strong) RETaxes *taxes;
@property (nonatomic, strong) NSDictionary *addons;
@property (nonatomic, strong) NSString *currency;
@property (nonatomic, strong) NSString *couponCode;
@property (nonatomic, assign) NSUInteger planCount;
@property (nonatomic, strong) REPricingBlock pricingCallback;

- (void)setPlanCode:(NSString *)planCode;
- (void)setAddress:(REAddress *)anAddress;
- (void)updateAddon:(NSString *)addonName quantity:(NSUInteger)quantity;
- (void)setCountryCode:(NSString *)country postalCode:(NSString *)postalCode vatCode:(NSString *)vat;

@end

