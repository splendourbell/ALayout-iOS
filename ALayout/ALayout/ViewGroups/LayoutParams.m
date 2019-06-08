//
//  LayoutParams.m
//  ALayout
//
//  Created by splendourbell on 2017/4/19.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "LayoutParams.h"
#import <objc/runtime.h>

@implementation LayoutParams

- (instancetype)initWithAttr:(AttributeReader*)attrReader
{
    if( self = [self init] )
    {
        [self parseAttr:attrReader useDefault:YES];
    }
    return self;
}

- (void)parseAttr:(AttributeReader*)attrReader useDefault:(BOOL)useDefault
{
    ATTR_ReadAttrEq(_layout_width, A_layout_width,  Dimension, LayoutParams_WRAP_CONTENT);
    ATTR_ReadAttrEq(_layout_height, A_layout_height, Dimension, LayoutParams_WRAP_CONTENT);
}

- (instancetype)initWithWidth:(CGFloat)width height:(CGFloat)height
{
    if( self = [self init] )
    {
        _layout_width  = width;
        _layout_height = height;
    }
    return self;
}

@end

@implementation UIView(LayoutParams)

static const void* KEY_layoutParams = &KEY_layoutParams;

- (__kindof LayoutParams*)layoutParams
{
    return objc_getAssociatedObject(self, KEY_layoutParams);
}

- (void)setLayoutParams:(LayoutParams*)layoutParams
{
    objc_setAssociatedObject(self, KEY_layoutParams, layoutParams, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
