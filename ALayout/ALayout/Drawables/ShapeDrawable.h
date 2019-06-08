//
//  ShapeDrawable.h
//  ALayout
//
//  Created by Splendour Bell on 2017/5/13.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "Drawable.h"

typedef NS_ENUM(int, ShapeType)
{
    ShapeRectangle,
    ShapeOval,
    ShapeLine,
    ShapeRing
};

typedef NS_ENUM(int, GradientType)
{
    GradientLinear,
    GradientRadial,
    GradientSweep
};

@interface ShapeStroke : NSObject

@property (nonatomic) CGFloat width;

@property (nonatomic) UIColor* color;

@property (nonatomic) CGFloat dashWidth;

@property (nonatomic) CGFloat dashGap;

@end

@interface ShapeGradient : NSObject

/**
 渐变的角度，默认是0，其值必须是45的整数倍。0表示从左边到右，90表示从上到下。具体效果随着角度的调整而产生变化，角度影响渐变方向。
*/
@property (nonatomic) int angle;

@property (nonatomic) CGFloat centerX;

@property (nonatomic) CGFloat centerY;

@property (nonatomic) UIColor* centerColor;

@property (nonatomic) UIColor* endColor;

@property (nonatomic) CGFloat gradientRadius;

@property (nonatomic) UIColor* startColor;

@property (nonatomic) BOOL useLevel;

@end

@interface ShapeShadow : NSObject

@property (nonatomic) CGSize shadowOffset;

@property (nonatomic) CGFloat shadowOpacity;

@property (nonatomic) UIColor* shadowColor;

@property (nonatomic) CGFloat shadowRadius;

@end

@interface ShapeDrawable : Drawable

@property (nonatomic) ShapeType shape;

@property (nonatomic) UICornerRadius cornerRadius;

@property (nonatomic) UIEdgeInsets padding;

@property (nonatomic) CGSize size;

@property (nonatomic) UIColor* solidColor;

@property (nonatomic) ShapeStroke* stroke;

@property (nonatomic) ShapeGradient* gradient;

@property (nonatomic) ShapeShadow* shadow;

@property (nonatomic) CGFloat ringThickness;

@property (nonatomic) CGFloat ringInnerRadius;

@property (nonatomic) CGFloat ringInnerRadiusRatio;

@property (nonatomic) CGFloat ringThicknessRatio;

@property (nonatomic) BOOL ringUseLevel;

@end

