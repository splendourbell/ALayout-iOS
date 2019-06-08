//
//  MarginLayoutParams.m
//  RMLayout
//
//  Created by Splendour Bell on 2017/4/8.
//  Copyright © 2017年 ajja.sdjkf.sd. All rights reserved.
//

#import "MarginLayoutParams.h"

@implementation MarginLayoutParams


- (void)parseAttr:(AttributeReader *)attrReader useDefault:(BOOL)useDefault
{
    [super parseAttr:attrReader useDefault:useDefault];
    
    UIEdgeInsets layout_margin = UIEdgeInsetsZero;
    if (!useDefault)
    {
        layout_margin = self.layout_margin;
    }
    
    CGFloat margin = -1;
    ATTR_ReadAttrEq(margin, A_layout_margin, Dimension, -1);
    if(margin < 0)
    {
        ATTR_ReadAttrEq(layout_margin.top   , A_layout_marginTop,    Dimension, 0);
        ATTR_ReadAttrEq(layout_margin.left  , A_layout_marginLeft,   Dimension, 0);
        ATTR_ReadAttrEq(layout_margin.bottom, A_layout_marginBottom, Dimension, 0);
        ATTR_ReadAttrEq(layout_margin.right , A_layout_marginRight,  Dimension, 0);
    }
    else
    {
        layout_margin.top    = margin;
        layout_margin.left   = margin;
        layout_margin.bottom = margin;
        layout_margin.right  = margin;
    }
    
    self.layout_margin = layout_margin;
}
@end












