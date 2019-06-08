//
//  DrawableFactory.m
//  ALayout
//
//  Created by splendourbell on 2017/5/4.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "DrawableFactory.h"
#import "Drawable.h"

static NSMutableDictionary* DrawableClassRegisters = nil;

void RegisterDrawableClass(NSString* className, Class cls)
{
    if(!DrawableClassRegisters) DrawableClassRegisters = [NSMutableDictionary new];
#ifdef DEBUG
    //不能重复注册
    assert(!DrawableClassRegisters[className]);
#endif
    DrawableClassRegisters[className] = cls;
}

static Class drawableClass(NSString* className)
{
    Class cls = DrawableClassRegisters[className];
    
#ifdef DEBUG
    assert(className);
#endif
    
    if(!cls && className)
    {
        cls = NSClassFromString(className);
        DrawableClassRegisters[className] = cls;
    }
    return cls;
}

@implementation DrawableFactory

+ (Drawable*)createDrawable:(AttributeReader*)attrReader
{
    NSString* className = attrReader[@"class"];
    Class cls = drawableClass(className);
    Drawable* drawable = [cls new];
    [drawable parseAttr:attrReader];
    return drawable;
}

@end
