//
//  LayoutDirection.h
//  RMLayout
//
//  Created by Splendour Bell on 2017/4/8.
//  Copyright © 2017年 ajja.sdjkf.sd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, LayoutDirectionMode)
{
    LayoutDirection_UNDEFINED   = -1,
    LayoutDirection_LTR         = 0,
    LayoutDirection_RTL         = 1,
    LayoutDirection_INHERIT     = 2,
    LayoutDirection_LOCALE      = 3
};
