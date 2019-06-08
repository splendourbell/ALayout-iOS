//
//  ScriptDataBinder.m
//  ALayout
//
//  Created by splendourbell on 2017/6/1.
//  Copyright © 2017年 com.aiospace.zone. All rights reserved.
//

#import "ScriptDataBinder.h"
#import "ScriptEngine.h"

@interface ScriptDataBinder()

@property (nonatomic) ScriptEngine* scriptEngine;

@property (nonatomic) NSMutableArray<NSString*>* pathArray;

@end

@implementation ScriptDataBinder

+ (instancetype)defaultDataBinder
{
    static ScriptDataBinder* gScriptDataBinder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gScriptDataBinder = [[ScriptDataBinder alloc] init];
    });
    return gScriptDataBinder;
}

- (void)addScriptSearchPath:(NSString*)path;
{
    if(!_pathArray)
    {
        _pathArray = [[NSMutableArray alloc] init];
    }
    [_pathArray removeAllObjects];
    if(path)
    {
        [_pathArray addObject:path];
        //[self loadScriptFile:[path stringByAppendingPathComponent:@"main"]];
    }
}

- (void)removeAllScriptSearchPath
{
    self.pathArray = nil;
}

- (void)reset
{
    _scriptEngine = nil;
    self.pathArray = nil;
}

- (BOOL)loadScriptFile:(NSString*)filename
{
    BOOL ret = NO;
    NSString* script = nil;
    
    if(![filename.pathExtension isEqualToString:@"js"])
    {
        filename = [filename stringByAppendingPathExtension:@"js"];
    }
    
    if([filename hasPrefix:@"/"])
    {
        script = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:nil];
    }
    else if(filename)
    {
        NSString* fullpath = [self searchScriptFile:filename];
        return [self loadScriptFile:fullpath];
    }
    if(script)
    {
        ret = [self loadScript:script];
    }
    return ret;
}

- (NSString*)searchScriptFile:(NSString*)filename
{
    NSFileManager* fileManager = [NSFileManager defaultManager];    
    for(NSString* path in self.pathArray)
    {
        NSString* fullname = [path stringByAppendingPathComponent:filename];
        if([fileManager fileExistsAtPath:fullname])
        {
            return fullname;
        }
    }
    return nil;
}
        
- (BOOL)loadScript:(NSString*)script
{
    return [self.scriptEngine loadScript:script];
}

- (NSDictionary*)generateBindData:(NSDictionary*)data dataBinder:(NSString*)dataBinder forHeight:(BOOL)forHeight
{
    NSDictionary* retBindData = nil;
    if(dataBinder && data)
    {
        BOOL hasPro = [self.scriptEngine hasProp:dataBinder];
        if(!hasPro)
        {
            [self loadScriptFile:dataBinder];
        }
        hasPro = [self.scriptEngine hasProp:dataBinder];
        if(hasPro)
        {
            retBindData = [self.scriptEngine callFunction:dataBinder param:@[data, @(forHeight)]];
        }
    }
    return retBindData;
}

- (void)loadScriptdataBinder:(NSString *)dataBinder
{
    if (dataBinder)
    {
        BOOL hasPro = [self.scriptEngine hasProp:dataBinder];
        if(!hasPro)
        {
            [self loadScriptFile:dataBinder];
        }
    }
}

- (id)runControlCofigFunction:(NSString *)funcName params:(id)otherParams, ...
{
    NSMutableArray *paramsArr = nil;
    if (otherParams)
    {
        paramsArr = [NSMutableArray array];
        
        va_list argList;
        va_start(argList, otherParams);
        id arg;
        while ((arg = va_arg(argList, id)))
        {
            [paramsArr addObject:arg];
        }
        va_end(argList);
    }
    
    [self loadScriptFile:@"control_config"];
    
    BOOL hasPro = [self.scriptEngine hasProp:funcName];
    if(hasPro)
    {
        return [self.scriptEngine callFunction:funcName param:paramsArr];
    }
    
    return nil;
}

- (ScriptEngine*)scriptEngine
{
    if(!_scriptEngine)
    {
        _scriptEngine = [[ScriptEngine alloc] init];
    }
    return _scriptEngine;
}

@end
