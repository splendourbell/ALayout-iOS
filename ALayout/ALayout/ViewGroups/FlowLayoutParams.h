//
//  FlowLayoutParams.h
//  ALayout
//
//  Created by bell on 2017/6/4.
//  Copyright © 2017年 com.aiospace.zone. All rights reserved.
//

#import "MarginLayoutParams.h"

@interface FlowLayoutParams : MarginLayoutParams

@property (nonatomic) GravityMode layout_gravity;

@property (nonatomic) CGFloat layout_widthPercent;

@end
