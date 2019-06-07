////
////  ScrollView.m
////  ALayout
////
////  Created by bell on 2019/4/23.
////  Copyright © 2019 com.aiospace.zone. All rights reserved.
////
//
//#import "ScrollView.h"
//#import "UIView+ALayout.h"
//#import "UIContentScrollView.h"
//#import "AViewCreator.h"
//
//@interface ScrollView()
//
//@property (nonatomic) NSMutableArray<UIView*>* layoutViews;
//
//@end
//
//@implementation ScrollView
//
//RegisterView(ScrollView)
//
//- (void)parseAttr:(AttributeReader *)attrReader useDefault:(BOOL)useDefault
//{
//    [super parseAttr:attrReader useDefault:useDefault];
//    
//    ATTR_ReadAttrEq(self.bounces,                           A_bounces,                      BOOL, YES);
//    ATTR_ReadAttrEq(self.alwaysBounceVertical,              A_alwaysBounceVertical,         BOOL,  NO);
//    ATTR_ReadAttrEq(self.pagingEnabled,                     A_pagingEnabled,                BOOL,  NO);
//    ATTR_ReadAttrEq(self.scrollEnabled,                     A_scrollEnabled,                BOOL, YES);
//    ATTR_ReadAttrEq(self.showsVerticalScrollIndicator,      A_showsVerticalScrollIndicator, BOOL, NO);
//    ATTR_ReadAttrEq(self.directionalLockEnabled,            A_directionalLockEnabled,       BOOL, YES);
//    
//    CGFloat inset = -1;
//    ATTR_ReadAttrEq(inset, A_inset, Dimension, -1);
//    if (inset < 0)
//    {
//        UIEdgeInsets e = UIEdgeInsetsZero;
//        ATTR_ReadAttrEq(e.left,     A_insetLeft,      Dimension, 0);
//        ATTR_ReadAttrEq(e.top,      A_insetTop,       Dimension, 0);
//        ATTR_ReadAttrEq(e.right,    A_insetRight,     Dimension, 0);
//        ATTR_ReadAttrEq(e.bottom ,  A_insetBotton,    Dimension, 0);
//        self.contentInset = e;
//    }
//    else
//    {
//        self.contentInset = UIEdgeInsetsMake(inset, inset, inset, inset);
//    }
//}
//
//- (void)onMeasure:(MeasureSpec)widthSpec heightSpec:(MeasureSpec)heightSpec
//{
//    MeasureSpec contentWidthSpec = widthSpec;
//    MeasureSpec contentHeightSpect = heightSpec;
//    contentWidthSpec.mode = MeasureSpec_AT_MOST;
//    contentWidthSpec.size = MAXFLOAT;
//    
//    contentHeightSpect.mode = MeasureSpec_AT_MOST;
//    contentHeightSpect.size = MAXFLOAT;
//    
//    [super onMeasure:contentWidthSpec heightSpec:contentHeightSpect];
//    
//    CGFloat defaultWidth  = [self defaultSize:self.suggestedMinimumWidth  measureSpec:widthSpec];
//    CGFloat defaultHeight = [self defaultSize:self.suggestedMinimumHeight measureSpec:heightSpec];
//    [self setMeasuredDimensionRaw:CGSizeMake(defaultWidth, defaultHeight)];
//}
//
//- (void)onLayout:(CGRect)rect
//{
//    UIScrollView *scrollView                  = self.contentView;
//    scrollView.contentInset                   = self.contentInset;
//    scrollView.scrollIndicatorInsets          = self.contentInset;
//    scrollView.bounces                        = self.bounces;
//    scrollView.alwaysBounceVertical           = self.alwaysBounceVertical;
//    scrollView.pagingEnabled                  = self.pagingEnabled;
//    scrollView.scrollEnabled                  = self.scrollEnabled;
//    scrollView.showsVerticalScrollIndicator   = self.showsVerticalScrollIndicator;
//    scrollView.directionalLockEnabled         = self.directionalLockEnabled;
//    
//    [super onLayout:rect];
//    
//    [self.contentView layout:self.bounds];
//    
//    if (_contentInset.top > 1 && fabs(scrollView.contentOffset.x) < 0.01)
//    {
//        [scrollView setContentOffset:CGPointMake(0, 0 - _contentInset.top) animated:false];
//    }
//    
//    NSArray<UIView*>* subviews = scrollView.subviews;
//    CGSize contentSize = CGSizeZero;
//    for(UIView* subView in subviews)
//    {
//        CGRect subFrame = subView.frame;
//        contentSize.height = MAX(contentSize.height, CGRectGetMaxY(subFrame));
//        contentSize.width  = MAX(contentSize.width, CGRectGetMaxX(subFrame));
//    }
//    scrollView.contentSize = contentSize;
//}
//
//- (UIScrollView*)contentView
//{
//    if(!_contentView)
//    {
//        UIContentScrollView* contentView = [[UIContentScrollView alloc] initWithFrame:self.bounds];
//        contentView.showsVerticalScrollIndicator = NO;
//        contentView.showsHorizontalScrollIndicator = NO;
//        __weak typeof(self) weakSelf = self;
//        contentView.viewRemoved = ^(UIView *view) {
//            [weakSelf.layoutViews removeObject:view];
//            [weakSelf requestLayout];
//        };
//        _contentView = contentView;
//        [super addSubview:_contentView];
//    }
//    return _contentView;
//}
//
//- (void)addSubview:(UIView *)view
//{
//    [self.contentView addSubview:view];
//    [self.layoutViews addObject:view];
//    [self requestLayout];
//}
//
//- (NSArray<UIView *> *)subviews
//{
//    return self.contentView.subviews;
//}
//
//- (NSMutableArray<UIView*>*)layoutViews
//{
//    if(!_layoutViews)
//    {
//        _layoutViews = [NSMutableArray array];
//    }
//    return _layoutViews;
//}
//
//@end
