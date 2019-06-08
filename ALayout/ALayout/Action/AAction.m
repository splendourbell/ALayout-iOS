//
//  AAction.m
//  ALayout
//
//  Created by splendourbell on 2018/7/27.
//  Copyright © 2018年 com.aiospace.zone. All rights reserved.
//

#import "AAction.h"
#import <objc/runtime.h>

#define SELECTOR_PREFIX @"@selector/"

@interface AAction()
- (BOOL)isEnabled;
- (BOOL)attachView:(UIControl*)control withTarget:(id)target forControlEvents:(UIControlEvents)controlEvents;
- (BOOL)dettachView:(UIControl*)control withTarget:(id)target forControlEvents:(UIControlEvents)controlEvents;
@end

static void* AActionRuntimeKey = &AActionRuntimeKey;

@implementation UIControl(DefaultAActon)

- (BOOL)attachAction:(AAction*)aaction withTarget:(id)target forControlEvents:(UIControlEvents)controlEvents
{
    BOOL attached = [aaction attachView:self withTarget:target forControlEvents:controlEvents];
    if(attached)
    {
        objc_setAssociatedObject(self, AActionRuntimeKey, aaction, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return attached;
}

- (BOOL)detachActionWithTarget:(id)target forControlEvents:(UIControlEvents)controlEvents
{
    AAction* aaction = objc_getAssociatedObject(self, AActionRuntimeKey);

    BOOL detached = [aaction dettachView:self withTarget:target forControlEvents:controlEvents];
    if(detached)
    {
        objc_setAssociatedObject(self, AActionRuntimeKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return NO;
}

@end


@implementation AAction
{
    SEL _sel;
    BOOL _enabled;
}

+ (instancetype) actionWithString:(NSString*)string
{
    AAction* action = [AAction new];
    [action parseActoin:string];
    return action.isEnabled ? action : nil;
}

- (BOOL)isEnabled;
{
    return _enabled;
}

- (BOOL)parseActoin:(NSString*)string
{
    if([string hasPrefix:SELECTOR_PREFIX])
    {
        return [self parseSelectorAction:string];
    }
    return NO;
}

- (BOOL)parseSelectorAction:(NSString*)selectorString
{
    if([selectorString hasPrefix:SELECTOR_PREFIX])
    {
        selectorString = [selectorString substringFromIndex:SELECTOR_PREFIX.length];
    }
    _sel = NSSelectorFromString(selectorString);
    if(_sel)
    {
        _enabled = YES;
    }
    return _enabled;
}

- (BOOL)attachView:(UIControl*)control withTarget:(id)target forControlEvents:(UIControlEvents)controlEvents
{
    if(self.isEnabled && target && control)
    {
        if([target respondsToSelector:_sel]) {
            [control addTarget:target action:_sel forControlEvents:controlEvents];
            return YES;
        } else {
            //#ifdef DEBUG
            NSLog(@"%@ can not respondsToSelector %@", control, NSStringFromSelector(_sel));
            //#endif
        }
    }
    return NO;
}

- (BOOL)dettachView:(UIControl*)control withTarget:(id)target forControlEvents:(UIControlEvents)controlEvents
{
    if(self.isEnabled)
    {
        [control removeTarget:target action:_sel forControlEvents:UIControlEventTouchUpInside];
        return YES;
    }
    return NO;
}

@end
