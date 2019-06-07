//
//  Button.m
//  ALayout
//
//  Created by splendourbell on 2017/5/3.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "Button.h"
#import "AttributeReader.h"
#import "UIView+Params.h"

@implementation Button

- (NSMutableDictionary*)defaultStyle
{
    NSMutableDictionary* defaultStyle = super.defaultStyle;
    
    [defaultStyle addEntriesFromDictionary:@{
             ValueKey(A_clickable) : @"true",
             ValueKey(A_gravity)   : @"center"
             }];
    
    return defaultStyle;
}

@end
