//
//  RECartSummary.h
//  RecurlySDK
//
//  Created by Peter Hsu on 12/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@class REPriceSummary;
@interface RECartSummary : NSObject

@property (nonatomic, readonly) REPriceSummary *now;
@property (nonatomic, readonly) REPriceSummary *recurrent;

@end
