//
//  UIContentScrollView.h
//  ALayout
//
//  Created by bell on 2019/4/23.
//  Copyright © 2019 com.aiospace.zone. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIContentScrollView : UIScrollView

@property (nonatomic) void (^viewRemoved)(UIView* view);

@end

NS_ASSUME_NONNULL_END
