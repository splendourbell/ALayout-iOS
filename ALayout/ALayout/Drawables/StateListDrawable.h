//
//  StateListDrawable.h
//  ALayout
//
//  Created by splendourbell on 2017/5/11.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "Drawable.h"

@interface StateItem : NSObject

@property (nonatomic) NSMutableDictionary<NSNumber*, NSNumber*>* states;

@property (nonatomic) Drawable* drawable;

@end

@interface StateListDrawable : Drawable

//@property (nonatomic) BOOL constantSize;
//@property (nonatomic) BOOL dither;
//@property (nonatomic) BOOL variablePadding;

@end
