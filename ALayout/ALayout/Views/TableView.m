//
//  TableView.m
//  ALayout
//
//  Created by Peak.Liu on 2017/6/21.
//  Copyright © 2017年 com.aiospace.zone. All rights reserved.
//

#import "TableView.h"
#import "Drawable.h"
#import "AViewCreator.h"
#import "UIView+Params.h"

@implementation TableView

RegisterView(TableView)

- (void)parseAttr:(AttributeReader *)attrReader useDefault:(BOOL)useDefault
{
    [super parseAttr:attrReader useDefault:useDefault];

    ATTR_ReadAttrEq(self.bounces,                   A_bounces,                    BOOL, YES);
    ATTR_ReadAttrEq(self.alwaysBounceHorizontal,    A_alwaysBounceHorizontal,     BOOL, NO);
    ATTR_ReadAttrEq(self.alwaysBounceVertical,      A_alwaysBounceVertical,       BOOL, NO);
    ATTR_ReadAttrEq(self.pagingEnabled,             A_pagingEnabled,              BOOL, NO);
    ATTR_ReadAttrEq(self.scrollEnabled,             A_scrollEnabled,              BOOL, YES);
    ATTR_ReadAttrEq(self.showsHorizontalScrollIndicator,    A_showsHorizontalScrollIndicator,   BOOL, NO);
    ATTR_ReadAttrEq(self.showsVerticalScrollIndicator,      A_showsVerticalScrollIndicator,     BOOL, NO);
    ATTR_ReadAttrEq(self.directionalLockEnabled,            A_directionalLockEnabled,           BOOL, NO);
    ATTR_ReadAttrEq(self.estimatedRowHeight,                A_estimatedRowHeight,               Dimension, 0);
    ATTR_ReadAttrEq(self.estimatedSectionHeaderHeight,      A_estimatedSectionHeaderHeight,     Dimension, 0);
    ATTR_ReadAttrEq(self.estimatedSectionFooterHeight,      A_estimatedSectionFooterHeight,     Dimension, 0);
    
    self.estimatedSectionFooterHeight = 0;
    self.estimatedSectionHeaderHeight = 0;
    
    if (ATTR_CanRead(A_textColor))
    {
        NSString* styleString = ATTR_ReadAttr(A_textColor, NSString, @"None");
        if([styleString isEqualToString:@"None"])
        {
            self.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        else
        {
            self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        }
    }
    
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
    
    self.scrollIndicatorInsets = self.contentInset;
    
//    self.contentOffset = CGPointZero;
}


- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
}

- (void)dealloc
{
    [self.viewParams.backgroud detach:self];
}

@end
