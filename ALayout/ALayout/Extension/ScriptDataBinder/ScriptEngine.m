//
//  ScriptEngine.m
//  ALayout
//
//  Created by splendourbell on 2017/6/1.
//  Copyright © 2017年 com.aiospace.zone. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIDevice.h>
#import "ScriptEngine.h"

@interface ScriptEngine()

@property (nonatomic) JSContext* context;

@property (nonatomic) dispatch_queue_t scriptQueue;

@property (nonatomic) JSValue *exception;

@end


#ifdef UseQueue
    #define QueBlock(__code__) dispatch_sync(_scriptQueue, ^{ __code__ })
#else
    #define QueBlock
#endif

@implementation ScriptEngine

- (id)init
{
    if(self = [super init])
    {
        _scriptQueue = dispatch_queue_create("ALayout.ESContext", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (JSContext*)context
{
    if(!_context)
    {
        _context = [[JSContext alloc] init];
        __weak typeof(self) __weakSelf = self;
        _context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            __weakSelf.exception = exception;
            context.exception = nil;
            assert(false);
        };
    }
    return _context;
}

- (BOOL)hasProp:(NSString*)propname
{
    __block BOOL ret = NO;
    QueBlock({
        NSRange range = [propname rangeOfString:@"/"];
        if (range.length > 0) {
            propname = [propname substringFromIndex:range.location + range.length];
        }
        JSValue* retValue = self.context[propname];
        ret = retValue && !retValue.isNull && !retValue.isUndefined;
    });
    return ret;
}

- (BOOL)loadScript:(NSString*)script
{
    
    __block BOOL ret = NO;
    if(script)
    {
        QueBlock({
                 self.exception = nil;
                 [self.context evaluateScript:script];
                 JSValue* exception = self.exception;
                 self.exception = nil;
                 ret = !exception;
                 });
    }
    return ret;
}

- (id)callFunction:(NSString*)function param:(NSArray*)data
{
    __block id retValue = nil;
    NSRange range = [function rangeOfString:@"/"];
    if (range.length > 0) {
        function = [function substringFromIndex:range.location + range.length];
    }
    QueBlock({
        JSValue* jsValue = [self.context[function] callWithArguments:data];
        
        if(jsValue.isObject)
        {
            retValue = jsValue.toObject;
        }
        else if(jsValue.isBoolean)
        {
            retValue = @(jsValue.toBool);
        }
        else if(jsValue.isNumber)
        {
            retValue = jsValue.toNumber;
        }
        else if(jsValue.isString)
        {
            retValue = jsValue.toString;
        }
        else
        {
            retValue = nil;
        }
    });
    return retValue;
}


@end



























