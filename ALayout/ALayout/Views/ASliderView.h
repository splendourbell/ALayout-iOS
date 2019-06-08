//
//  ASliderView.h
//  lite
//
//  Created by splendourbell on 2019/3/20.
//  Copyright © 2019年 chelaile. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASliderView : UIView

@property (nonatomic) CGFloat cacheValue;

@property (nonatomic) CGFloat usedValue;

//ui property
@property (nonatomic) UIColor* bgColor;

@property (nonatomic) UIColor* cacheColor;

@property (nonatomic) UIColor* usedColor;

@property (nonatomic) CGFloat height;

@property (nonatomic) UIColor* thumbColor;

@property (nonatomic) CGFloat thumbWidth;

@property (nonatomic) CGFloat thumbHeight;

@property (nonatomic) void (^progressChanged)(CGFloat value);

@end

NS_ASSUME_NONNULL_END
