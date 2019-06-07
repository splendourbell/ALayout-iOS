//
//  BitmapDrawable.h
//  ALayout
//
//  Created by splendourbell on 2017/5/3.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "Drawable.h"

typedef NS_ENUM(int, TileMode)
{
    TILE_MODE_UNDEFINED = -2,
    TILE_MODE_DISABLED  = -1,
    TILE_MODE_CLAMP     = 0,
    TILE_MODE_REPEAT    = 1,
    TILE_MODE_MIRROR    = 2
};

@interface BitmapDrawable : Drawable

@property (nonatomic) UIImage* image;

@property (nonatomic) BOOL antialias;

@property (nonatomic) TileMode tileMode;

- (void)setSrc:(NSString*)src;

@end
