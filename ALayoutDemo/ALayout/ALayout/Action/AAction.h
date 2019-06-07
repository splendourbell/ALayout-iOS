//
//  AAction.h
//  ALayout
//
//  Created by splendourbell on 2018/7/27.
//  Copyright © 2018年 com.aiospace.zone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AAction;

@interface UIControl(DefaultAActon)
- (BOOL)attachAction:(AAction*)aaction withTarget:(id)target forControlEvents:(UIControlEvents)controlEvents;
- (BOOL)detachActionWithTarget:(id)target forControlEvents:(UIControlEvents)controlEvents;
@end

@interface AAction : NSObject
+ (instancetype) actionWithString:(NSString*)string;
@end
