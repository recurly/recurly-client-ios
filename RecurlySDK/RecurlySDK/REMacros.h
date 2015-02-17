//
//  NSObject+D.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 27/10/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// TODO
// disable logging when building in release mode

#pragma mark - Logging

#define RELOGERROR(s, ...)  fprintf(stderr, "Recurly:Error: %s\n", [[NSString stringWithFormat:s, ##__VA_ARGS__] UTF8String] )

#if defined(DEBUG)
#define RELOGDEBUG(s, ...) fprintf(stdout, "Recurly:Debug: %s\n", [[NSString stringWithFormat:s, ##__VA_ARGS__] UTF8String] )
#define RELOGINFO(s, ...) fprintf(stdout, "Recurly:Info: %s\n", [[NSString stringWithFormat:s, ##__VA_ARGS__] UTF8String] )
#else
#define RELOGINFO(...) do{}while(0)
#define RELOGDEBUG(...) do{}while(0)
#endif


#pragma mark - Utilities

#define REGEX(__PATTERN__) ([NSRegularExpression regularExpressionWithPattern:(__PATTERN__) options:0 error:nil])

#define DYNAMIC_CAST(__CLASS__, __OBJ__) ^id(Class __class, id __obj) {\
    return ([__obj isKindOfClass:__class] ? __obj : nil); \
}([__CLASS__ class], (__OBJ__))


#define IS_EMPTY(__OBJ__) (__OBJ__ == nil || [__OBJ__ length]==0)

#define SAFE(__OBJ__) (__OBJ__ == nil ? [NSNull null] : __OBJ__)

#define ASSIGN_ONCE(__variable__, __expression__) { \
    static dispatch_once_t pred = 0; \
    dispatch_once(&pred, ^{ \
        __variable__ = __expression__; \
    });\
}


#define ALLOC_DISABLED \
+ (instancetype)alloc { \
    [NSException raise:@"RENoDefaultConfig" format:@"Allocating an instance of this class is not allowed"]; \
    return nil; \
}
