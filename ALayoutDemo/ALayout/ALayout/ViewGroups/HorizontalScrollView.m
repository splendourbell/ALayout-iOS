//
//  HorizontalScrollView.m
//  ALayout
//
//  Created by bell on 2019/5/6.
//  Copyright © 2019 com.aiospace.zone. All rights reserved.
//

#import "HorizontalScrollView.h"
#import "UIContentScrollView.h"

@implementation HorizontalScrollView

- (void)onLayout:(CGRect)rect
{
    [super onLayout:rect];
    
    UIView* child = self.subviews.firstObject;
    if(Visibility_GONE != child.viewParams.visibility )
    {
        MeasureSpec widthSpec = {.size = MAXFLOAT, .mode = MeasureSpec_AT_MOST};
        MeasureSpec heightSpec = {.size = rect.size.height, .mode = MeasureSpec_EXACTLY};
        [self measureChildWithMargins:child parentWidthSpec:widthSpec widthUsed:0 parentHeightSpec:heightSpec heightUsed:0];
        CGSize size = child.viewParams.measuredSize;
        CGSize contentSize = rect.size;
        contentSize.width = size.width;
        self.contentView.contentSize = contentSize;
        UIEdgeInsets padding = self.viewParams.padding;
        CGRect frame;
        frame.origin.x = padding.left;
        frame.origin.y = padding.right;
        frame.size = size;
        [child layout:frame];
    }
    else
    {
        self.contentView.contentSize = CGSizeZero;
    }
    [self.contentView layout:self.bounds];
}

- (void)addSubview:(UIView *)view
{
    [self.contentView addSubview:view];
    [self requestLayout];
}

- (NSArray<UIView *> *)subviews
{
    return self.contentView.subviews;
}

- (UIScrollView*)contentView
{
    if(!_contentView)
    {
        UIContentScrollView* contentView = [[UIContentScrollView alloc] initWithFrame:self.bounds];
        contentView.showsVerticalScrollIndicator = NO;
        contentView.showsHorizontalScrollIndicator = NO;
        __weak typeof(self) weakSelf = self;
        contentView.viewRemoved = ^(UIView *view) {
            [weakSelf requestLayout];
        };
        _contentView = contentView;
        [super addSubview:_contentView];
    }
    return _contentView;
}

@end
