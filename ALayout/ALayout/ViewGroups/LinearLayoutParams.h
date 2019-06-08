//
//  LinearLayoutParams.h
//  ALayout
//
//  Created by splendourbell on 2017/5/2.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "MarginLayoutParams.h"

@interface LinearLayoutParams : MarginLayoutParams

@property (nonatomic) CGFloat layout_weight;

@property (nonatomic) GravityMode layout_gravity;

@end
