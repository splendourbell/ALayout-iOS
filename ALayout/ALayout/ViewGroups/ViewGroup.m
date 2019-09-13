//
//  ViewGroup.m
//  ALayout
//
//  Created by splendourbell on 2017/4/19.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "ViewGroup.h"
#import "Drawable.h"
#import "AViewCreator.h"

@implementation ViewGroup

- (void)measureChildWithMargins:(UIView*)child
                parentWidthSpec:(MeasureSpec)parentWidthSpec
                      widthUsed:(CGFloat)widthUsed
               parentHeightSpec:(MeasureSpec)parentHeightSpec
                     heightUsed:(CGFloat)heightUsed
{
    ViewParams* viewParams = self.viewParams;
    MarginLayoutParams* lp = (MarginLayoutParams*) child.layoutParams;
    
    CGFloat padding = 0;
    padding += viewParams.padding.left + viewParams.padding.right;
    padding += lp.layout_margin.left + lp.layout_margin.right;
    padding += widthUsed;
    
    MeasureSpec childWidthMeasureSpec  = [ViewGroup childMeasureSpec:parentWidthSpec
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

+ (MeasureSpec)childMeasureSpec:(MeasureSpec)spec padding:(CGFloat)padding childDimension:(CGFloat)childDimension
{
    CGFloat size = MAX(0, spec.size - padding);
    
    MeasureSpec resultSpec = {.size = 0, .mode = MeasureSpec_UNSPECIFIED};
    
    switch (spec.mode)
    {
        case MeasureSpec_EXACTLY:
            if (childDimension >= 0)
            {
                resultSpec.size = childDimension;
                resultSpec.mode = MeasureSpec_EXACTLY;
            }
            else if (LayoutParams_MATCH_PARENT == childDimension)
            {
                resultSpec.size = size;
                resultSpec.mode = MeasureSpec_EXACTLY;
            }
            else if (LayoutParams_WRAP_CONTENT == childDimension)
            {
                resultSpec.size = size;
                resultSpec.mode = MeasureSpec_AT_MOST;
            }
            break;
            
        case MeasureSpec_AT_MOST:
            if (childDimension >= 0)
            {
                resultSpec.size = childDimension;
                resultSpec.mode = MeasureSpec_EXACTLY;
            }
            else if (LayoutParams_MATCH_PARENT == childDimension)
            {
                resultSpec.size = size;
                resultSpec.mode = MeasureSpec_AT_MOST;
            }
            else if (LayoutParams_WRAP_CONTENT == childDimension)
            {
                resultSpec.size = size;
                resultSpec.mode = MeasureSpec_AT_MOST;
            }
            break;
            
        case MeasureSpec_UNSPECIFIED:
            if (childDimension >= 0)
            {
                resultSpec.size = childDimension;
                resultSpec.mode = MeasureSpec_EXACTLY;
            }
            else if (LayoutParams_MATCH_PARENT == childDimension)
            {
                resultSpec.size = size;//TODO:View.sUseZeroUnspecifiedMeasureSpec ? 0 : size;
                resultSpec.mode = MeasureSpec_UNSPECIFIED;
            }
            else if (LayoutParams_WRAP_CONTENT == childDimension)
            {
                resultSpec.size = size;//TODO:View.sUseZeroUnspecifiedMeasureSpec ? 0 : size;
                resultSpec.mode = MeasureSpec_UNSPECIFIED;
            }
            break;
    }
    return resultSpec;
}

- (void)setHighlighted:(BOOL)highlighted 
{
    [super setHighlighted:highlighted];
    for(UIControl* control in self.subviews) 
    {
        if([control isKindOfClass:UIControl.class])
        {
            if(!control.viewParams.clickable)
                control.highlighted = highlighted;
        }
    }
}

- (void)setEnabled:(BOOL)enabled 
{
    [super setEnabled:enabled];
    for(UIControl* control in self.subviews) 
    {
        if([control isKindOfClass:UIControl.class])
        {
            control.enabled = enabled;
        }
    }
}

- (void)setSelected:(BOOL)selected 
{
    [super setSelected:selected];
    for(UIControl* control in self.subviews) 
    {
        if([control isKindOfClass:UIControl.class])
        {
            control.selected = selected;
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
#ifdef DEBUG
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:@"ALayoutDebugClicked"];
    if(enable)
    {
        BOOL resetEnable = self.isEnabled;
        if(!self.isEnabled)
        {
            self.enabled = YES;
        }
        UIView* view = [super hitTest:point withEvent:event];
        if(self.isEnabled != resetEnable)
        {
            self.enabled = resetEnable;
        }
        if(self == view)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ALayoutViewClicked" object:view];
            return nil;
        }
    }
#endif
    UIView* view = [super hitTest:point withEvent:event];
    if(!self.viewParams.clickable && self == view)
    {
        view = nil;
    }
    return view;
}

- (void)addSubview:(UIView *)view
{
    [super addSubview:view];
    [self requestLayout];
}

- (void)dealloc 
{
    [self.viewParams.backgroud detach:self];
}

- (UIView*)addSubviewCreator:(AViewCreator*)viewCreator
{
    UIView* view = [viewCreator loadViewHierarchy];
    LayoutParams* layoutParams = [self generateLayoutParams:viewCreator.attrReader];
    view.layoutParams = layoutParams;
    [self addSubview:view];
    return view;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.viewParams.clickable) {
        [super touchesBegan:touches withEvent:event];
    }else{
        [[self nextResponder] touchesBegan:touches withEvent:event];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.viewParams.clickable) {
        [super touchesMoved:touches withEvent:event];
    }else{
        [[self nextResponder] touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.viewParams.clickable) {
        [super touchesEnded:touches withEvent:event];
    }else{
        [[self nextResponder] touchesEnded:touches withEvent:event];
    }
}


@end
