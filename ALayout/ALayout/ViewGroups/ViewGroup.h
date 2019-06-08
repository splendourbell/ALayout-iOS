//
//  ViewGroup.h
//  ALayout
//
//  Created by splendourbell on 2017/4/19.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+ALayout.h"
#import "UIView+Params.h"
#import "MarginLayoutParams.h"

@class AViewCreator;

@interface ViewGroup : UIControl

- (void)measureChildWithMargins:(UIView*)child
                parentWidthSpec:(MeasureSpec)parentWidthSpec
                      widthUsed:(CGFloat)widthUsed
               parentHeightSpec:(MeasureSpec)parentHeightSpec
                     heightUsed:(CGFloat)heightUsed;

+ (MeasureSpec)childMeasureSpec:(MeasureSpec)spec padding:(CGFloat)padding childDimension:(CGFloat)childDimension;

- (UIView*)addSubviewCreator:(AViewCreator*)viewCreator;

@end
