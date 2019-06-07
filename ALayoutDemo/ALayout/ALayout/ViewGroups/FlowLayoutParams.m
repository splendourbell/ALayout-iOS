//
//  FlowLayoutParams.m
//  ALayout
//
//  Created by bell on 2017/6/4.
//  Copyright © 2017年 com.aiospace.zone. All rights reserved.
//

#import "FlowLayoutParams.h"

@implementation FlowLayoutParams

- (void)parseAttr:(AttributeReader *)attrReader useDefault:(BOOL)useDefault
{
    [super parseAttr:attrReader useDefault:useDefault];
    ATTR_ReadAttrEq(_layout_gravity, A_layout_gravity, GravityMode, Gravity_NO_GRAVITY);
    ATTR_ReadAttrEq(_layout_widthPercent, A_layout_widthPercent, int, 0);
}

@end
