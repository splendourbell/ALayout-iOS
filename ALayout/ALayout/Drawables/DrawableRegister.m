//
//  DrawableRegister.m
//  ALayout
//
//  Created by splendourbell on 2017/5/4.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "DrawableRegister.h"
#import "BitmapDrawable.h"
#import "StateListDrawable.h"
#import "ColorDrawable.h"
#import "ShapeDrawable.h"

@implementation DrawableRegister

+ (void)load
{
    RegisterDrawableClass(@"bitmap",    BitmapDrawable.class);
    RegisterDrawableClass(@"selector",  StateListDrawable.class);
    RegisterDrawableClass(@"color",     ColorDrawable.class);
    RegisterDrawableClass(@"shape",     ShapeDrawable.class);
}

@end
