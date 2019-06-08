//
//  RelativeLayout.m
//  ALayout
//
//  Created by splendourbell on 2017/4/19.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "RelativeLayoutParams.h"
#import "RelativeLayout.h"
#import "AttributeReader.h"
#import "DependencyGraph.h"
#import "MeasureSpec.h"
#import "Gravity.h"
#import "UIView+Params.h"
#import "UIView+ALayout.h"

static NSArray<NSNumber*>* RULES_VERTICAL;
static NSArray<NSNumber*>* RULES_HORIZONTAL;

@implementation RelativeLayout
{
    GravityMode _gravity;
    
    NSString* _ignoreGravity;
    
    DependencyGraph* _graph;
    
    NSMutableArray<UIView*>* _sortedHorizontalChildren;
    NSMutableArray<UIView*>* _sortedVerticalChildren;
}

+ (void)initialize
{
    RULES_VERTICAL = @[
                       @(RelativeLayout_ABOVE),
                       @(RelativeLayout_BELOW),
//                       @(RelativeLayout_ALIGN_BASELINE),
                       @(RelativeLayout_ALIGN_TOP),
                       @(RelativeLayout_ALIGN_BOTTOM)
                       ];
    
    RULES_HORIZONTAL = @[
                         @(RelativeLayout_LEFT_OF),
                         @(RelativeLayout_RIGHT_OF),
                         @(RelativeLayout_ALIGN_LEFT),
                         @(RelativeLayout_ALIGN_RIGHT)
//                         @(RelativeLayout_START_OF),
//                         @(RelativeLayout_END_OF),
//                         @(RelativeLayout_ALIGN_START),
//                         @(RelativeLayout_ALIGN_END)
                         ];
}

- (instancetype)init
{
    if(self = [super init])
    {
        _graph = [[DependencyGraph alloc] init];
    }
    return self;
}

- (void)parseAttr:(AttributeReader*)attrReader useDefault:(BOOL)useDefault
{
    [super parseAttr:attrReader useDefault:useDefault];
    
    ATTR_ReadAttrEq(_gravity, A_gravity, GravityMode, Gravity_LEFT | Gravity_TOP);
    ATTR_ReadAttrEq(_ignoreGravity, A_ignoreGravity, NSString, nil);
}

- (LayoutParams*)generateLayoutParams:(AttributeReader *)attrReader
{
    return [[RelativeLayoutParams alloc] initWithAttr:attrReader];
}

- (void)sortChildren
{
    NSArray* subviews = self.subviews;
    const int count = (int)subviews.count;
    if (_sortedVerticalChildren.count != count)
    {
        _sortedVerticalChildren = [NSMutableArray array];
    }
    else
    {
        [_sortedVerticalChildren removeAllObjects];
    }
    
    if (_sortedHorizontalChildren.count != count)
    {
        _sortedHorizontalChildren = [NSMutableArray array];
    }
    else
    {
        [_sortedHorizontalChildren removeAllObjects];
    }
    
    DependencyGraph* graph = _graph;
    [graph clear];
    for (int i = 0; i < count; i++)
    {
        [graph add:subviews[i]];
    }
    
    [graph sortedViews:_sortedVerticalChildren   rules:RULES_VERTICAL];
    [graph sortedViews:_sortedHorizontalChildren rules:RULES_HORIZONTAL];
}

- (void)onMeasure:(MeasureSpec)widthSpec heightSpec:(MeasureSpec)heightSpec
{
    [self sortChildren];
    
    CGFloat myWidth  = -1;
    CGFloat myHeight = -1;
    
    CGFloat width  = 0;
    CGFloat height = 0;
    
    const MeasureSpecMode widthMode  = widthSpec.mode;
    const MeasureSpecMode heightMode = heightSpec.mode;
    
    const CGFloat widthSize  = widthSpec.size;
    const CGFloat heightSize = heightSpec.size;
    
    (MeasureSpec_UNSPECIFIED != widthMode)  ? (myWidth  = widthSize)  : 0;
    (MeasureSpec_UNSPECIFIED != heightMode) ? (myHeight = heightSize) : 0;
    (MeasureSpec_EXACTLY     == widthMode)  ? (width    = myWidth)    : 0;
    (MeasureSpec_EXACTLY     == heightMode) ? (height   = myHeight)   : 0;
    
    UIView* ignore = nil;
    
    GravityMode gravity = _gravity & Gravity_RELATIVE_HORIZONTAL_GRAVITY_MASK;
    const BOOL horizontalGravity = (gravity && (gravity != Gravity_LEFT));
    
    gravity = _gravity & Gravity_VERTICAL_GRAVITY_MASK;
    const BOOL verticalGravity = (gravity && (gravity != Gravity_TOP));
    
    CGFloat left    = INT_MAX;
    CGFloat top     = INT_MAX;
    CGFloat right   = INT_MIN;
    CGFloat bottom  = INT_MIN;
    
    BOOL offsetHorizontalAxis = NO;
    BOOL offsetVerticalAxis = NO;
    
    if ((horizontalGravity || verticalGravity) && _ignoreGravity)
    {
        ignore = self[_ignoreGravity];
    }
    
    const BOOL isWrapContentWidth  = (MeasureSpec_EXACTLY != widthMode);
    const BOOL isWrapContentHeight = (MeasureSpec_EXACTLY != heightMode);
    
    const LayoutDirectionMode layoutDirection = LayoutDirection_LTR;
    
    NSMutableArray<UIView*>* views = _sortedHorizontalChildren;
    int count = (int)views.count;
    
    for (int i = 0; i < count; i++)
    {
        UIView* child = views[i];
        ViewParams* childViewParams = child.viewParams;
        if (Visibility_GONE != childViewParams.visibility)
        {
            RelativeLayoutParams* params = (RelativeLayoutParams*)child.layoutParams;
            RelativeRule* rules = [params getRules:layoutDirection];
            
            [self applyHorizontalSizeRules:params myWidth:myWidth rules:rules];
            [self measureChildHorizontal:child params:params myWidth:myWidth myHeight:myHeight];
            
            if ([self positionChildHorizontal:child params:params myWidth:myWidth wrap:isWrapContentWidth])
            {
                offsetHorizontalAxis = true;
            }
        }
    }
    
    views = _sortedVerticalChildren;
    count = (int)views.count;
    
    for (int i = 0; i < count; i++)
    {
        UIView* child = views[i];
        ViewParams* childViewParams = child.viewParams;
        if (Visibility_GONE != childViewParams.visibility)
        {
            RelativeLayoutParams* params = (RelativeLayoutParams*)child.layoutParams;
            [self applyVerticalSizeRules:params myHeight:myHeight];// myBaseline:child.baseline];
            [self measureChild:child params:params myWidth:myWidth myHeight:myHeight];
            
            if ([self positionChildVertical:child params:params myHeight:myHeight wrap:isWrapContentHeight])
            {
                offsetVerticalAxis = true;
            }
            
            if (isWrapContentWidth)
            {
                //TODO:
                //                if (isLayoutRtl())
                //                {
                //                    width = Math.max(width, myWidth - params.mLeft - params.leftMargin);
                //                }
                //                else
                {
                    width = MAX(width, (params.right + params.layout_margin.right));
                }
            }
            
            if (isWrapContentHeight)
            {
                height = MAX(height, (params.bottom + params.layout_margin.bottom));
            }
            
            if (child != ignore || verticalGravity)
            {
                left = MIN(left, (params.left - params.layout_margin.left));
                top  = MIN(top,  (params.top - params.layout_margin.top));
            }
            
            if (child != ignore || horizontalGravity)
            {
                right  = MAX(right,  (params.right  + params.layout_margin.right));
                bottom = MAX(bottom, (params.bottom + params.layout_margin.bottom));
            }
        }
    }
    
    RelativeLayoutParams* layoutParams = (RelativeLayoutParams*)self.layoutParams;
    ViewParams* viewParams = self.viewParams;
    
    if (isWrapContentWidth)
    {
        width += viewParams.padding.right;
        if (layoutParams.layout_width >= 0)
        {
            width = MAX(width, layoutParams.layout_width);
        }
        
        width = MAX(width, self.suggestedMinimumWidth);
        width = [self resolveSize:width measureSpec:widthSpec];
        
        if (offsetHorizontalAxis)
        {
            for (int i = 0; i < count; i++)
            {
                UIView* child = views[i];
                ViewParams* childViewParams = child.viewParams;
                if (Visibility_GONE != childViewParams.visibility)
                {
                    RelativeLayoutParams* params = (RelativeLayoutParams*)child.layoutParams;
                    RelativeRule* rules = [params getRules:layoutDirection];
                    if (rules[@(RelativeLayout_CENTER_IN_PARENT)] || rules[@(RelativeLayout_CENTER_HORIZONTAL)])
                    {
                        [self centerHorizontal:childViewParams params:params myWidth:width];
                    }
                    else if (rules[@(RelativeLayout_ALIGN_PARENT_RIGHT)])
                    {
                        const CGFloat childWidth = childViewParams.measuredSize.width;
                        params.left  = width - viewParams.padding.right - childWidth;
                        params.right = params.left + childWidth;
                    }
                }
            }
        }
    }
    
    if (isWrapContentHeight)
    {
        height += viewParams.padding.bottom;
        
        if (layoutParams.layout_height >= 0)
        {
            height = MAX(height, layoutParams.layout_height);
        }
        
        height = MAX(height, self.suggestedMinimumHeight);
        height = [self resolveSize:height measureSpec:heightSpec];
        
        if (offsetVerticalAxis)
        {
            for (int i = 0; i < count; i++)
            {
                UIView* child = views[i];
                ViewParams* childViewParams = child.viewParams;
                if (Visibility_GONE != childViewParams.visibility)
                {
                    RelativeLayoutParams* params = (RelativeLayoutParams*)child.layoutParams;
                    RelativeRule* rules = [params getRules:layoutDirection];
                    if (rules[@(RelativeLayout_CENTER_IN_PARENT)] || rules[@(RelativeLayout_CENTER_VERTICAL)])
                    {
                        [self centerVertical:childViewParams params:params myHeight:height];
                    }
                    else if (rules[@(RelativeLayout_ALIGN_PARENT_BOTTOM)])
                    {
                        const CGFloat childHeight = childViewParams.measuredSize.height;
                        params.top = height - viewParams.padding.bottom - childHeight;
                        params.bottom = params.top + childHeight;
                    }
                }
            }
        }
    }
    
    if (horizontalGravity || verticalGravity)
    {
        UIEdgeBounds edgeBounds = UIEdgeInsetsMake(viewParams.padding.top,
                                             viewParams.padding.left,
                                             height - viewParams.padding.bottom,
                                             width  - viewParams.padding.right);
        
        UIEdgeBounds contentBounds = [Gravity apply:_gravity w:(right-left) h:(bottom-top) container:edgeBounds layoutDirection:LayoutDirection_LTR];
        
        const CGFloat horizontalOffset = contentBounds.left - left;
        const CGFloat verticalOffset   = contentBounds.top - top;
        if (0 != horizontalOffset || 0 != verticalOffset)
        {
            for (int i = 0; i < count; i++)
            {
                UIView* child = views[i];
                ViewParams* childViewParams = child.viewParams;
                if (Visibility_GONE != childViewParams.visibility && child != ignore)
                {
                    RelativeLayoutParams* params = (RelativeLayoutParams*)child.layoutParams;
                    if (horizontalGravity)
                    {
                        params.left += horizontalOffset;
                        params.right += horizontalOffset;
                    }
                    if (verticalGravity)
                    {
                        params.top += verticalOffset;
                        params.bottom += verticalOffset;
                    }
                }
            }
        }
    }
    
    [self setMeasuredDimensionRaw:CGSizeMake(width, height)];
}

- (BOOL)positionChildHorizontal:(UIView*)child
                         params:(RelativeLayoutParams*)layoutParams
                        myWidth:(CGFloat)myWidth
                           wrap:(BOOL)wrapContent
{
    LayoutDirectionMode layoutDirection = LayoutDirection_LTR;
    RelativeRule* rules = [layoutParams getRules:layoutDirection];
    
    ViewParams* childViewParams = child.viewParams;
    ViewParams* viewParams = self.viewParams;
    
    if ((RelativeLayout_VALUE_NOT_SET == layoutParams.left) && (RelativeLayout_VALUE_NOT_SET != layoutParams.right))
    {
        layoutParams.left = layoutParams.right - childViewParams.measuredSize.width;
    }
    else if (RelativeLayout_VALUE_NOT_SET != layoutParams.left && RelativeLayout_VALUE_NOT_SET == layoutParams.right)
    {
        layoutParams.right = layoutParams.left + childViewParams.measuredSize.width;
    }
    else if (RelativeLayout_VALUE_NOT_SET == layoutParams.left && RelativeLayout_VALUE_NOT_SET == layoutParams.right)
    {
        if (rules[@(RelativeLayout_CENTER_IN_PARENT)] || rules[@(RelativeLayout_CENTER_HORIZONTAL)])
        {
            if (wrapContent)
            {
                layoutParams.left  = viewParams.padding.left + layoutParams.layout_margin.left;
                layoutParams.right = layoutParams.left + viewParams.measuredSize.width;
            }
            else
            {
                [self centerHorizontal:childViewParams params:layoutParams myWidth:myWidth];
            }
            return true;
        }
        else
        {
//            if ([self isLayoutRtl])
//            {
//                layoutParams.right = myWidth - viewParams.padding.right - layoutParams.layout_margin.right;
//                layoutParams.left = layoutParams.right - child.measuredWidth;
//            }
//            else
            {
                layoutParams.left  = viewParams.padding.left + layoutParams.layout_margin.left;
                layoutParams.right = layoutParams.left + childViewParams.measuredSize.width;
            }
        }
    }
    return [rules[@(RelativeLayout_ALIGN_PARENT_END)] boolValue];
}

- (void) centerHorizontal:(ViewParams*)viewParams params:(RelativeLayoutParams*)params myWidth:(CGFloat)myWidth
{
    CGFloat childWidth = viewParams.measuredSize.width;
    CGFloat left = (myWidth - childWidth) / 2;
    
    params.left = left;
    params.right = left + childWidth;
}

- (void)centerVertical:(ViewParams*)viewParams params:(RelativeLayoutParams*)params myHeight:(CGFloat)myHeight
{
    CGFloat childHeight = viewParams.measuredSize.height;
    CGFloat top = (myHeight - childHeight) / 2;
    
    params.top = top;
    params.bottom = top + childHeight;
}

- (BOOL)positionChildVertical : (UIView*)child
                       params : (RelativeLayoutParams*)params
                     myHeight : (CGFloat)myHeight
                         wrap : (BOOL)wrapContent
{
    RelativeRule* rules = [params rules];
    
    ViewParams* childViewParams = child.viewParams;
    ViewParams* viewParams = self.viewParams;
    
    if (RelativeLayout_VALUE_NOT_SET == params.top && RelativeLayout_VALUE_NOT_SET != params.bottom)
    {
        params.top = params.bottom - childViewParams.measuredSize.height;
    }
    else if (RelativeLayout_VALUE_NOT_SET != params.top && RelativeLayout_VALUE_NOT_SET == params.bottom)
    {
        params.bottom = params.top + childViewParams.measuredSize.height;
    }
    else if (RelativeLayout_VALUE_NOT_SET == params.top && RelativeLayout_VALUE_NOT_SET == params.bottom)
    {
        if (rules[@(RelativeLayout_CENTER_IN_PARENT)] || rules[@(RelativeLayout_CENTER_VERTICAL)])
        {
            if (wrapContent)
            {
                params.top = viewParams.padding.top + params.layout_margin.top;
                params.bottom = params.top + childViewParams.measuredSize.height;
            }
            else
            {
                [self centerVertical:childViewParams params:params myHeight:myHeight];
            }
            return true;
        }
        else
        {
            params.top = viewParams.padding.top + params.layout_margin.top;
            params.bottom = params.top + childViewParams.measuredSize.height;
        }
    }
    return [rules[@(RelativeLayout_ALIGN_PARENT_BOTTOM)] boolValue];
}

- (void)measureChild:(UIView*)child params:(RelativeLayoutParams*)params myWidth:(CGFloat)myWidth myHeight:(CGFloat)myHeight
{
    ViewParams* viewParams = self.viewParams;
    
    MeasureSpec childWidthMeasureSpec  = [self getChildMeasureSpec : params.left
                                                          childEnd : params.right
                                                         childSize : params.layout_width
                                                       startMargin : params.layout_margin.left
                                                         endMargin : params.layout_margin.right
                                                      startPadding : viewParams.padding.left
                                                        endPadding : viewParams.padding.right
                                                            mySize : myWidth];
    
    MeasureSpec childHeightMeasureSpec = [self getChildMeasureSpec : params.top
                                                          childEnd : params.bottom
                                                         childSize : params.layout_height
                                                       startMargin : params.layout_margin.top
                                                         endMargin : params.layout_margin.bottom
                                                      startPadding : viewParams.padding.top
                                                        endPadding : viewParams.padding.bottom
                                                            mySize : myHeight];
    
    [child measure:childWidthMeasureSpec heightSpec:childHeightMeasureSpec];
}

- (void)applyVerticalSizeRules:(RelativeLayoutParams*)childParams myHeight:(CGFloat)myHeight //myBaseline:(int)myBaseline
{
    RelativeRule* rules = [childParams rules];
    
//    CGFloat baselineOffset = [self getRelatedViewBaselineOffset:rules];
//    if (baselineOffset != -1)
//    {
//        if (myBaseline != -1)
//        {
//            baselineOffset -= myBaseline;
//        }
//        childParams.top = baselineOffset;
//        childParams.bottom = RelativeLayout_VALUE_NOT_SET;
//        return;
//    }
    
    RelativeLayoutParams* anchorParams;
    
    childParams.top = RelativeLayout_VALUE_NOT_SET;
    childParams.bottom = RelativeLayout_VALUE_NOT_SET;
    
    ViewParams* viewParams = self.viewParams;
    
    anchorParams = (RelativeLayoutParams*)[self getRelatedViewParams:rules relation:RelativeLayout_ABOVE];
    
    if (anchorParams)
    {
        childParams.bottom = anchorParams.top - (anchorParams.layout_margin.top + childParams.layout_margin.bottom);
    }
    else if (childParams.alignWithParent && rules[@(RelativeLayout_ABOVE)])
    {
        if (myHeight >= 0)
        {
            childParams.bottom = myHeight - viewParams.padding.top - childParams.layout_margin.bottom;
        }
    }
    
    anchorParams = (RelativeLayoutParams*)[self getRelatedViewParams:rules relation:RelativeLayout_BELOW];
    if (anchorParams)
    {
        childParams.top = anchorParams.bottom + (anchorParams.layout_margin.bottom + childParams.layout_margin.top);
    }
    else if (childParams.alignWithParent && rules[@(RelativeLayout_BELOW)])
    {
        childParams.top = viewParams.padding.top + childParams.layout_margin.top;
    }
    
    anchorParams = (RelativeLayoutParams*)[self getRelatedViewParams:rules relation:RelativeLayout_ALIGN_TOP];
    if (anchorParams)
    {
        childParams.top = anchorParams.top + childParams.layout_margin.top;
    }
    else if (childParams.alignWithParent && rules[@(RelativeLayout_ALIGN_TOP)])
    {
        childParams.top = viewParams.padding.top + childParams.layout_margin.top;
    }
    
    anchorParams = (RelativeLayoutParams*)[self getRelatedViewParams:rules relation:RelativeLayout_ALIGN_BOTTOM];
    if (anchorParams)
    {
        childParams.bottom = anchorParams.bottom - childParams.layout_margin.bottom;
    }
    else if (childParams.alignWithParent && rules[@(RelativeLayout_ALIGN_BOTTOM)])
    {
        if (myHeight >= 0)
        {
            childParams.bottom = myHeight - viewParams.padding.bottom - childParams.layout_margin.bottom;
        }
    }
    
    if (rules[@(RelativeLayout_ALIGN_PARENT_TOP)])
    {
        childParams.top = viewParams.padding.top + childParams.layout_margin.top;
    }
    
    if (0 != rules[@(RelativeLayout_ALIGN_PARENT_BOTTOM)])
    {
        if (myHeight >= 0)
        {
            childParams.bottom = myHeight - viewParams.padding.bottom - childParams.layout_margin.bottom;
        }
    }
}

//- (int)getRelatedViewBaselineOffset:(RelativeRule*)rules
//{
//    UIView* v = [self getRelatedView:rules relation:RelativeLayout_ALIGN_BASELINE];
//    if (v)
//    {
//        CGFloat baseline = v.baseline;
//        if (baseline != -1)
//        {
//            LayoutParams* params = v.layoutParams;
//            if([params isKindOfClass:RelativeLayoutParams.class])
//            {
//                RelativeLayoutParams* anchorParams = (RelativeLayoutParams*) v.layoutParams;
//                return anchorParams.top + baseline;
//            }
//        }
//    }
//    return -1;
//}

- (void)applyHorizontalSizeRules:(RelativeLayoutParams*)childParams myWidth:(CGFloat)myWidth rules:(RelativeRule*)rules
{
    RelativeLayoutParams* anchorParams;
    
    // VALUE_NOT_SET indicates a "soft requirement" in that direction. For example:
    // left=10, right=VALUE_NOT_SET means the view must start at 10, but can go as far as it
    // wants to the right
    // left=VALUE_NOT_SET, right=10 means the view must end at 10, but can go as far as it
    // wants to the left
    // left=10, right=20 means the left and right ends are both fixed
    childParams.left = RelativeLayout_VALUE_NOT_SET;
    childParams.right = RelativeLayout_VALUE_NOT_SET;
    
    ViewParams* viewParams = self.viewParams;
    
    anchorParams = (RelativeLayoutParams*)[self getRelatedViewParams:rules relation:RelativeLayout_LEFT_OF];
    if (anchorParams)
    {
        childParams.right = anchorParams.left - (anchorParams.layout_margin.left + childParams.layout_margin.right);
    }
    else if (childParams.alignWithParent && rules[@(RelativeLayout_LEFT_OF)])
    {
        if (myWidth >= 0)
        {
            childParams.right = myWidth - viewParams.padding.right - childParams.layout_margin.right;
        }
    }
    
    anchorParams = (RelativeLayoutParams*)[self getRelatedViewParams:rules relation:RelativeLayout_RIGHT_OF];
    if (anchorParams)
    {
        childParams.left = anchorParams.right + (anchorParams.layout_margin.right + childParams.layout_margin.left);
    }
    else if (childParams.alignWithParent && rules[@(RelativeLayout_RIGHT_OF)])
    {
        childParams.left = viewParams.padding.left + childParams.layout_margin.left;
    }
    
    anchorParams = (RelativeLayoutParams*)[self getRelatedViewParams:rules relation:RelativeLayout_ALIGN_LEFT];
    if (anchorParams)
    {
        childParams.left = anchorParams.left + childParams.layout_margin.left;
    }
    else if (childParams.alignWithParent && rules[@(RelativeLayout_ALIGN_LEFT)])
    {
        childParams.left = viewParams.padding.left + childParams.layout_margin.left;
    }
    
    anchorParams = (RelativeLayoutParams*)[self getRelatedViewParams:rules relation:RelativeLayout_ALIGN_RIGHT];
    if (anchorParams)
    {
        childParams.right = anchorParams.right - childParams.layout_margin.right;
    }
    else if (childParams.alignWithParent && rules[@(RelativeLayout_ALIGN_RIGHT)])
    {
        if (myWidth >= 0)
        {
            childParams.right = myWidth - viewParams.padding.right - childParams.layout_margin.right;
        }
    }
    
    if (rules[@(RelativeLayout_ALIGN_PARENT_LEFT)])
    {
        childParams.left = viewParams.padding.left + childParams.layout_margin.left;
    }
    
    if (rules[@(RelativeLayout_ALIGN_PARENT_RIGHT)])
    {
        if (myWidth >= 0)
        {
            childParams.right = myWidth - viewParams.padding.right - childParams.layout_margin.right;
        }
    }
}

- (LayoutParams*)getRelatedViewParams:(RelativeRule*)rules relation:(RelativeLayoutType)relation
{
    UIView* v = [self getRelatedView:rules relation:relation];
    if (v)
    {
        LayoutParams* params = v.layoutParams;
        if([params isKindOfClass:RelativeLayoutParams.class])
        {
            return (LayoutParams*)v.layoutParams;
        }
    }
    return nil;
}

- (UIView*)getRelatedView:(RelativeRule*)rules relation:(RelativeLayoutType)relation
{
    NSString* viewId = rules[@(relation)];
    if (viewId)
    {
        DependencyGraph_Node* node = _graph.keyNodes[viewId];
        if (node)
        {
            UIView* v = node.view;
            ViewParams* viewParams = v.viewParams;
            while (Visibility_GONE == viewParams.visibility)
            {
                rules = [((RelativeLayoutParams*)v.layoutParams) getRules:LayoutDirection_LTR];
                node = _graph.keyNodes[rules[@(relation)]];
                
                if (!node) return nil;
                
                v = node.view;
            }
            return v;
        }
    }
    return nil;
}

- (void)measureChildHorizontal:(UIView*)child params:(RelativeLayoutParams*)params myWidth:(CGFloat)myWidth myHeight:(CGFloat)myHeight
{
    ViewParams* viewParams = self.viewParams;
    
    const MeasureSpec childWidthMeasureSpec = [self getChildMeasureSpec : params.left
                                                               childEnd : params.right
                                                              childSize : params.layout_width
                                                            startMargin : params.layout_margin.left
                                                              endMargin : params.layout_margin.right
                                                           startPadding : viewParams.padding.left
                                                             endPadding : viewParams.padding.right
                                                                 mySize : myWidth];
    
    MeasureSpec childHeightMeasureSpec;
    if (myHeight < 0)
    {
        if (params.layout_height >= 0)
        {
            childHeightMeasureSpec.size = params.layout_height;
            childHeightMeasureSpec.mode = MeasureSpec_EXACTLY;
        }
        else
        {
            childHeightMeasureSpec.size = 0;
            childHeightMeasureSpec.mode = MeasureSpec_UNSPECIFIED;
        }
    }
    else
    {
        const CGFloat maxHeight = MAX(0, (myHeight - viewParams.padding.top - viewParams.padding.bottom - params.layout_margin.top - params.layout_margin.bottom));
        
        if (LayoutParams_MATCH_PARENT == params.layout_height)
        {
            childHeightMeasureSpec.mode = MeasureSpec_EXACTLY;
        }
        else
        {
            childHeightMeasureSpec.mode = MeasureSpec_AT_MOST;
        }
        childHeightMeasureSpec.size = maxHeight;
    }
    [child measure:childWidthMeasureSpec heightSpec:childHeightMeasureSpec];
}

- (MeasureSpec)getChildMeasureSpec:(CGFloat)childStart
                              childEnd:(CGFloat)childEnd
                             childSize:(CGFloat)childSize
                           startMargin:(CGFloat)startMargin
                             endMargin:(CGFloat)endMargin
                          startPadding:(CGFloat)startPadding
                            endPadding:(CGFloat)endPadding
                                mySize:(CGFloat)mySize
{
    MeasureSpec childSpec = {.size = 0, .mode = MeasureSpec_UNSPECIFIED};
    
    BOOL isUnspecified = mySize < 0;
    if (isUnspecified)
    {
        if ((RelativeLayout_VALUE_NOT_SET != childStart) && (RelativeLayout_VALUE_NOT_SET != childEnd))
        {
            childSpec.size = MAX(0, (childEnd - childStart));
            childSpec.mode = MeasureSpec_EXACTLY;
        }
        else if (childSize >= 0)
        {
            childSpec.size = childSize;
            childSpec.mode = MeasureSpec_EXACTLY;
        }
        return childSpec;
    }
    
    CGFloat tempStart = childStart;
    CGFloat tempEnd   = childEnd;
    
    if (RelativeLayout_VALUE_NOT_SET == tempStart)
    {
        tempStart = startPadding + startMargin;
    }
    if (RelativeLayout_VALUE_NOT_SET == tempEnd)
    {
        tempEnd = mySize - endPadding - endMargin;
    }
    
    const CGFloat maxAvailable = tempEnd - tempStart;
    
    if (RelativeLayout_VALUE_NOT_SET != childStart && RelativeLayout_VALUE_NOT_SET != childEnd)
    {
        childSpec.mode = isUnspecified ? MeasureSpec_UNSPECIFIED : MeasureSpec_EXACTLY;
        childSpec.size = MAX(0, maxAvailable);
    }
    else
    {
        if (childSize >= 0)
        {
            childSpec.mode = MeasureSpec_EXACTLY;
            
            if (maxAvailable >= 0)
            {
                childSpec.size = MIN(maxAvailable, childSize);
            }
            else
            {
                childSpec.size = childSize;
            }
        }
        else if (LayoutParams_MATCH_PARENT == childSize)
        {
            childSpec.mode = isUnspecified ? MeasureSpec_UNSPECIFIED : MeasureSpec_EXACTLY;
            childSpec.size = MAX(0, maxAvailable);
        }
        else if (LayoutParams_WRAP_CONTENT == childSize)
        {
            if (maxAvailable >= 0)
            {
                // We have a maximum size in this dimension.
                childSpec.mode = MeasureSpec_AT_MOST;
                childSpec.size = maxAvailable;
            }
            else
            {
                childSpec.mode = MeasureSpec_UNSPECIFIED;
                childSpec.size = 0;
            }
        }
    }
    return childSpec;
}

- (void)onLayout:(CGRect)rect
{
    NSArray<UIView*>* subviews = self.subviews;
    int count = (int)subviews.count;
    
    for (int i = 0; i < count; i++)
    {
        UIView* child = subviews[i];
        ViewParams* viewParams = child.viewParams;
        if (Visibility_GONE != viewParams.visibility)
        {
            RelativeLayoutParams* st = (RelativeLayoutParams*)child.layoutParams;
            CGRect frame = CGRectMake(st.left, st.top, st.right - st.left, st.bottom - st.top);
            [child layout:frame];
        }
    }
}

@end
