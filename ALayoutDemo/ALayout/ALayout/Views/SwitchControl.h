//
//  SwitchControl.h
//  ALayout
//
//  Created by Peak.Liu on 2017/6/20.
//  Copyright © 2017年 com.aiospace.zone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchControl : UIControl

@property (nonatomic, getter=isOn) BOOL on;

@property (nullable, nonatomic, strong) UIImage *onImage;

@property (nullable, nonatomic, strong) UIImage *offImage;

@property (nullable, nonatomic, strong) UIColor *onTintColor;

@property (assign, nonatomic) CGFloat scale;

@property (nonatomic, copy) void(^ _Nullable valueChanged)(UISwitch * _Nonnull switchView);

@end
