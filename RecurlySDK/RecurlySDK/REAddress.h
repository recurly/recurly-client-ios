//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <RecurlySDK/REProtocols.h>


@interface REAddress : NSObject <REValidable, RESerializable>

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *companyName;
@property (nonatomic, strong) NSString *vatCode;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *address1;
@property (nonatomic, strong) NSString *address2;
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *country;

- (instancetype)initWithABRecord:(ABRecordRef)record NS_DESIGNATED_INITIALIZER;

@end
