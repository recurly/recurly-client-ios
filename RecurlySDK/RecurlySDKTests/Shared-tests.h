//
//  REConfiguration-tests.m
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 28/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <AddressBook/AddressBook.h>
#import <RecurlySDK/RecurlySDK.h>


#define XCTAssertJSONSerializable(__OBJ__) XCTAssertTrue([NSJSONSerialization isValidJSONObject:__OBJ__])

REAddress *validAddress(void);
ABRecordRef validABRecordWithAddress(void);
ABRecordRef validABRecord(void);
