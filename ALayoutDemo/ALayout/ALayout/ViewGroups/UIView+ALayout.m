//
//  UIView+ALayout.m
//  ALayout
//
//  Created by splendourbell on 2017/4/19.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import <objc/runtime.h>
#import "UIView+ALayout.h"
#import "MarginLayoutParams.h"
#import "UIView+Params.h"

@interface ViewParams(MeasureSizeFlag)

@property (nonatomic) BOOL hasSetMeasuredSize;

@property (nonatomic, readwrite) CGSize measuredSize;

@end

@implementation UIView(ALayout)

- (__kindof LayoutParams*)generateLayoutParams:(AttributeReader *)attrReader
{
    return [[MarginLayoutParams alloc] initWithAttr:attrReader];
}

- (void)onMeasure:(MeasureSpec)widthSpec heightSpec:(MeasureSpec)heightSpec
{
    CGFloat defaultWidth  = [self defaultSize:self.suggestedMinimumWidth  measureSpec:widthSpec];
    CGFloat defaultHeight = [self defaultSize:self.suggestedMinimumHeight measureSpec:heightSpec];
    [self setMeasuredDimensionRaw:CGSizeMake(defaultWidth, defaultHeight)];
}

- (CGFloat)suggestedMinimumWidth
{
    return self.viewParams.minSize.width;
}

- (CGFloat)suggestedMinimumHeight
{
    return self.viewParams.minSize.height;
}

- (CGFloat)defaultSize:(CGFloat)size measureSpec:(MeasureSpec)measureSpec
{
    CGFloat result = size;
    
    switch (measureSpec.mode)
    {
        case MeasureSpec_UNSPECIFIED:
            result = size;
            break;
            
        case MeasureSpec_AT_MOST:
        case MeasureSpec_EXACTLY:
            result = measureSpec.size;
            break;
    }
    return result;
}

- (CGFloat)resolveSize:(CGFloat)size measureSpec:(MeasureSpec)measureSpec
{
    CGFloat result;
    switch (measureSpec.mode)
    {
        case MeasureSpec_AT_MOST:
            if (measureSpec.size < size)
            {
                result = measureSpec.size;
            }
            else
            {
                result = size;
            }
            break;
            
        case MeasureSpec_EXACTLY:
            result = measureSpec.size;
            break;
            
        case MeasureSpec_UNSPECIFIED:
        default:
            result = size;
            break;
    }
    return result;
}

- (void)onLayout:(CGRect)rect
{
    
}

- (void)measure:(MeasureSpec)widthMeasureSpec heightSpec:(MeasureSpec)heightMeasureSpec
{
    NSString* uniKey = [NSString stringWithFormat:@"%d%.6f%d%.6f", widthMeasureSpec.mode, widthMeasureSpec.size, heightMeasureSpec.mode, heightMeasureSpec.size];
    
    ViewParams* viewParams = self.viewParams;
    if (viewParams.requestLayout || !viewParams.measureCache[uniKey])
    {
        viewParams.hasSetMeasuredSize = NO;
        [self onMeasure:widthMeasureSpec heightSpec:heightMeasureSpec];
        if(!viewParams.hasSetMeasuredSize)
        {
            NSLog(@"in %@.onMeasure must call setMeasuredDimensionRaw method", self.class);
        }
    }
    else
    {
        [self setMeasuredDimensionRaw:viewParams.measureCache[uniKey].CGSizeValue];
    }
    assert(viewParams.hasSetMeasuredSize);
    viewParams.measureCache[uniKey] = [NSValue valueWithCGSize:viewParams.measuredSize];;
}

- (CGSize)measureWithWidth:(CGFloat)width
{
    CGRect bounds = self.frame;
    bounds.size.width = width;
    bounds.size.height = CGFLOAT_MAX;
    [self measureHierarchyInBounds:bounds];
    return self.viewParams.measuredSize;
}

- (void)measureAndLayoutWithWidth:(CGFloat)width
{
    CGSize size = [self measureWithWidth:width];
    CGRect bounds = self.frame;
    bounds.size = size;
    [self layout:bounds];
}

- (BOOL)isChangedFrame:(CGRect)rect
{
    return !CGRectEqualToRect(rect, self.frame);
}

- (void)layout:(CGRect)rect
{
    ViewParams* viewParams = self.viewParams;
    BOOL changed = [self isChangedFrame:rect];
    if(changed || viewParams.requestLayout)
    {
        if(viewParams.willLayouts)
        {
            for(NSString* key in viewParams.willLayouts)
            {
                viewParams.willLayouts[key](rect);
            }
        }
        
        [self setLayoutedFrame:rect];
        [self onLayout:rect];
        
        if(viewParams.didLayouts)
        {
            for(NSString* key in viewParams.didLayouts)
            {
                viewParams.didLayouts[key](rect);
            }
        }
        viewParams.requestLayout = NO;
    }
}

- (void)setLayoutedFrame:(CGRect)rect
{
    if([self isChangedFrame:rect])
    {
        self.frame = rect;
    }
}

- (void)setMeasuredDimensionRaw:(CGSize)measuredSize
{
    ViewParams* viewParams = self.viewParams;
    viewParams.measuredSize = measuredSize;
    self.viewParams.hasSetMeasuredSize = YES;
}

- (void)requestLayout
{
    ViewParams* viewParams = self.viewParams;
    if(!viewParams.requestLayout)
    {
        viewParams.requestLayout = YES;
        if(self.isRootView)
        {
            [self setNeedsLayout];
        }
        else
        {
            [self.superview requestLayout];
        }
    }
}

@end

@implementation UIView(Root)

static void* KEY_asRootView = &KEY_asRootView;

- (void)asRootView:(BOOL)asRoot
{
    objc_setAssociatedObject(self, KEY_asRootView, @(asRoot), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isRootView
{
    return [objc_getAssociatedObject(self, KEY_asRootView) boolValue];
}

- (UIView*)rootView
{
    if(self.isRootView)
    {
        return self;
    }
    else
    {
        return self.superview.rootView;
    }
}

#pragma mark root measure

- (void)measureHierarchyInBounds:(CGRect)bounds
{
    MeasureSpec widthSpec  = {.size = bounds.size.width,  .mode = MeasureSpec_AT_MOST};
    MeasureSpec heightSpec = {.size = bounds.size.height, .mode = MeasureSpec_AT_MOST};

    if(self.layoutParams)
    {
        [self measureHierarchy:self.layoutParams widthSpec:widthSpec heightSpec:heightSpec];
    }
    else
    {
        LayoutParams* layoutParams = [[LayoutParams alloc] initWithWidth:LayoutParams_WRAP_CONTENT height:LayoutParams_WRAP_CONTENT];
        [self measureHierarchy:layoutParams widthSpec:widthSpec heightSpec:heightSpec];
    }
}

- (void)measureHierarchy:(LayoutParams*)layoutParams widthSpec:(MeasureSpec)widthSpec heightSpec:(MeasureSpec)heightSpec
{
    MeasureSpec childWidthMeasureSpec;
    MeasureSpec childHeightMeasureSpec;
    
    childWidthMeasureSpec  = [self rootMeasureSpec:widthSpec.size  dimension:layoutParams.layout_width];
    childHeightMeasureSpec = [self rootMeasureSpec:heightSpec.size dimension:layoutParams.layout_height];
    
    [self performMeasure:childWidthMeasureSpec heightSpec:childHeightMeasureSpec];
}

- (MeasureSpec)rootMeasureSpec:(CGFloat)size dimension:(CGFloat)rootDimension
{
    MeasureSpec measureSpec;
    
    if(LayoutParams_MATCH_PARENT == rootDimension)
    {
        measureSpec.size = size;
        measureSpec.mode = MeasureSpec_EXACTLY;
    }
    else if(LayoutParams_WRAP_CONTENT == rootDimension)
    {
        measureSpec.size = size;
        measureSpec.mode = MeasureSpec_AT_MOST;
    }
    else
    {
        measureSpec.size = rootDimension;
        measureSpec.mode = MeasureSpec_EXACTLY;
    }
    return measureSpec;
}

- (void)performMeasure:(MeasureSpec)childWidthMeasureSpec heightSpec:(MeasureSpec)childHeightMeasureSpec
{
    [self measure:childWidthMeasureSpec heightSpec:childHeightMeasureSpec];
}

#pragma mark root layout
- (void)layoutHierarchy:(CGRect)rect
{
    [self performLayout:rect];
}

- (void)performLayout:(CGRect)rect
{
    [self layout:rect];
}

- (void)addLayoutContentView:(UIView*)layoutContentView
{
    LayoutParams* layoutParams = layoutContentView.layoutParams;
    if(!layoutParams)
    {
        layoutParams = [[MarginLayoutParams alloc] initWithWidth:LayoutParams_MATCH_PARENT height:LayoutParams_MATCH_PARENT];
    }
    [self addLayoutContentView:layoutContentView layoutParams:layoutParams];
}

- (void)addLayoutContentView:(UIView*)layoutContentView layoutParams:(LayoutParams*)layoutParams
{
    [self.layoutContentView removeFromSuperview];
    layoutContentView.layoutParams = layoutParams;
    if(layoutContentView)
    {
        [self insertSubview:layoutContentView atIndex:0];
    }
    self.layoutContentView = layoutContentView;
    [self asRootView:YES];
}

static void* KEY_layoutContentView = &KEY_layoutContentView;

- (void)setLayoutContentView:(UIView *)layoutContentView
{
    objc_setAssociatedObject(self, KEY_layoutContentView, layoutContentView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView*)layoutContentView
{
    return objc_getAssociatedObject(self, KEY_layoutContentView);
}

static void* KEY_needLayoutViews = &KEY_needLayoutViews;

- (void)addNeedLayoutView:(UIView *)needLayoutView
{
    LayoutParams* layoutParams = needLayoutView.layoutParams;
    if(!layoutParams)
    {
        layoutParams = [[MarginLayoutParams alloc] initWithWidth:LayoutParams_MATCH_PARENT height:LayoutParams_MATCH_PARENT];
    }
    [self addSubview:needLayoutView];
    
    NSHashTable* hashTable = objc_getAssociatedObject(self, KEY_needLayoutViews);
    if(!hashTable)
    {
        hashTable = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:8];
        objc_setAssociatedObject(self, KEY_needLayoutViews, hashTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [hashTable addObject:needLayoutView];
}


- (NSHashTable*)needLayoutViews
{
    return objc_getAssociatedObject(self, KEY_needLayoutViews);
}

- (MeasureSpec)measureSpec:(CGFloat)parentSize layout_size:(CGFloat)layout_size
{
    MeasureSpec sizeSpec  = {.size = parentSize,  .mode = MeasureSpec_AT_MOST};
    
    if(LayoutParams_MATCH_PARENT == layout_size)
    {
        sizeSpec.mode = MeasureSpec_EXACTLY;
        sizeSpec.size = parentSize;
    }
    else if(LayoutParams_WRAP_CONTENT == layout_size)
    {
        sizeSpec.mode = MeasureSpec_AT_MOST;
        sizeSpec.size = parentSize;
    }
    else
    {
        sizeSpec.mode = MeasureSpec_EXACTLY;
        sizeSpec.size = layout_size;
    }
    return sizeSpec;
}

- (void)ALayoutSubviews
{
    [self ALayoutSubviews];
    if(self.isRootView && !self.viewParams.animating)
    {
        [self layoutView:self.layoutContentView];
        [self layout:self.frame];
    }
    
    if(!self.viewParams.animating)
    {
        NSHashTable* hashTable = [self needLayoutViews];
        if(hashTable.count)
        {
            NSArray<UIView*> *allObjects = hashTable.allObjects;
            for(UIView* needLayoutView in allObjects)
            {
                if(needLayoutView.superview != self)
                {
                    [hashTable removeObject:needLayoutView];
                }
                else
                {
                    [self layoutView:needLayoutView];
                }
            }
        }
    }
}

- (void)layoutView:(UIView*)layoutView
{
    CGSize availableLayoutSize = self.bounds.size;
    ViewParams* viewParams = self.viewParams;
    if(viewParams.availableLayoutSize)
    {
        availableLayoutSize = viewParams.availableLayoutSize(availableLayoutSize);
    }
    
    MeasureSpec widthSpec  = {.size = availableLayoutSize.width,  .mode = MeasureSpec_AT_MOST};
    MeasureSpec heightSpec = {.size = availableLayoutSize.height, .mode = MeasureSpec_AT_MOST};
    
    UIEdgeInsets layout_margin = UIEdgeInsetsZero;
    LayoutParams* layoutParams = layoutView.layoutParams;
    if(layoutParams)
    {
        widthSpec  = [self measureSpec:availableLayoutSize.width  layout_size:layoutParams.layout_width];
        heightSpec = [self measureSpec:availableLayoutSize.height layout_size:layoutParams.layout_height];
        
        if([layoutParams isKindOfClass:MarginLayoutParams.class])
        {
            MarginLayoutParams* marginLayoutParams = (MarginLayoutParams*)layoutParams;
            layout_margin = marginLayoutParams.layout_margin;
            CGRect rect;
            rect.origin.x    = layout_margin.left;
            rect.origin.y    = layout_margin.top;
            rect.size.width  = widthSpec.size  - layout_margin.left - layout_margin.right;
            rect.size.height = heightSpec.size - layout_margin.top  - layout_margin.bottom;
            
            widthSpec.size   = MAX(0, rect.size.width);
            heightSpec.size  = MAX(0, rect.size.height);
        }
    }
    [layoutView measureHierarchy:layoutParams widthSpec:widthSpec heightSpec:heightSpec];
    
    ViewParams* layoutContentViewParams = layoutView.viewParams;
    CGSize measuredSize = layoutContentViewParams.measuredSize;
    
    CGRect rect;
    rect.origin.x    = layout_margin.left;
    rect.origin.y    = layout_margin.top;
    rect.size.width  = measuredSize.width;
    rect.size.height = measuredSize.height;

    [layoutView layoutHierarchy:rect];
}

+ (void)load
{
    Method originalMethod = class_getInstanceMethod(self, @selector(layoutSubviews));
    Method swizzledMethod = class_getInstanceMethod(self, @selector(ALayoutSubviews));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

@end

@interface UIWindow(Root)
@end

@implementation UIWindow(Root)

- (void)requestLayout
{
    [self setNeedsLayout];
}

@end
