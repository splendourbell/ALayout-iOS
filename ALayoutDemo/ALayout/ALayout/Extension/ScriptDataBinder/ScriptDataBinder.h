//
//  ScriptDataBinder.h
//  ALayout
//
//  Created by splendourbell on 2017/6/1.
//  Copyright © 2017年 com.aiospace.zone. All rights reserved.
//

#import "UIView+DataBinder.h"

@interface ScriptDataBinder : NSObject<DataBinderProtocol>

+ (instancetype)defaultDataBinder;

- (void)addScriptSearchPath:(NSString*)path;

- (void)reset;

- (id)runControlCofigFunction:(NSString *)funcName params:(id)otherParams, ... NS_REQUIRES_NIL_TERMINATION;

@end
