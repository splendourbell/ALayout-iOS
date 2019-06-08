//
//  ImageView.h
//  ALayout
//
//  Created by splendourbell on 2017/5/5.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Params.h"
#import "UIView+ALayout.h"

@class BitmapDrawable;

@interface ImageView : UIControl

@property (nonatomic) ScaleType scaleType;

@property (nonatomic) BOOL adjustViewBounds;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic) CGFloat maxWidth;

@property (nonatomic) CGFloat maxHeight;

@property (nonatomic) CGFloat aspectRatio; //图片宽高比

@property (nonatomic) BOOL roundAsCircle;

@property (nonatomic) UICornerRadius cornerRadius;

@property (nonatomic, strong) UIImage *defaultImage;


@end
