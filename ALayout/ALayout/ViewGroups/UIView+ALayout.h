//
//  UIView+ALayout.h
//  ALayout
//
//  Created by splendourbell on 2017/4/19.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeasureSpec.h"

@class LayoutParams;
@class AttributeReader;

@interface UIView(ALayout)

- (CGFloat)suggestedMinimumWidth;

- (CGFloat)suggestedMinimumHeight;

- (CGFloat)defaultSize:(CGFloat)size measureSpec:(MeasureSpec)measureSpec;

- (__kindof LayoutParams*)generateLayoutParams:(AttributeReader *)attrReader;

//@position
- (void)onMeasure:(MeasureSpec)widthSpec heightSpec:(MeasureSpec)heightSpec;

- (void)onLayout:(CGRect)rect;

- (CGFloat)resolveSize:(CGFloat)size measureSpec:(MeasureSpec)measureSpec;

- (void)setMeasuredDimensionRaw:(CGSize)measuredSize;

- (void)requestLayout;

- (CGSize)measureWithWidth:(CGFloat)width;

- (void)measureAndLayoutWithWidth:(CGFloat)width;

//@private
- (void)measure:(MeasureSpec)widthMeasureSpec heightSpec:(MeasureSpec)heightMeasureSpec;

- (void)layout:(CGRect)rect;

@end

@interface UIView(Root)

@property (nonatomic, readonly) UIView* layoutContentView;

- (void)asRootView:(BOOL)asRoot;

- (BOOL)isRootView;

- (UIView*)rootView;

- (void)addLayoutContentView:(UIView*)layoutContentView;

- (void)addLayoutContentView:(UIView*)layoutContentView layoutParams:(LayoutParams*)layoutParams;

- (void)addNeedLayoutView:(UIView *)needLayoutView;

- (void)measureHierarchyInBounds:(CGRect)bounds;

- (void)measureHierarchy:(LayoutParams*)layoutParams widthSpec:(MeasureSpec)widthSpec heightSpec:(MeasureSpec)heightSpec;

@end

