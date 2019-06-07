//
//  RelativeLayoutParams.h
//  ALayout
//
//  Created by splendourbell on 2017/4/11.
//  Copyright © 2017年 ajja.sdjkf.sd. All rights reserved.
//

#import "MarginLayoutParams.h"

typedef NS_ENUM(int, RelativeLayoutType)
{
    RelativeLayout_TRUE                     = -1,
    RelativeLayout_LEFT_OF                  = 0,
    RelativeLayout_RIGHT_OF                 = 1,
    RelativeLayout_ABOVE                    = 2,
    RelativeLayout_BELOW                    = 3,
    RelativeLayout_ALIGN_BASELINE           = 4,
    RelativeLayout_ALIGN_LEFT               = 5,
    RelativeLayout_ALIGN_TOP                = 6,
    RelativeLayout_ALIGN_RIGHT              = 7,
    RelativeLayout_ALIGN_BOTTOM             = 8,
    RelativeLayout_ALIGN_PARENT_LEFT        = 9,
    RelativeLayout_ALIGN_PARENT_TOP         = 10,
    RelativeLayout_ALIGN_PARENT_RIGHT       = 11,
    RelativeLayout_ALIGN_PARENT_BOTTOM      = 12,
    RelativeLayout_CENTER_IN_PARENT         = 13,
    RelativeLayout_CENTER_HORIZONTAL        = 14,
    RelativeLayout_CENTER_VERTICAL          = 15,
    RelativeLayout_START_OF                 = 16,
    RelativeLayout_END_OF                   = 17,
    RelativeLayout_ALIGN_START              = 18,
    RelativeLayout_ALIGN_END                = 19,
    RelativeLayout_ALIGN_PARENT_START       = 20,
    RelativeLayout_ALIGN_PARENT_END         = 21,
    RelativeLayout_VALUE_NOT_SET            = INT_MIN
};

typedef NSMutableDictionary<NSNumber*, id> RelativeRule;

@interface RelativeLayoutParams : MarginLayoutParams

@property (nonatomic) RelativeRule* rules;
@property (nonatomic) BOOL alignWithParent;
@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;

//- (instancetype)initWithAttr:(AttributeReader*)attrReader;

- (RelativeRule*)getRules:(int)layoutDirection;

- (void)setRule:(id)rule forType:(RelativeLayoutType)type;

@end
