//
//  MeasureSpec.h
//  ALayout
//
//  Created by splendourbell on 2017/4/19.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(unsigned char, MeasureSpecMode)
{
    MeasureSpec_UNSPECIFIED = 0,
    MeasureSpec_EXACTLY     = 1,
    MeasureSpec_AT_MOST     = 2
};

typedef struct MeasureSpec
{
    CGFloat         size;
    MeasureSpecMode mode;
} MeasureSpec;
