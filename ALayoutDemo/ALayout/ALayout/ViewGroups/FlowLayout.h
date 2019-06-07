//
//  FlowLayout.h
//  ALayout
//
//  Created by bell on 2017/6/4.
//  Copyright © 2017年 com.aiospace.zone. All rights reserved.
//

#import "ViewGroup.h"

@interface FlowLayout : ViewGroup

@property (nonatomic) GravityMode gravity;

@property (nonatomic) GravityMode rowGravity;

@property (nonatomic, strong, nonnull) UIScrollView* contentView;

@end
