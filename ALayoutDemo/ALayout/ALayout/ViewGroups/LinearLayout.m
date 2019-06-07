//
//  LinearLayout.m
//  ALayout
//
//  Created by splendourbell on 2017/5/2.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "LinearLayout.h"
#import "Drawable.h"
#import "LinearLayoutParams.h"

typedef NS_ENUM(int, ShowDividerMode)
{
    ShowDividerNone         = 0,
    ShowDividerBeginning    = 1,
    ShowDividerMiddle       = 2,
    ShowDividerEnd          = 4
};

@implementation LinearLayout
{
    CGFloat _totalLength;
    CGFloat _weightSum;
    BOOL    _useLargestChild;
    
    Drawable* _divider;//TODO:draw
    CGFloat   _dividerWidth;
    CGFloat   _dividerHeight;
    CGFloat   _dividerPadding;
    ShowDividerMode _showDividers;
}

- (void)parseAttr:(AttributeReader *)attrReader useDefault:(BOOL)useDefault
{
    [super parseAttr:attrReader useDefault:useDefault];
    
    ATTR_ReadAttrEq(_orientation,     A_orientation,  OrientationMode,    Orientation_HORIZONTAL);
    ATTR_ReadAttrEq(_gravity,         A_gravity,      GravityMode,        Gravity_TOP|Gravity_LEFT);
    
    ATTR_ReadAttrEq(_useLargestChild, A_measureWithLargestChild,  BOOL, NO);
    ATTR_ReadAttrEq(_weightSum,       A_weightSum,        CGFloat,    -1.0);
    ATTR_ReadAttrEq(_divider,         A_divider,          Drawable,   nil);
    ATTR_ReadAttrEq(_dividerPadding,  A_dividerPadding,   Dimension,  0);

    if (ATTR_CanRead(A_showDividers))
    {
        _showDividers = ShowDividerNone;
        NSString* showDividers = ATTR_ReadAttr(A_showDividers, NSString, nil);
        if(showDividers)
        {
            if([showDividers rangeOfString:@"beginning"].length)
            {
                _showDividers |= ShowDividerBeginning;
            }
            if([showDividers rangeOfString:@"middle"].length)
            {
                _showDividers |= ShowDividerMiddle;
            }
            if([showDividers rangeOfString:@"end"].length)
            {
                _showDividers |= ShowDividerEnd;
            }
        }
    }
}

- (void)setDivider:(Drawable*)drawable
{
    if(_divider != drawable)
    {
        _divider = drawable;
        _dividerWidth  = [_divider intrinsicWidth];
        _dividerHeight = [_divider intrinsicHeight];
    }
}

- (NSUInteger)virtualChildCount
{
    return self.subviews.count;
}

- (__kindof UIView*)virtualChildAt:(NSInteger)index
{
    return self.subviews[index];
}

- (CGFloat)measureNullChild:(NSInteger)index
{
    return 0;
}

- (BOOL)allViewsAreGoneBefore:(NSInteger)index
{
    for (int i = (int)index - 1; i >= 0; i--)
    {
        UIView* child = [self virtualChildAt:i];
        if(Visibility_GONE != child.viewParams.visibility)
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)hasDividerBeforeChildAt:(NSInteger)index
{
    if (index == self.virtualChildCount)
    {
        return (_showDividers & ShowDividerEnd);
    }
    
    if ([self allViewsAreGoneBefore:index])
    {
        return (_showDividers & ShowDividerBeginning);
    }
    else
    {
        return (_showDividers & ShowDividerMiddle);
    }
}

- (NSInteger)childrenSkipCount:(UIView*)view index:(NSInteger)index
{
    return 0;
}

- (CGFloat)nextLocationOffset:(UIView*)view
{
    return 0;
}

- (CGFloat)locationOffset:(UIView*)view
{
    return 0;
}

- (void)measureChildBeforeLayout:(UIView*)child
                      childIndex:(NSInteger)childIndex
                       widthSpec:(MeasureSpec)widthSpec
                      totalWidth:(CGFloat)totalWidth
                      heightSpec:(MeasureSpec)heightSpec
                     totalHeight:(CGFloat) totalHeight
{
    [self measureChildWithMargins:child
                  parentWidthSpec:widthSpec
                        widthUsed:totalWidth
                 parentHeightSpec:heightSpec
                       heightUsed:totalHeight];
}

- (void)onMeasure:(MeasureSpec)widthSpec heightSpec:(MeasureSpec)heightSpec
{
    if(Orientation_VERTICAL == self.orientation)
    {
        [self measureVertical:widthSpec heightSpec:heightSpec];
    }
    else
    {
        [self measureHorizontal:widthSpec heightSpec:heightSpec];
    }
}

- (void)measureVertical:(MeasureSpec)widthSpec heightSpec:(MeasureSpec)heightSpec
{
    _totalLength = 0;
    CGFloat maxWidth = 0;
//TODO:    CGFloat childState = 0;
    CGFloat alternativeMaxWidth = 0;
    CGFloat weightedMaxWidth = 0;
    BOOL allFillParent = YES;
    CGFloat totalWeight = 0;
    
    int count = (int)[self virtualChildCount];
    
    MeasureSpecMode widthMode  = widthSpec.mode;
    MeasureSpecMode heightMode = heightSpec.mode;
    
    BOOL matchWidth = NO;
    BOOL skippedMeasure = NO;
    
    //int baselineChildIndex = mBaselineAlignedChildIndex;
    BOOL useLargestChild = _useLargestChild;
    
    CGFloat largestChildHeight = INT_MIN;
    CGFloat consumedExcessSpace = 0;
    
    // See how tall everyone is. Also remember max width.
    for (int i = 0; i < count; ++i)
    {
        UIView* child = [self virtualChildAt:i];
        ViewParams* childViewParams = child.viewParams;
        if (!child)
        {
            _totalLength += [self measureNullChild:i];
            continue;
        }
        
        if (Visibility_GONE == childViewParams.visibility)
        {
            i += [self childrenSkipCount:child index:i];
            continue;
        }
        
        if ([self hasDividerBeforeChildAt:i])
        {
            _totalLength += _dividerHeight;
        }
        
        LinearLayoutParams* lp = (LinearLayoutParams*) child.layoutParams;
        
        totalWeight += lp.layout_weight;
        
        BOOL useExcessSpace = (0 == lp.layout_height && lp.layout_weight > 0);
        if (MeasureSpec_EXACTLY == heightMode && useExcessSpace)
        {
            CGFloat totalLength = _totalLength;
            _totalLength = MAX(totalLength, totalLength + lp.layout_margin.top + lp.layout_margin.bottom);
            skippedMeasure = YES;
        }
        else
        {
            if (useExcessSpace)
            {
                lp.layout_height = LayoutParams_WRAP_CONTENT;
            }

            CGFloat usedHeight = totalWeight == 0 ? _totalLength : 0;
            [self measureChildBeforeLayout:child childIndex:i widthSpec:widthSpec totalWidth:0 heightSpec:heightSpec totalHeight:usedHeight];
            
            CGFloat childHeight = childViewParams.measuredSize.height;
            if (useExcessSpace)
            {
                lp.layout_height = 0;
                consumedExcessSpace += childHeight;
            }
            
            CGFloat totalLength = _totalLength;
            _totalLength = MAX(totalLength, totalLength + childHeight + lp.layout_margin.top +
                                    lp.layout_margin.bottom + [self nextLocationOffset:child]);
            
            if (useLargestChild)
            {
                largestChildHeight = MAX(childHeight, largestChildHeight);
            }
        }
        
//        /**
//         * If applicable, compute the additional offset to the child's baseline
//         * we'll need later when asked {@link #getBaseline}.
//         */
//        if ((baselineChildIndex >= 0) && (baselineChildIndex == i + 1))
//        {
//            mBaselineChildTop = _totalLength;
//        }
        
//        // if we are trying to use a child index for our baseline, the above
//        // book keeping only works if there are no children above it with
//        // weight.  fail fast to aid the developer.
//        if (i < baselineChildIndex && lp.weight > 0) {
//            throw new RuntimeException("A child of LinearLayout with index "
//                                       + "less than mBaselineAlignedChildIndex has weight > 0, which "
//                                       + "won't work.  Either remove the weight, or don't set "
//                                       + "mBaselineAlignedChildIndex.");
//        }
        
        BOOL matchWidthLocally = NO;
        if (MeasureSpec_EXACTLY != widthMode && LayoutParams_MATCH_PARENT == lp.layout_width)
        {
            matchWidth = YES;
            matchWidthLocally = YES;
        }
        
        CGFloat margin = lp.layout_margin.left + lp.layout_margin.right;
        CGFloat measuredWidth = childViewParams.measuredSize.width + margin;
        maxWidth = MAX(maxWidth, measuredWidth);
        //TODO:childState = combineMeasuredStates(childState, child.getMeasuredState());
        
        allFillParent = allFillParent && LayoutParams_MATCH_PARENT == lp.layout_width;
        if (lp.layout_weight > 0)
        {
            weightedMaxWidth = MAX(weightedMaxWidth, matchWidthLocally ? margin : measuredWidth);
        }
        else
        {
            alternativeMaxWidth = MAX(alternativeMaxWidth, matchWidthLocally ? margin : measuredWidth);
        }
        
        i += [self childrenSkipCount:child index:i];
    }
    
    if (_totalLength > 0 && [self hasDividerBeforeChildAt:count])
    {
        _totalLength += _dividerHeight;
    }
    
    if (useLargestChild &&
        (MeasureSpec_AT_MOST == heightMode|| MeasureSpec_UNSPECIFIED == heightMode))
    {
        _totalLength = 0;
        
        for (int i = 0; i < count; ++i)
        {
            UIView* child = [self virtualChildAt:i];
            ViewParams* childViewParams = child.viewParams;
            if (!child)
            {
                _totalLength += [self measureNullChild:i];
                continue;
            }
            
            if (Visibility_GONE == childViewParams.visibility)
            {
                i += [self childrenSkipCount:child index:i];
                continue;
            }
            
            LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
            // Account for negative margins
            CGFloat totalLength = _totalLength;
            _totalLength = MAX(totalLength, totalLength + largestChildHeight +
                                    lp.layout_margin.top + lp.layout_margin.bottom + [self nextLocationOffset:child]);
        }
    }
    
    ViewParams* viewParams = self.viewParams;
    _totalLength += viewParams.padding.top + viewParams.padding.bottom;
    
    CGFloat heightSize = _totalLength;
    
    heightSize = MAX(heightSize, self.suggestedMinimumHeight);
    heightSize = [self resolveSize:heightSize measureSpec:heightSpec];

    CGFloat remainingExcess = heightSize - _totalLength + consumedExcessSpace;
    
    if (skippedMeasure || (remainingExcess != 0 && totalWeight > 0.0f))
    {
        float remainingWeightSum = _weightSum > 0.0f ? _weightSum : totalWeight;
        
        _totalLength = 0;
        
        for (int i = 0; i < count; ++i)
        {
            UIView* child = [self virtualChildAt:i];
            ViewParams* childViewParams = child.viewParams;//TODO child == nil?
            if (Visibility_GONE == childViewParams.visibility)
            {
                continue;
            }
            
            LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
            CGFloat childWeight = lp.layout_weight;
            if (childWeight > 0)
            {
                CGFloat share = childWeight * remainingExcess / remainingWeightSum;
                remainingExcess -= share;
                remainingWeightSum -= childWeight;
                
                CGFloat childHeight;
                if (useLargestChild && MeasureSpec_EXACTLY != heightMode)
                {
                    childHeight = largestChildHeight;
                }
                else if (lp.layout_height == 0)
                {
                    childHeight = share;
                }
                else
                {
                    childHeight = childViewParams.measuredSize.height + share;
                }
                
                MeasureSpec childHeightSpec = {.size = MAX(0, childHeight), .mode = MeasureSpec_EXACTLY};
                
                CGFloat padding = viewParams.padding.left + viewParams.padding.right + lp.layout_margin.left + lp.layout_margin.right;
                MeasureSpec childWidthSpec = [ViewGroup childMeasureSpec:widthSpec padding:padding childDimension:lp.layout_width];
                
                [child measure:childWidthSpec heightSpec:childHeightSpec];
                
// TODO:               // Child may now not fit in vertical dimension.
//                childState = combineMeasuredStates(childState, child.getMeasuredState()
//                                                   & (MEASURED_STATE_MASK>>MEASURED_HEIGHT_STATE_SHIFT));
            }
            
            CGFloat margin =  lp.layout_margin.left + lp.layout_margin.right;
            CGFloat measuredWidth = childViewParams.measuredSize.width + margin;
            maxWidth = MAX(maxWidth, measuredWidth);
            
            BOOL matchWidthLocally = MeasureSpec_EXACTLY != widthMode && LayoutParams_MATCH_PARENT == lp.layout_width;
            
            alternativeMaxWidth = MAX(alternativeMaxWidth,
                                           matchWidthLocally ? margin : measuredWidth);
            
            allFillParent = allFillParent && LayoutParams_MATCH_PARENT == lp.layout_width;
            
            CGFloat totalLength = _totalLength;
            _totalLength = MAX(totalLength, totalLength + childViewParams.measuredSize.height +
                                    lp.layout_margin.top + lp.layout_margin.bottom + [self nextLocationOffset:child]);
        }
        _totalLength += viewParams.padding.top + viewParams.padding.bottom;
    }
    else
    {
        alternativeMaxWidth = MAX(alternativeMaxWidth, weightedMaxWidth);

        if (useLargestChild && MeasureSpec_EXACTLY != heightMode)
        {
            for (int i = 0; i < count; i++)
            {
                UIView* child = [self virtualChildAt:i];
                ViewParams* childViewParams = child.viewParams;
                if (Visibility_GONE == childViewParams.visibility)
                {
                    continue;
                }
                
                LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
                
                CGFloat childExtra = lp.layout_weight;
                if (childExtra > 0)
                {
                    MeasureSpec childWidthSpec  = {.size = childViewParams.measuredSize.width, .mode = MeasureSpec_EXACTLY};
                    MeasureSpec childHeightSpec = {.size = largestChildHeight, .mode = MeasureSpec_EXACTLY};
                    [child measure:childWidthSpec heightSpec:childHeightSpec];
                }
            }
        }
    }
    
    if (!allFillParent && MeasureSpec_EXACTLY != widthMode)
    {
        maxWidth = alternativeMaxWidth;
    }
    
    maxWidth += viewParams.padding.left + viewParams.padding.right;
    maxWidth = MAX(maxWidth, self.suggestedMinimumWidth);
    
    CGFloat resolveWidth = [self resolveSize:maxWidth measureSpec:widthSpec];
    
    [self setMeasuredDimensionRaw:CGSizeMake(resolveWidth, heightSize)];
    
    if (matchWidth)
    {
        [self forceUniformWidth:count heightSpec:heightSpec];
    }
}

- (void)forceUniformWidth:(NSInteger)count heightSpec:(MeasureSpec)heightSpec
{
    MeasureSpec uniformMeasureSpec = {.size = self.viewParams.measuredSize.width, .mode = MeasureSpec_EXACTLY };
    
    for (int i = 0; i< count; ++i)
    {
        UIView* child = [self virtualChildAt:i];
        ViewParams* childViewParams = child.viewParams;
        if(Visibility_GONE == childViewParams.visibility)
        {
            LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
            
            if (LayoutParams_MATCH_PARENT == lp.layout_width)
            {
                CGFloat oldHeight = lp.layout_height;
                lp.layout_height = childViewParams.measuredSize.height;
                
                [self measureChildWithMargins:child
                              parentWidthSpec:uniformMeasureSpec
                                    widthUsed:0
                             parentHeightSpec:heightSpec
                                   heightUsed:0];
                lp.layout_height = oldHeight;
            }
        }
    }
}

- (void)measureHorizontal:(MeasureSpec)widthSpec heightSpec:(MeasureSpec)heightSpec
{
    _totalLength       = 0;
    CGFloat maxHeight  = 0;
    CGFloat alternativeMaxHeight = 0;
    CGFloat weightedMaxHeight    = 0;
    BOOL    allFillParent = YES;
    CGFloat totalWeight   = 0;

    const int count = (int)self.virtualChildCount;
    
    const MeasureSpecMode widthMode  = widthSpec.mode;
    const MeasureSpecMode heightMode = heightSpec.mode;

    BOOL matchHeight    = NO;
    BOOL skippedMeasure = NO;

//TODO:    if (mMaxAscent == null || mMaxDescent == null)
//    {
//        mMaxAscent = new int[VERTICAL_GRAVITY_COUNT];
//        mMaxDescent = new int[VERTICAL_GRAVITY_COUNT];
//    }
//
//    const int[] maxAscent = mMaxAscent;
//    const int[] maxDescent = mMaxDescent;
//
//     maxAscent[0] =  maxAscent[1] =  maxAscent[2] =  maxAscent[3] = -1;
//    maxDescent[0] = maxDescent[1] = maxDescent[2] = maxDescent[3] = -1;
//
//    const BOOL baselineAligned = mBaselineAligned;
    const BOOL useLargestChild = _useLargestChild;

    const BOOL isExactly = (MeasureSpec_EXACTLY == widthMode);
//
    CGFloat largestChildWidth = INT_MIN;
    CGFloat usedExcessSpace = 0;

    for (int i = 0; i < count; ++i)
    {
        UIView* child = [self virtualChildAt:i];
        ViewParams* childViewParams = child.viewParams;
        if (!child)
        {
            _totalLength += [self measureNullChild:i];
            continue;
        }
       
        if ((Visibility_GONE == childViewParams.visibility))
        {
            i += [self childrenSkipCount:child index:i];
            continue;
        }

        if ([self hasDividerBeforeChildAt:i])
        {
            _totalLength += _dividerWidth;
        }

        const LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;

        totalWeight += lp.layout_weight;

        const BOOL useExcessSpace = lp.layout_width == 0 && lp.layout_weight > 0;
        if (widthMode == MeasureSpec_EXACTLY && useExcessSpace)
        {
            if (isExactly)
            {
                _totalLength += lp.layout_margin.left + lp.layout_margin.right;
            }
            else
            {
                const CGFloat totalLength = _totalLength;
                _totalLength = MAX(totalLength, totalLength + lp.layout_margin.left + lp.layout_margin.right);
            }

            // Baseline alignment requires to measure widgets to obtain the
            // baseline offset (in particular for TextViews). The following
            // defeats the optimization mentioned above. Allow the child to
            // use as much space as it wants because we can shrink things
            // later (and re-measure).
//TODO
//            if (baselineAligned)
//            {
//                const CGFloat freeWidthSpec = MeasureSpec.makeSafeMeasureSpec(
//                        MeasureSpec.getSize(widthMeasureSpec), MeasureSpec_UNSPECIFIED);
//                const CGFloat freeHeightSpec = MeasureSpec.makeSafeMeasureSpec(
//                        MeasureSpec.getSize(heightMeasureSpec), MeasureSpec_UNSPECIFIED);
//                child.measure(freeWidthSpec, freeHeightSpec);
//            }
//            else
            {
                skippedMeasure = YES;
            }
        }
        else
        {
            if (useExcessSpace)
            {
                lp.layout_width = LayoutParams_WRAP_CONTENT;
            }

            const CGFloat usedWidth = totalWeight == 0 ? _totalLength : 0;
            [self measureChildBeforeLayout:child childIndex:i widthSpec:widthSpec totalWidth:usedWidth heightSpec:heightSpec totalHeight:0];

            const CGFloat childWidth = childViewParams.measuredSize.width;
            if (useExcessSpace)
            {
                lp.layout_width = 0;
                usedExcessSpace += childWidth;
            }

            if (isExactly)
            {
                _totalLength += childWidth + lp.layout_margin.left + lp.layout_margin.right + [self nextLocationOffset:child];
            }
            else
            {
                const CGFloat totalLength = _totalLength;
                _totalLength = MAX(totalLength, totalLength + childWidth + lp.layout_margin.left + lp.layout_margin.right + [self nextLocationOffset:child]);
            }

            if (useLargestChild)
            {
                largestChildWidth = MAX(childWidth, largestChildWidth);
            }
        }

        BOOL matchHeightLocally = NO;
        if (MeasureSpec_EXACTLY != heightMode && LayoutParams_MATCH_PARENT == lp.layout_height)
        {
            matchHeight = YES;
            matchHeightLocally = YES;
        }

        const CGFloat margin = lp.layout_margin.top + lp.layout_margin.bottom;
        const CGFloat childHeight = childViewParams.measuredSize.height + margin;
        //childState = combineMeasuredStates(childState, child.getMeasuredState());

//        if (baselineAligned)
//        {
//            const CGFloat childBaseline = child.getBaseline();
//            if (childBaseline != -1) {
//                // Translates the child's vertical gravity into an index
//                // in the range 0..VERTICAL_GRAVITY_COUNT
//                const GravityMode gravity = (lp.gravity < 0 ? mGravity : lp.gravity)
//                        & Gravity.VERTICAL_GRAVITY_MASK;
//                const GravityMode index = ((gravity >> Gravity.AXIS_Y_SHIFT)
//                        & ~Gravity.AXIS_SPECIFIED) >> 1;
//
//                maxAscent[index] = MAX(maxAscent[index], childBaseline);
//                maxDescent[index] = MAX(maxDescent[index], childHeight - childBaseline);
//            }
//        }

        maxHeight = MAX(maxHeight, childHeight);

        allFillParent = allFillParent && (LayoutParams_MATCH_PARENT == lp.layout_height);
        if (lp.layout_weight > 0)
        {
            weightedMaxHeight = MAX(weightedMaxHeight, matchHeightLocally ? margin : childHeight);
        }
        else
        {
            alternativeMaxHeight = MAX(alternativeMaxHeight, matchHeightLocally ? margin : childHeight);
        }

        i += [self childrenSkipCount:child index:i];
    }

    if (_totalLength > 0 && [self hasDividerBeforeChildAt:count])
    {
        _totalLength += _dividerWidth;
    }

//    // Check mMaxAscent[INDEX_TOP] first because it maps to Gravity.TOP,
//    // the most common case
//    if (maxAscent[INDEX_TOP] != -1 ||
//            maxAscent[INDEX_CENTER_VERTICAL] != -1 ||
//            maxAscent[INDEX_BOTTOM] != -1 ||
//            maxAscent[INDEX_FILL] != -1) {
//        const CGFloat ascent = MAX(maxAscent[INDEX_FILL],
//                MAX(maxAscent[INDEX_CENTER_VERTICAL],
//                MAX(maxAscent[INDEX_TOP], maxAscent[INDEX_BOTTOM])));
//        const CGFloat descent = MAX(maxDescent[INDEX_FILL],
//                MAX(maxDescent[INDEX_CENTER_VERTICAL],
//                MAX(maxDescent[INDEX_TOP], maxDescent[INDEX_BOTTOM])));
//        maxHeight = MAX(maxHeight, ascent + descent);
//    }

    if (useLargestChild && (MeasureSpec_AT_MOST == widthMode || MeasureSpec_UNSPECIFIED == widthMode))
    {
        _totalLength = 0;

        for (int i = 0; i < count; ++i)
        {
            UIView* child = [self virtualChildAt:i];
            ViewParams* childViewParams = child.viewParams;
            if (!child)
            {
                _totalLength += [self measureNullChild:i];
                continue;
            }

            if((Visibility_GONE == childViewParams.visibility))
            {
                i += [self childrenSkipCount:child index:i];
                continue;
            }

            const LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
            if (isExactly)
            {
                _totalLength += largestChildWidth + lp.layout_margin.left + lp.layout_margin.right + [self nextLocationOffset:child];
            }
            else
            {
                const CGFloat totalLength = _totalLength;
                _totalLength = MAX(totalLength, totalLength + largestChildWidth + lp.layout_margin.left + lp.layout_margin.right + [self nextLocationOffset:child]);
            }
        }
    }

    ViewParams* viewParams = self.viewParams;
    _totalLength += viewParams.padding.left + viewParams.padding.right;
    
    CGFloat widthSize = _totalLength;
    
    widthSize = MAX(widthSize, self.suggestedMinimumWidth);
    
    widthSize = [self resolveSize:widthSize measureSpec:widthSpec];
    
    CGFloat remainingExcess = widthSize - _totalLength + usedExcessSpace;
    if (skippedMeasure || (remainingExcess && totalWeight > 0.0f))
    {
        CGFloat remainingWeightSum = _weightSum > 0.0f ? _weightSum : totalWeight;

//        maxAscent[0] = maxAscent[1] = maxAscent[2] = maxAscent[3] = -1;
//        maxDescent[0] = maxDescent[1] = maxDescent[2] = maxDescent[3] = -1;
        maxHeight = -1;

        _totalLength = 0;

        for (int i = 0; i < count; ++i)
        {
            UIView* child = [self virtualChildAt:i];
            ViewParams* childViewParams = child.viewParams;
            if((Visibility_GONE == childViewParams.visibility))
            {
                continue;
            }

            LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
            const CGFloat childWeight = lp.layout_weight;
            if (childWeight > 0)
            {
                const CGFloat share = childWeight * remainingExcess / remainingWeightSum;
                remainingExcess -= share;
                remainingWeightSum -= childWeight;

                CGFloat childWidth;
                if (_useLargestChild && MeasureSpec_EXACTLY != widthMode)
                {
                    childWidth = largestChildWidth;
                }
                else if (0 == lp.layout_width)
                {
                    childWidth = share;
                }
                else
                {
                    childWidth = childViewParams.measuredSize.width + share;
                }

                MeasureSpec childWidthSpec = {.size = MAX(0, childWidth), .mode = MeasureSpec_EXACTLY};
                
                CGFloat padding = 0;
                padding += viewParams.padding.top + viewParams.padding.bottom;
                padding += lp.layout_margin.top + lp.layout_margin.bottom;

                MeasureSpec childHeightSpec = [ViewGroup childMeasureSpec:heightSpec padding:padding childDimension:lp.layout_height];
                [child measure:childWidthSpec heightSpec:childHeightSpec];

//                // Child may now not fit in horizontal dimension.
//                childState = combineMeasuredStates(childState,
//                        child.getMeasuredState() & MEASURED_STATE_MASK);
            }

            if (isExactly)
            {
                _totalLength += childViewParams.measuredSize.width + lp.layout_margin.left + lp.layout_margin.right + [self nextLocationOffset:child];
            }
            else
            {
                const CGFloat totalLength = _totalLength;
                _totalLength = MAX(totalLength, totalLength + childViewParams.measuredSize.width + lp.layout_margin.left + lp.layout_margin.right + [self nextLocationOffset:child]);
            }

            BOOL matchHeightLocally = (MeasureSpec_EXACTLY != heightMode && LayoutParams_MATCH_PARENT == lp.layout_height);

            const CGFloat margin = lp.layout_margin.top + lp.layout_margin.bottom;
            CGFloat childHeight = childViewParams.measuredSize.height + margin;
            maxHeight = MAX(maxHeight, childHeight);
            alternativeMaxHeight = MAX(alternativeMaxHeight, matchHeightLocally ? margin : childHeight);

            allFillParent = allFillParent && LayoutParams_MATCH_PARENT == lp.layout_height;

//            if (baselineAligned)
//            {
//                const CGFloat childBaseline = child.getBaseline();
//                if (childBaseline != -1) {
//                    // Translates the child's vertical gravity into an index in the range 0..2
//                    const GravityMode gravity = (lp.gravity < 0 ? mGravity : lp.gravity)
//                            & Gravity.VERTICAL_GRAVITY_MASK;
//                    const GravityMode index = ((gravity >> Gravity.AXIS_Y_SHIFT)
//                            & ~Gravity.AXIS_SPECIFIED) >> 1;
//
//                    maxAscent[index] = MAX(maxAscent[index], childBaseline);
//                    maxDescent[index] = MAX(maxDescent[index],
//                            childHeight - childBaseline);
//                }
//            }
        }

        _totalLength += viewParams.padding.left + viewParams.padding.right;

        // Check mMaxAscent[INDEX_TOP] first because it maps to Gravity.TOP,
        // the most common case
//        if (maxAscent[INDEX_TOP] != -1 ||
//                maxAscent[INDEX_CENTER_VERTICAL] != -1 ||
//                maxAscent[INDEX_BOTTOM] != -1 ||
//                maxAscent[INDEX_FILL] != -1) {
//            const CGFloat ascent = MAX(maxAscent[INDEX_FILL],
//                    MAX(maxAscent[INDEX_CENTER_VERTICAL],
//                    MAX(maxAscent[INDEX_TOP], maxAscent[INDEX_BOTTOM])));
//            const CGFloat descent = MAX(maxDescent[INDEX_FILL],
//                    MAX(maxDescent[INDEX_CENTER_VERTICAL],
//                    MAX(maxDescent[INDEX_TOP], maxDescent[INDEX_BOTTOM])));
//            maxHeight = MAX(maxHeight, ascent + descent);
//        }
    }
    else
    {
        alternativeMaxHeight = MAX(alternativeMaxHeight, weightedMaxHeight);

        if (useLargestChild && MeasureSpec_EXACTLY != widthMode)
        {
            for (int i = 0; i < count; i++)
            {
                UIView* child = [self virtualChildAt:i];
                ViewParams* childViewParams = child.viewParams;
                if((Visibility_GONE == childViewParams.visibility))
                {
                    continue;
                }

                const LinearLayoutParams* lp = (LinearLayoutParams*) child.layoutParams;

                float childExtra = lp.layout_weight;
                if (childExtra > 0)
                {
                    MeasureSpec wSpec = {.size = largestChildWidth, .mode = MeasureSpec_EXACTLY};
                    MeasureSpec hSpec = {.size = childViewParams.measuredSize.height, .mode = MeasureSpec_EXACTLY};
                    [child measure:wSpec heightSpec:hSpec];
                }
            }
        }
    }

    if (!allFillParent && MeasureSpec_EXACTLY != heightMode)
    {
        maxHeight = alternativeMaxHeight;
    }
    
    maxHeight += viewParams.padding.top + viewParams.padding.bottom;
    maxHeight = MAX(maxHeight, self.suggestedMinimumHeight);
    
    [self setMeasuredDimensionRaw:CGSizeMake(widthSize, [self resolveSize:maxHeight measureSpec:heightSpec])];

    if (matchHeight)
    {
        [self forceUniformHeight:count widthSpec:widthSpec];
    }
}

- (void)forceUniformHeight:(NSInteger)count widthSpec:(MeasureSpec)widthSpec
{
    MeasureSpec uniformMeasureSpec = {.size = self.viewParams.measuredSize.height, .mode = MeasureSpec_EXACTLY};
    
    for (int i = 0; i < count; ++i)
    {
        UIView* child = [self virtualChildAt:i];
        ViewParams* childViewParams = child.viewParams;
        if(Visibility_GONE != childViewParams.visibility)
        {
            LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
            
            if (LayoutParams_MATCH_PARENT == lp.layout_height)
            {
                CGFloat oldWidth = lp.layout_width;
                lp.layout_width = childViewParams.measuredSize.width;
                
                [self measureChildWithMargins:child parentWidthSpec:widthSpec widthUsed:0 parentHeightSpec:uniformMeasureSpec heightUsed:0];
                lp.layout_width = oldWidth;
            }
        }
    }
}

- (LayoutParams*)generateLayoutParams:(AttributeReader *)attrReader
{
    return [[LinearLayoutParams alloc] initWithAttr:attrReader];
}

- (void)onLayout:(CGRect)rect
{
    if(Orientation_VERTICAL == self.orientation)
    {
        [self layoutVertical:rect];
    }
    else
    {
        [self layoutHorizontal:rect];
    }
}

- (void)layoutVertical:(CGRect)rect
{
    ViewParams* viewParams = self.viewParams;
    
    CGFloat paddingLeft = viewParams.padding.left;
    
    CGFloat childTop;
    CGFloat childLeft;

    CGFloat width = rect.size.width;
    CGFloat childRight = width - viewParams.padding.right;
    
    CGFloat childSpace = width - paddingLeft - viewParams.padding.right;
    
    int count = (int)self.virtualChildCount;
    
    GravityMode majorGravity = _gravity & Gravity_VERTICAL_GRAVITY_MASK;
    GravityMode minorGravity = _gravity & Gravity_RELATIVE_HORIZONTAL_GRAVITY_MASK;
    
    switch (majorGravity)
    {
        case Gravity_BOTTOM:
            childTop = viewParams.padding.top + rect.size.height - _totalLength;
            break;
            
        case Gravity_CENTER_VERTICAL:
            childTop = viewParams.padding.top + (rect.size.height - _totalLength) / 2;
            break;
            
        case Gravity_TOP:
        default:
            childTop = viewParams.padding.top;
            break;
    }
    
    for (int i = 0; i < count; i++)
    {
        UIView* child = [self virtualChildAt:i];
        ViewParams* childViewParams = child.viewParams;
        if (!child)
        {
            childTop += [self measureNullChild:i];
        }
        else if(Visibility_GONE != childViewParams.visibility)
        {
            CGFloat childWidth  = childViewParams.measuredSize.width;
            CGFloat childHeight = childViewParams.measuredSize.height;
            
            LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
            
            int gravity = lp.layout_gravity;
            if (gravity < 0)
            {
                gravity = minorGravity;
            }
            LayoutDirectionMode layoutDirection = LayoutDirection_LTR;
            GravityMode absoluteGravity = [Gravity absoluteGravity:gravity layoutDirection:layoutDirection];
            switch (absoluteGravity & Gravity_HORIZONTAL_GRAVITY_MASK)
            {
                case Gravity_CENTER_HORIZONTAL:
                    childLeft = paddingLeft + ((childSpace - childWidth) / 2) + lp.layout_margin.left - lp.layout_margin.right;
                    break;
                    
                case Gravity_RIGHT:
                    childLeft = childRight - childWidth - lp.layout_margin.right;
                    break;
                    
                case Gravity_LEFT:
                default:
                    childLeft = paddingLeft + lp.layout_margin.left;
                    break;
            }
            
            if ([self hasDividerBeforeChildAt:i])
            {
                childTop += _dividerHeight;
            }
            
            childTop += lp.layout_margin.top;
            
            [self setChildFrame:child left:childLeft top:childTop+[self locationOffset:child] width:childWidth height:childHeight];
            
            childTop += childHeight + lp.layout_margin.bottom + [self nextLocationOffset:child];
            
            i += [self childrenSkipCount:child index:i];
        }
    }
}

- (void)layoutHorizontal:(CGRect)rect
{
    ViewParams* viewParams = self.viewParams;
    const BOOL isLayoutRtl = NO;//TODO:isLayoutRtl();
    const CGFloat paddingTop = viewParams.padding.top;
    
    CGFloat childTop;
    CGFloat childLeft;
    
    const CGFloat height = rect.size.height;
    CGFloat childBottom = height - viewParams.padding.bottom;
    
    CGFloat childSpace = height - paddingTop - viewParams.padding.bottom;
    
    const int count = (int)self.virtualChildCount;
    
    const GravityMode majorGravity = _gravity & Gravity_RELATIVE_HORIZONTAL_GRAVITY_MASK;
    const GravityMode minorGravity = _gravity & Gravity_VERTICAL_GRAVITY_MASK;
    
//    const BOOL baselineAligned = mBaselineAligned;
//    
//    const int[] maxAscent = mMaxAscent;
//    const int[] maxDescent = mMaxDescent;
    
    const LayoutDirectionMode layoutDirection = LayoutDirection_LTR;
    switch ([Gravity absoluteGravity:majorGravity layoutDirection:layoutDirection])
    {
        case Gravity_RIGHT:
            childLeft = viewParams.padding.left + rect.size.width - _totalLength;
            break;
            
        case Gravity_CENTER_HORIZONTAL:
            childLeft = viewParams.padding.left + (rect.size.width - _totalLength) / 2;
            break;
            
        case Gravity_LEFT:
        default:
            childLeft = viewParams.padding.left;
            break;
    }
    
    int start = 0;
    int dir = 1;

    if (isLayoutRtl)
    {
        start = count - 1;
        dir = -1;
    }
    
    for (int i = 0; i < count; i++)
    {
        const int childIndex = start + dir * i;
        UIView* child = [self virtualChildAt:i];
        ViewParams* childViewParams = child.viewParams;
        
        if (!child)
        {
            childLeft += [self measureNullChild:childIndex];
        }
        else if (Visibility_GONE != childViewParams.visibility)
        {
            const CGFloat childWidth  = childViewParams.measuredSize.width;
            const CGFloat childHeight = childViewParams.measuredSize.height;
            //int childBaseline = -1;
            
            const LinearLayoutParams* lp = (LinearLayoutParams*)child.layoutParams;
            
//            if (baselineAligned && lp.height != LayoutParams.MATCH_PARENT)
//            {
//                childBaseline = child.getBaseline();
//            }
            
            int gravity = lp.layout_gravity;
            if (gravity < 0)
            {
                gravity = minorGravity;
            }
            
            switch (gravity & Gravity_VERTICAL_GRAVITY_MASK)
            {
                case Gravity_TOP:
                    childTop = paddingTop + lp.layout_margin.top;
//                    if (childBaseline != -1)
//                    {
//                        childTop += maxAscent[INDEX_TOP] - childBaseline;
//                    }
                    break;
                    
                case Gravity_CENTER_VERTICAL:
                    // Removed support for baseline alignment when layout_gravity or
                    // gravity == center_vertical. See bug #1038483.
                    // Keep the code around if we need to re-enable this feature
                    // if (childBaseline != -1) {
                    //     // Align baselines vertically only if the child is smaller than us
                    //     if (childSpace - childHeight > 0) {
                    //         childTop = paddingTop + (childSpace / 2) - childBaseline;
                    //     } else {
                    //         childTop = paddingTop + (childSpace - childHeight) / 2;
                    //     }
                    // } else {
                    
                    childTop = paddingTop + ((childSpace - childHeight) / 2) + lp.layout_margin.top - lp.layout_margin.bottom;
                    break;
                    
                case Gravity_BOTTOM:
                    childTop = childBottom - childHeight - lp.layout_margin.bottom;
//                    if (childBaseline != -1)
//                    {
//                        int descent = child.getMeasuredHeight() - childBaseline;
//                        childTop -= (maxDescent[INDEX_BOTTOM] - descent);
//                    }
                    break;
                default:
                    childTop = paddingTop;
                    break;
            }
            
            if ([self hasDividerBeforeChildAt:childIndex])
            {
                childLeft += _dividerWidth;
            }
            
            childLeft += lp.layout_margin.left;
            
            [self setChildFrame:child left:childLeft + [self locationOffset:child] top:childTop width:childWidth height:childHeight];
            
            childLeft += childWidth + lp.layout_margin.right +
            [self nextLocationOffset:child];
            
            i += [self childrenSkipCount:child index:childIndex];
        }
    }
}

- (void)setChildFrame:(UIView*)child left:(CGFloat)left top:(CGFloat)top width:(CGFloat)width height:(CGFloat)height
{
    [child layout:CGRectMake(left, top, width, height)];
}

@end
