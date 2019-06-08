//
//  UIContentScrollView.m
//  ALayout
//
//  Created by bell on 2019/4/23.
//  Copyright © 2019 com.aiospace.zone. All rights reserved.
//

#import "UIContentScrollView.h"
#import "UIView+Params.h"

@implementation UIContentScrollView

- (id)init
{
    if(self = [super init])
    {
        self.directionalLockEnabled = YES;
        self.delaysContentTouches = NO;
    }
    return self;
}

- (void)willRemoveSubview:(UIView *)subview
{
    [super willRemoveSubview:subview];
    if(_viewRemoved)
    {
        _viewRemoved(subview);
    }
}

- (void)onLayout:(CGRect)rect
{
    if(self.contentSize.width <= self.frame.size.width
       && self.contentSize.height <= self.frame.size.height )
    {
        self.scrollEnabled = false;
    }
    else
    {
        self.scrollEnabled = true;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView* view = [super hitTest:point withEvent:event];
    if(!self.viewParams.clickable && self == view)
    {
        view = nil;
    }
    return view;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    [super touchesShouldCancelInContentView:view];
    return YES;
}

@end
