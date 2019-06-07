//
//  ASliderView.m
//  lite
//
//  Created by splendourbell on 2019/3/20.
//  Copyright © 2019年 chelaile. All rights reserved.
//

#import "ASliderView.h"
#import "AttributeReader.h"
#import "UIView+Params.h"
#import "UIView+ALayout.h"

@interface ASliderView()<UIScrollViewDelegate>

@property (nonatomic) UIView* bgView;

@property (nonatomic) UIView* cacheView;

@property (nonatomic) UIView* usedView;

@property (nonatomic) UIView* indicatorView;

@property (nonatomic) UIScrollView* scrollView;

@property (nonatomic) BOOL scrollEnabled;

@end

@implementation ASliderView

- (void)parseAttr:(AttributeReader *)attrReader useDefault:(BOOL)useDefault
{
    [super parseAttr:attrReader useDefault:useDefault];

    ATTR_ReadAttrEq(self.bgColor,       bgColor,    UIColor,    nil);
    ATTR_ReadAttrEq(self.cacheColor,    cacheColor, UIColor,    nil);
    ATTR_ReadAttrEq(self.usedColor,     usedColor,  UIColor,    nil);
    ATTR_ReadAttrEq(self.thumbColor,    thumbColor, UIColor,    nil);
    
    ATTR_ReadAttrEq(self.height, height, Dimension, 2.0);
    ATTR_ReadAttrEq(self.thumbWidth, thumbWidth, Dimension, 6.0);
    if([attrReader hasKey:ValueKey(thumbHeight)])
    {
        ATTR_ReadAttrEq(self.thumbHeight, thumbHeight, Dimension, 6.0);
    }
    else
    {
        self.thumbHeight = self.thumbWidth;
    }
    
    ATTR_ReadAttrEq(self.scrollEnabled, A_scrollEnabled, BOOL, YES);
}

- (void)onLayout:(CGRect)rect
{
    CGRect bgRect = CGRectZero;
    bgRect.size.height = self.height;
    bgRect.origin.y = (rect.size.height - self.height) / 2;
    bgRect.size.width = rect.size.width;
    
    if(_bgColor) {
        if(!_bgView){
            _bgView = [[UIView alloc] initWithFrame:bgRect];
            [self addSubview:_bgView];
        }
        [self setViewBgColor:_bgColor forView:_bgView];
        [self setViewFrame:bgRect forView:_bgView];
    }
    
    if(_cacheColor) {
        CGRect aRect = bgRect;
        aRect.size.width = _cacheValue * rect.size.width;
        if(!_cacheView){
            _cacheView = [[UIView alloc] initWithFrame:aRect];
            [self addSubview:_cacheView];
        }
        else {
            [self setViewFrame:aRect forView:_cacheView];
        }
        [self setViewBgColor:_cacheColor forView:_cacheView];
    }
    
    if(_usedColor) {
        CGRect aRect = bgRect;
        aRect.size.width = _usedValue * rect.size.width;
        
        if(!_usedView){
            _usedView = [[UIView alloc] initWithFrame:aRect];
            [self addSubview:_usedView];
        } else {
            [self setViewFrame:aRect forView:_usedView];
        }
        [self setViewBgColor:_usedColor forView:_usedView];
    }
    
    if(_thumbColor) {
        CGRect aRect = rect;
        aRect.origin = CGPointZero;
        if(!_scrollView){
            _scrollView = [[UIScrollView alloc] initWithFrame:aRect];
            _scrollView.showsVerticalScrollIndicator = NO;
            _scrollView.showsHorizontalScrollIndicator = NO;
            _scrollView.delegate = self;
            _scrollView.bounces = NO;
            _scrollView.scrollEnabled = self.scrollEnabled;
            [self addSubview:_scrollView];
        }
        
        if(_scrollView.scrollEnabled != self.scrollEnabled)
        {
            _scrollView.scrollEnabled = self.scrollEnabled;
        }
        
        [self setViewFrame:aRect forView:_scrollView];
        
        CGSize contentSize = CGSizeMake(rect.size.width*2 - self.thumbWidth, aRect.size.height);
        
        if(!CGSizeEqualToSize(_scrollView.contentSize, contentSize)){
            _scrollView.contentSize = contentSize;
        }
        
        CGRect thumbRect = CGRectZero;
        thumbRect.size.width = self.thumbWidth;
        thumbRect.size.height = self.thumbHeight;
        thumbRect.origin.y = (rect.size.height - thumbRect.size.height) / 2;
        thumbRect.origin.x = rect.size.width - self.thumbWidth;
        
        CGFloat offset = (1-_usedValue) * (rect.size.width - thumbRect.size.width);
        CGPoint contetnOffset = _scrollView.contentOffset;
        contetnOffset.x = offset;
        
        if(!_indicatorView){
            _indicatorView = [[UIView alloc] initWithFrame:thumbRect];
            [_scrollView addSubview:_indicatorView];
        } else {
            [self setViewFrame:thumbRect forView:_indicatorView];
        }
        [self setViewBgColor:_thumbColor forView:_indicatorView];
        if(fabs(_indicatorView.layer.cornerRadius - thumbRect.size.height/2.0) > 0.00001) {
            _indicatorView.layer.cornerRadius = thumbRect.size.height/2.0; 
        }
        if(!CGPointEqualToPoint(_scrollView.contentOffset, contetnOffset)){
            _scrollView.contentOffset = contetnOffset;
        }
    }
}

- (void)setViewFrame:(CGRect)rect forView:(UIView*)view
{
    if(!CGRectEqualToRect(view.frame, rect)){
        view.frame = rect;
    }
}

- (void)setViewBgColor:(UIColor*)color forView:(UIView*)view
{
    if(color != view.backgroundColor){
        view.backgroundColor = color;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect rect = _usedView.frame;
    CGFloat totalWidth = scrollView.frame.size.width - _indicatorView.frame.size.width;
    rect.size.width = totalWidth - scrollView.contentOffset.x;
    _usedView.frame = rect;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    *targetContentOffset = scrollView.contentOffset;
    CGRect rect = _usedView.frame;
    CGFloat totalWidth = scrollView.frame.size.width - _indicatorView.frame.size.width;
    CGFloat usedValue = rect.size.width / totalWidth;
    if(self.progressChanged){
        self.progressChanged(usedValue);
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint offset = _scrollView.contentOffset;
    CGRect rect = _indicatorView.frame;
    if(point.x < rect.origin.x - offset.x - 10
       || point.x > CGRectGetMaxX(rect) - offset.x + 10
       ){
        return nil;
    } else {
        return [super hitTest:point withEvent:event];
    }
}

- (void)setCacheValue:(CGFloat)cacheValue
{
    if(cacheValue != _cacheValue)
    {
        _cacheValue = cacheValue;
        [self requestLayout];
    }
}

- (void)setUsedValue:(CGFloat)usedValue
{
    if(usedValue != _usedValue)
    {
        _usedValue = usedValue;
        [self onLayout:self.frame];
    }
}

@end
