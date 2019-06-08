//
//  UIControl+Action.h
//  ALayout
//
//  Created by splendourbell on 2018/7/27.
//  Copyright © 2018年 com.aiospace.zone. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ControlEventBlock)(__kindof UIControl* control, UIEvent* event);
@interface UIControl(Action)

- (void)setOnEvent:(ControlEventBlock)onEvent;

- (BOOL)onEvent:(UIControlEvents)controlEvents action:(ControlEventBlock)actionBlock;

@end
