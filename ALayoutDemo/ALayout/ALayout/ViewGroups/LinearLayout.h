//
//  LinearLayout.h
//  ALayout
//
//  Created by splendourbell on 2017/5/2.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "ViewGroup.h"
#import "Gravity.h"

@interface LinearLayout : ViewGroup

@property (nonatomic) OrientationMode orientation;

@property (nonatomic) GravityMode gravity;

@end
