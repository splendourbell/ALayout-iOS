//
//  VerticalScrollView.m
//  ALayout
//
//  Created by Peak.Liu on 2017/6/21.
//  Copyright © 2017年 com.aiospace.zone. All rights reserved.
//

#import "VerticalScrollView.h"

@implementation VerticalScrollView

RegisterView(VerticalScrollView)

- (void)parseAttr:(AttributeReader *)attrReader useDefault:(BOOL)useDefault
{
    [super parseAttr:attrReader useDefault:useDefault];
    
    ATTR_ReadAttrEq(self.bounces,                           A_bounces,                      BOOL, YES);
    ATTR_ReadAttrEq(self.alwaysBounceVertical,              A_alwaysBounceVertical,         BOOL,  NO);
    ATTR_ReadAttrEq(self.pagingEnabled,                     A_pagingEnabled,                BOOL,  NO);
    ATTR_ReadAttrEq(self.scrollEnabled,                     A_scrollEnabled,                BOOL, YES);
    ATTR_ReadAttrEq(self.showsVerticalScrollIndicator,      A_showsVerticalScrollIndicator, BOOL, YES);
    ATTR_ReadAttrEq(self.directionalLockEnabled,            A_directionalLockEnabled,       BOOL, YES);
    
    CGFloat inset = -1;
    ATTR_ReadAttrEq(inset, A_inset, Dimension, -1);
    if (inset < 0)
    {
        UIEdgeInsets e = UIEdgeInsetsZero;
        ATTR_ReadAttrEq(e.left,     A_insetLeft,      Dimension, 0);
        ATTR_ReadAttrEq(e.top,      A_insetTop,       Dimension, 0);
        ATTR_ReadAttrEq(e.right,    A_insetRight,     Dimension, 0);
        ATTR_ReadAttrEq(e.bottom ,  A_insetBotton,    Dimension, 0);
        self.contentInset = e;
    }
    else
    {
        self.contentInset = UIEdgeInsetsMake(inset, inset, inset, inset);
    }
}

- (void)onLayout:(CGRect)rect
{
    UIScrollView *scrollView = self.contentView;
    NSLog(@"%@", scrollView);
    scrollView.contentInset                   = self.contentInset;
    scrollView.scrollIndicatorInsets          = self.contentInset;
    scrollView.bounces                        = self.bounces;
    scrollView.alwaysBounceVertical           = self.alwaysBounceVertical;
    scrollView.pagingEnabled                  = self.pagingEnabled;
    scrollView.scrollEnabled                  = self.scrollEnabled;
    scrollView.showsVerticalScrollIndicator   = self.showsVerticalScrollIndicator;
    scrollView.directionalLockEnabled         = self.directionalLockEnabled;
    
    [super onLayout:rect];
    
    if (_contentInset.top > 1 && fabs(scrollView.contentOffset.x) < 0.01)
    {
        [scrollView setContentOffset:CGPointMake(0, 0 - _contentInset.top) animated:false];
    }
}

@end
