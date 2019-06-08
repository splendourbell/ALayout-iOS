//
//  AttributeReader+Gravity.m
//  ALayout
//
//  Created by splendourbell on 2017/4/25.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "AttributeReader+Gravity.h"

@implementation AttributeReader(Gravity)

- (GravityMode)read_GravityMode_imp:(NSString*)key default:(GravityMode)defValue
{
    static NSDictionary<NSString*, NSNumber*>* modeMap = nil;
    if(!modeMap)
    {
        modeMap = @{
            @"bottom":@(Gravity_BOTTOM),
            @"fill":@(Gravity_FILL),
            @"center":@(Gravity_CENTER),
            @"center_horizontal":@(Gravity_CENTER_HORIZONTAL),
            @"center_vertical":@(Gravity_CENTER_VERTICAL),
            @"clip_horizontal":@(Gravity_CLIP_HORIZONTAL),
            @"clip_vertical":@(Gravity_CLIP_VERTICAL),
            @"end":@(Gravity_END),
            @"fill_horizontal":@(Gravity_FILL_HORIZONTAL),
            @"fill_vertical":@(Gravity_FILL_VERTICAL),
            @"left":@(Gravity_LEFT),
            @"right":@(Gravity_RIGHT),
            @"start":@(Gravity_START),
            @"top":@(Gravity_TOP)
        };
    }
    NSString* modeStr = self[key];
    NSArray* modeStrArray = [modeStr componentsSeparatedByString:@"|"];
    
    GravityMode mode = Gravity_NO_GRAVITY;
    for(NSString* modeItemStr in modeStrArray)
    {
        NSNumber* modeNumber = modeMap[modeItemStr];
        if(modeNumber)
        {
            mode |= modeNumber.intValue;
        }
    }
    
    return (Gravity_NO_GRAVITY != mode) ? mode : defValue;
}

@end
