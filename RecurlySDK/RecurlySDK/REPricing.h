//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RecurlySDK/REProtocols.h>


@class RECartSummary;
@class REPlan;
@class RETaxes;
@class REAddress;
typedef void (^REPricingBlock)(RECartSummary *price, NSError *error);

@interface REPricing : NSObject

@property (nonatomic) NSDictionary *addons;
@property (nonatomic) NSString *couponCode;
@property (nonatomic) NSUInteger planCount;
@property (nonatomic) NSString *countryCode;
@property (nonatomic) NSString *postalCode;
@property (nonatomic) NSString *vatCode;

@property (nonatomic, readonly) NSString *currency;
@property (nonatomic, weak) id<REPricingHandlerDelegate>delegate;

- (instancetype)initWithCurrency:(NSString *)currency;
- (void)setPlanCode:(NSString *)planCode;
- (void)setCountryCode:(NSString *)country;
- (void)setAddress:(REAddress *)anAddress;
- (void)updateAddon:(NSString *)addonName quantity:(NSUInteger)quantity;

@end

