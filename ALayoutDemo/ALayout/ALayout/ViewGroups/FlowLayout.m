//
//  FlowLayout.m
//  ALayout
//
//  Created by bell on 2017/6/4.
//  Copyright © 2017年 com.aiospace.zone. All rights reserved.
//

#import "FlowLayout.h"
#import "FlowLayoutParams.h"
#import "UIContentScrollView.h"

@interface FlowLayout()

@property (nonatomic) NSMutableArray<UIView*>* layoutViews;
@property (nonatomic) NSMutableArray<NSNumber*>* rowsHeight;
@property (nonatomic) NSMutableArray<NSNumber*>* rowsWidth;
@property (nonatomic) NSMutableArray<NSMutableArray<UIView*>*>* cooritems;
@property (nonatomic) CGSize contentSize;

@end

@implementation FlowLayout

- (void)addSubview:(UIView *)view
{
    [self.contentView addSubview:view];
    [self.layoutViews addObject:view];
    [self requestLayout];
}

- (NSArray<UIView *> *)subviews
{
    return self.contentView.subviews;
}

- (void)parseAttr:(AttributeReader*)attrReader useDefault:(BOOL)useDefault
{
    [super parseAttr:attrReader useDefault:useDefault];
    ATTR_ReadAttrEq(_gravity, A_gravity, GravityMode, Gravity_LEFT | Gravity_TOP);
    ATTR_ReadAttrEq(_rowGravity, A_rowGravity, GravityMode, Gravity_LEFT);
}

- (LayoutParams*)generateLayoutParams:(AttributeReader *)attrReader
{
    return [[FlowLayoutParams alloc] initWithAttr:attrReader];
}

- (void)onMeasure:(MeasureSpec)widthSpec heightSpec:(MeasureSpec)heightSpec
{
    CGSize size = CGSizeMake(widthSpec.size, heightSpec.size);
    
    [self.rowsWidth removeAllObjects];
    [self.rowsHeight removeAllObjects];
    [self.cooritems removeAllObjects];

    if(MeasureSpec_EXACTLY != widthSpec.mode || MeasureSpec_EXACTLY != heightSpec.mode)
    {
        size = [self calcChild:widthSpec heightSpec:heightSpec size:size];
    }
    
    size.width  = MAX(size.width, self.suggestedMinimumWidth);
    size.height = MAX(size.height, self.suggestedMinimumHeight);
    
    ViewParams* viewParams = self.viewParams;
    CGFloat maxHeight = viewParams.maxSize.height;
    size.height = MIN(size.height, maxHeight);
    [self setMeasuredDimensionRaw:size];
}

- (void)measureChildWithMargins:(UIView*)child
                parentWidthSpec:(MeasureSpec)parentWidthSpec
                      widthUsed:(CGFloat)widthUsed
               parentHeightSpec:(MeasureSpec)parentHeightSpec
                     heightUsed:(CGFloat)heightUsed
{
    ViewParams* viewParams = self.viewParams;
    FlowLayoutParams* lp = (FlowLayoutParams*) child.layoutParams;
    
    CGFloat padding = 0;
    padding += viewParams.padding.left + viewParams.padding.right;
    padding += lp.layout_margin.left + lp.layout_margin.right;
    padding += widthUsed;
    
    MeasureSpec availableWidthSpec = parentWidthSpec;
    
    if(lp.layout_widthPercent > 0 && 0 <= lp.layout_width)
    {
        availableWidthSpec.size = availableWidthSpec.size / 100 * lp.layout_widthPercent;
        if(lp.layout_width == 0)
        {
            lp.layout_width = availableWidthSpec.size;
        }
    }
    
    MeasureSpec childWidthMeasureSpec  = [ViewGroup childMeasureSpec:availableWidthSpec
                                                             padding:padding
                                                      childDimension:lp.layout_width];
    
    padding  = 0;
    padding += viewParams.padding.top + viewParams.padding.bottom;
    padding += lp.layout_margin.top + lp.layout_margin.bottom;
    padding += heightUsed;
    
    MeasureSpec childHeightMeasureSpec = [ViewGroup childMeasureSpec:parentHeightSpec
                                                             padding:padding
                                                      childDimension:lp.layout_height];
    
    [child measure:childWidthMeasureSpec heightSpec:childHeightMeasureSpec];
}

- (CGSize)calcChild:(MeasureSpec)widthSpec heightSpec:(MeasureSpec)heightSpec size:(CGSize)size
{
    NSArray<UIView*>* subviews = self.layoutViews;
    ViewParams* viewParams = self.viewParams;
    UIEdgeInsets padding = viewParams.padding;
    
    CGFloat xOffset = padding.left;
    CGFloat yOffset = padding.top;
    
    CGFloat maxWidth = 0;
    CGFloat maxHeightInRow = 0;
    
    CGFloat totalWidthOfRow = 0;
    CGFloat totalHeight = 0;
    CGFloat colCount = 0;
    
    NSMutableArray<UIView*>* rowViews = [NSMutableArray array];
    [_cooritems addObject:rowViews];
    
    for(UIView* child in subviews)
    {
        ViewParams* childViewParams = child.viewParams;
        if(Visibility_GONE == childViewParams.visibility)
        {
            continue;
        }
        FlowLayoutParams* layoutParams = (FlowLayoutParams*)child.layoutParams;
        [self measureChildWithMargins:child parentWidthSpec:widthSpec widthUsed:0 parentHeightSpec:heightSpec heightUsed:0];
        CGSize childMeasuredSizse = childViewParams.measuredSize;
        
        UIEdgeInsets layout_margin = layoutParams.layout_margin;
        CGFloat hPadding = layout_margin.left + layout_margin.right + childMeasuredSizse.width;
        
        if( (xOffset + hPadding + padding.right) > size.width && colCount > 0)
        {
            xOffset = padding.left;
            yOffset += maxHeightInRow;
            
            [_rowsHeight addObject:@(maxHeightInRow)];
            [_rowsWidth addObject:@(totalWidthOfRow)];
            rowViews = [NSMutableArray array];
            [_cooritems addObject:rowViews];
            
            totalHeight += maxHeightInRow;
            
            totalWidthOfRow = 0;
            maxHeightInRow = 0;
            colCount = 0;
        }

        ++colCount;
        xOffset += layout_margin.left + layout_margin.right + childMeasuredSizse.width;
        totalWidthOfRow += layout_margin.left + layout_margin.right + childMeasuredSizse.width;
    
        CGFloat vPadding = layout_margin.top + layout_margin.bottom;
        maxHeightInRow = MAX(maxHeightInRow, vPadding + childMeasuredSizse.height);
        maxWidth = MAX(maxWidth, totalWidthOfRow);
        [rowViews addObject:child];
    }
    [_rowsHeight addObject:@(maxHeightInRow)];
    [_rowsWidth addObject:@(totalWidthOfRow)];
    
    totalHeight += maxHeightInRow;
    maxWidth = MAX(maxWidth, totalWidthOfRow);
    
    self.contentSize = CGSizeMake(padding.left + padding.right + maxWidth, 
                                  padding.top + padding.bottom + totalHeight);
    if(MeasureSpec_EXACTLY != widthSpec.mode)
    {
        size.width = self.contentSize.width;
    }
    
    if(MeasureSpec_EXACTLY != heightSpec.mode)
    {
        size.height = self.contentSize.height;
    }
    self.contentView.contentSize = self.contentSize;
    return size;
}

- (void)onLayout:(CGRect)rect
{
    if(0 == self.cooritems.count)
    {
        MeasureSpec widthSpec  = {.mode = MeasureSpec_EXACTLY, .size = rect.size.width};
        MeasureSpec heightSpec = {.mode = MeasureSpec_AT_MOST, .size = CGFLOAT_MAX};
        [self calcChild:widthSpec heightSpec:heightSpec size:rect.size];
    }
    
    [self.contentView layout:self.bounds];
    
    ViewParams* viewParams = self.viewParams;
    UIEdgeInsets padding = viewParams.padding;
    
    CGFloat width  = rect.size.width;
    CGFloat height = rect.size.height;
    
    UIEdgeBounds edgeBounds = UIEdgeInsetsMake(viewParams.padding.top,
                                               viewParams.padding.left,
                                               height - viewParams.padding.top,
                                               width  - viewParams.padding.left
                                               );
    
    UIEdgeBounds contentBounds = [Gravity apply:_gravity w:self.contentSize.width h:self.contentSize.height container:edgeBounds layoutDirection:LayoutDirection_LTR];
    
    contentBounds.left = MAX(contentBounds.left, padding.left);
    contentBounds.top  = MAX(contentBounds.top , padding.top);
    
    CGFloat rowYOffset = contentBounds.top;
    
    for(int row=0; row < self.cooritems.count; ++row)
    {
        CGFloat maxHeightInRow = [self.rowsHeight[row] floatValue];
        CGFloat totalWidthOfRow = [self.rowsWidth[row] floatValue];
        
        UIEdgeBounds rowEdgeBounds = UIEdgeInsetsMake(rowYOffset, 
                                                      contentBounds.left, 
                                                      maxHeightInRow + rowYOffset, 
                                                      contentBounds.right);

        UIEdgeBounds rowContentBounds = [Gravity apply:_rowGravity w:totalWidthOfRow h:maxHeightInRow container:rowEdgeBounds layoutDirection:LayoutDirection_LTR];
        
        rowYOffset += maxHeightInRow;
        
        CGFloat colXOffset = rowContentBounds.left;
        CGFloat colYOffset = 0;
        NSArray<UIView*>* rowViews = self.cooritems[row];
        
        for(int col=0; col < rowViews.count; ++col)
        {
            UIView* child = rowViews[col];
            FlowLayoutParams* layoutParams = (FlowLayoutParams*)child.layoutParams;
            ViewParams* childViewParams = child.viewParams;
            CGSize measuredSize = childViewParams.measuredSize;
            
            colXOffset += layoutParams.layout_margin.left;
            colYOffset = rowContentBounds.top + layoutParams.layout_margin.top;
            UIEdgeBounds colEdgeBounds = UIEdgeInsetsMake(colYOffset, 
                                                          colXOffset, 
                                                          maxHeightInRow - layoutParams.layout_margin.top - layoutParams.layout_margin.bottom + colYOffset, 
                                                          measuredSize.width + colXOffset);
                                                        
            GravityMode childGravity = layoutParams.layout_gravity ?: _rowGravity;
            
            UIEdgeBounds colContentBounds = [Gravity apply: childGravity w:measuredSize.width h:measuredSize.height container:colEdgeBounds layoutDirection:LayoutDirection_LTR];
            
            CGRect childRect;
            childRect.origin.x = colContentBounds.left ;
            childRect.origin.y = colContentBounds.top;
            childRect.size.width  = colContentBounds.right -  colContentBounds.left;
            childRect.size.height = colContentBounds.bottom - colContentBounds.top;
            [child layout:childRect];
            
            colXOffset += layoutParams.layout_margin.right + childRect.size.width;
        }
    }
}

- (NSMutableArray<NSNumber*>*)rowsHeight
{
    if(!_rowsHeight)
    {
        _rowsHeight = [NSMutableArray array];
    }
    return _rowsHeight;
}

- (NSMutableArray<NSNumber*>*)rowsWidth
{
    if(!_rowsWidth)
    {
        _rowsWidth = [NSMutableArray array];
    }
    return _rowsWidth;
}

- (NSMutableArray<NSMutableArray<UIView*>*>*)cooritems
{
    if(!_cooritems)
    {
        _cooritems = [NSMutableArray array];
    }
    return _cooritems;
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
            [weakSelf.layoutViews removeObject:view];
            [weakSelf requestLayout];
        };
        _contentView = contentView;
        [super addSubview:_contentView];
    }
    return _contentView;
}

- (NSMutableArray<UIView*>*)layoutViews
{
    if(!_layoutViews)
    {
        _layoutViews = [NSMutableArray array];
    }
    return _layoutViews;
}

@end
