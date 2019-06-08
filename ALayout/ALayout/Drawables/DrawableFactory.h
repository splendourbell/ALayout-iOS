//
//  DrawableFactory.h
//  ALayout
//
//  Created by splendourbell on 2017/5/4.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AttributeReader;
@class Drawable;

@interface DrawableFactory : NSObject

void RegisterDrawableClass(NSString* viewName, Class cls);

#define RegisterDrawable(drawableName) \
+ (void)load \
{\
    RegisterDrawableClass(@#drawableName, self);\
}

+ (Drawable*)createDrawable:(AttributeReader*)attrReader;

@end
