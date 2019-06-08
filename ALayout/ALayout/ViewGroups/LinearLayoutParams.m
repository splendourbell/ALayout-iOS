//
//  LinearLayoutParams.m
//  ALayout
//
//  Created by splendourbell on 2017/5/2.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "LinearLayoutParams.h"

@implementation LinearLayoutParams

- (void)parseAttr:(AttributeReader *)attrReader useDefault:(BOOL)useDefault
{
    [super parseAttr:attrReader useDefault:useDefault];
    ATTR_ReadAttrEq(_layout_gravity, A_layout_gravity, GravityMode, -1);
    ATTR_ReadAttrEq(_layout_weight, A_layout_weight, CGFloat, 0);
}

@end
