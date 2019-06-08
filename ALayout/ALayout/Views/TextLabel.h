//
//  TextLabel.h
//  ALayout
//
//  Created by splendourbell on 2017/4/25.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Gravity.h"

@class Drawable;

@interface TextLabel : UIControl

@property (nonatomic, copy) NSString* text;

@property (nonatomic, copy) NSAttributedString* attributedText;

@property (nonatomic, strong) UIColor* textColor;

@property (nonatomic, strong) Drawable* textColorDrawable;

@property (nonatomic) CGFloat textSize;//设置文字大小,相当于字体size

@property (nonatomic, assign) NSLineBreakMode ellipsize;

@property (nonatomic, assign) NSTextAlignment textAlignment;

@property (nonatomic) CGFloat height;//设置文本区域的高度
@property (nonatomic) CGFloat width;//设置文本区域的宽度;
@property (nonatomic) CGFloat maxHeight;//设置文本区域的最大高度
@property (nonatomic) CGFloat minHeight;//设置文本区域的最小高度
@property (nonatomic) CGFloat maxWidth;//设置文本区域的最大宽度
@property (nonatomic) CGFloat minWidth;//设置文本区域的最小宽度
@property (nonatomic, copy) NSString* typeface;//TODO:默认系统字体 设置文本字体，必须是以下常量值之一：normal 0, sans 1, serif 2, monospace(等宽字体) 3]

@property (nonatomic, copy) NSString* textStyle;//bold|italic

@property (nonatomic, strong) UIColor* shadowColor;//设置阴影颜色;
@property (nonatomic) CGFloat shadowDx;//设置阴影横向坐标开始位置
@property (nonatomic) CGFloat shadowDy;//设置阴影纵向坐标开始位置
@property (nonatomic) CGFloat shadowRadius;//设置阴影的半径

@property (nonatomic) int lines;//注意 -1 为无限行，
@property (nonatomic) int maxLines;//最大行数
@property (nonatomic) int minLines;//最小行数
@property (nonatomic) int contentLines;//多行文本=返回完整内容所占行数；单行文本=1

@property (nonatomic) CGFloat lineSpacingExtra; //行间距

@property (nonatomic) GravityMode gravity;

@property (nonatomic) NSUInteger maxLength; //重置后需要重新设置text or attributedString

@property (nonatomic, strong) CALayer* drawableTop;
@property (nonatomic, strong) CALayer* drawableLeft;
@property (nonatomic, strong) CALayer* drawableBottom;
@property (nonatomic, strong) CALayer* drawableRight;
@property (nonatomic) CGFloat  drawablePadding;

@property (nonatomic, readonly) CGRect contentRect;

@end

