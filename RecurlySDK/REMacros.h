/********************/
/** PRIVATE HEADER **/
/********************/
/*
 * The MIT License
 * Copyright (c) 2014-2015 Recurly, Inc.

 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

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
