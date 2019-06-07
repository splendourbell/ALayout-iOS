//
//  ColorDrawable.m
//  ALayout
//
//  Created by splendourbell on 2017/5/4.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "ColorDrawable.h"
#import "AttributeKey.h"

@implementation ColorDrawable

- (void)parseAttr:(AttributeReader *)attrReader
{
    [super parseAttr:attrReader];
    _color = ATTR_ReadAttr(A_color, UIColor, UIColor.clearColor);
}

- (void)attachBackground:(CALayer*)layer stateView:(UIView*)stateView
{
    layer.backgroundColor = _color.CGColor;
}

- (void)attachUIColor:(id)hostView forKey:(NSString*)colorKey stateView:(UIView*)stateView
{
    [hostView setValue:_color forKey:colorKey];
}

@end
