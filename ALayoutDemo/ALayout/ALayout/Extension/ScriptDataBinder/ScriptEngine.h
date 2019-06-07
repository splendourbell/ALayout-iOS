//
//  ScriptEngine.h
//  ALayout
//
//  Created by splendourbell on 2017/6/1.
//  Copyright © 2017年 com.aiospace.zone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScriptEngine : NSObject

- (BOOL)loadScript:(NSString*)script;

- (BOOL)hasProp:(NSString*)propname;

- (id)callFunction:(NSString*)function param:(NSArray*)data;

@end
