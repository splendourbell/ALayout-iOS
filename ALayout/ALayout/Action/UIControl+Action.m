//
//  UIControl+Action.m
//  ALayout
//
//  Created by splendourbell on 2018/7/27.
//  Copyright © 2018年 com.aiospace.zone. All rights reserved.
//

#import "UIControl+Action.h"
#import <objc/runtime.h>

static const void* Event_Targets = &Event_Targets;

typedef NSMutableArray<ControlEventBlock> TargetArray;
typedef NSMutableDictionary<NSNumber*, TargetArray*> EventTargetsMap;

@implementation UIControl(Action)

- (void)setOnEvent:(ControlEventBlock)onEvent
{
    if(onEvent)
    {
        [self onEvent:UIControlEventTouchUpInside action:onEvent];
    }
}

- (EventTargetsMap*)getEventTargets
{
    EventTargetsMap* targets = objc_getAssociatedObject(self, Event_Targets);
    if(!targets)
    {
        targets = [NSMutableDictionary new];
        objc_setAssociatedObject(self, Event_Targets, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}

- (BOOL)onEvent:(UIControlEvents)controlEvents action:(void(^)(__kindof UIControl* control, UIEvent* event))actionBlock
{
    //未支持 "| 同时多个event1|event2"
    EventTargetsMap* targets = self.getEventTargets;
    TargetArray* targetArray = targets[@(controlEvents)];
    NSLog(@"targetArray.count=%@", @(targetArray.count));
    if(targetArray)
    {
        [targetArray addObject:actionBlock];
        return YES;
    }
    
    targetArray = [NSMutableArray new];
    [targetArray addObject:actionBlock];
    targets[@(controlEvents)] = targetArray;

    #define DefEventCase(EventType) \
        case EventType:\
        {\
            [self addTarget:self action:@selector(EventType:event:) forControlEvents:EventType];\
        }\
        break;

    switch(controlEvents)
    {
        DefEventCase(UIControlEventTouchDown)
        DefEventCase(UIControlEventTouchDownRepeat)
        DefEventCase(UIControlEventTouchDragInside)
        DefEventCase(UIControlEventTouchDragOutside)
        DefEventCase(UIControlEventTouchDragEnter)
        DefEventCase(UIControlEventTouchDragExit)
        DefEventCase(UIControlEventTouchUpInside)
        DefEventCase(UIControlEventTouchUpOutside)
        DefEventCase(UIControlEventTouchCancel)
        DefEventCase(UIControlEventValueChanged)
        DefEventCase(UIControlEventPrimaryActionTriggered)
        DefEventCase(UIControlEventEditingDidBegin)
        DefEventCase(UIControlEventEditingChanged)
        DefEventCase(UIControlEventEditingDidEnd)
        DefEventCase(UIControlEventEditingDidEndOnExit)
        DefEventCase(UIControlEventAllTouchEvents)
        DefEventCase(UIControlEventAllEditingEvents)
        DefEventCase(UIControlEventApplicationReserved)
        DefEventCase(UIControlEventSystemReserved)
        DefEventCase(UIControlEventAllEvents)
        default:
        break;
    }
    #undef DefEventCase
    
    return YES;
}

- (void)postEvent:(UIControlEvents)controlEvents event:(UIEvent *)event
{
    EventTargetsMap* targets = self.getEventTargets;
    TargetArray* targetArray = targets[@(controlEvents)];
    for(ControlEventBlock eventBlock in targetArray)
    {
        eventBlock(self, event);
    }
}

#define DefEventFun(EventType) \
- (void)EventType:(UIControl*)control event:(UIEvent *)event\
{\
    [self postEvent:EventType event:event];\
}

DefEventFun(UIControlEventTouchDown)
DefEventFun(UIControlEventTouchDownRepeat)
DefEventFun(UIControlEventTouchDragInside)
DefEventFun(UIControlEventTouchDragOutside)
DefEventFun(UIControlEventTouchDragEnter)
DefEventFun(UIControlEventTouchDragExit)
DefEventFun(UIControlEventTouchUpInside)
DefEventFun(UIControlEventTouchUpOutside)
DefEventFun(UIControlEventTouchCancel)
DefEventFun(UIControlEventValueChanged)
DefEventFun(UIControlEventPrimaryActionTriggered)
DefEventFun(UIControlEventEditingDidBegin)
DefEventFun(UIControlEventEditingChanged)
DefEventFun(UIControlEventEditingDidEnd)
DefEventFun(UIControlEventEditingDidEndOnExit)
DefEventFun(UIControlEventAllTouchEvents)
DefEventFun(UIControlEventAllEditingEvents)
DefEventFun(UIControlEventApplicationReserved)
DefEventFun(UIControlEventSystemReserved)
DefEventFun(UIControlEventAllEvents)

#undef DefEventFun

@end
