//
//  View.m
//  ALayout
//
//  Created by splendourbell on 2017/4/19.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "ViewManager.h"
#import "UIView+ALayout.h"

@implementation ViewManager
{
    NSMutableDictionary<NSNumber*, UIView*>* _viewRegistry;
}

- (instancetype)init
{
    if(self = [super init])
    {
        _viewRegistry = [NSMutableDictionary new];
    }
    return self;
}

- (ViewToken)createView:(NSDictionary*) attribute
{
    return 0;
}

- (void)removeView:(ViewToken)viewToken
{
    UIView* view = _viewRegistry[@(viewToken)];
    [_viewRegistry removeObjectForKey:@(viewToken)];
    [view removeFromSuperview];
}

- (void)addViewFor:(ViewToken)parentToken subToken:(ViewToken)viewToken
{
    UIView* parentView = _viewRegistry[@(parentToken)];
    UIView* subView = _viewRegistry[@(viewToken)];
    [parentView addSubview:subView];
}

- (void)onMeasure:(ViewToken)viewToken widthSpec:(MeasureSpec)widthSpec heightSpec:(MeasureSpec)heightSpec
{
    UIView* view = _viewRegistry[@(viewToken)];
    [view onMeasure:widthSpec heightSpec:heightSpec];
}

@end
