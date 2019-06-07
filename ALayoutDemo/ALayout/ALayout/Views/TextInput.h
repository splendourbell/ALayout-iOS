//
//  TextInput.h
//  ASpace
//
//  Created by Peak.Liu on 2017/5/26.
//  Copyright © 2017年 com.aiospace.zone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIControl+Action.h"

extern const NSInteger UIControlEventEditingDidReturn;

@class Drawable;

@interface TextInput : UIView

@property (nonatomic, copy) NSString* text;

@property (nonatomic) Drawable      *textColorDrawable;

@property (nonatomic) CGFloat       textSize;               //设置文字大小,相当于字体size

@property (nonatomic) UIColor       *textColor;

@property (nonatomic, assign) NSTextAlignment textAlignment; //EditText没有这个属性，但TextView有，居中

@property (nonatomic) CGFloat       height;

@property (nonatomic) CGFloat       width;

@property (nonatomic, copy) NSString* typeface;             //TODO:默认系统字体 设置文本字体，必须是以下常量值之一：normal 0, sans 1, serif 2, monospace(等宽字体) 3]
@property (nonatomic) NSString      *textStyle;             //bold|italic

@property (nonatomic) NSUInteger    maxLength;              //最大输入字符串长

@property (nonatomic) NSString      *hint;                  //设置显示在空间上的提示信息

@property (nonatomic) NSString      *numberic;              //设置只能输入整数，如果是小数则是：decimal 整数 integer

@property (nonatomic) BOOL          password;               //设置只能输入密码

@property (nonatomic) BOOL          phoneNumber;            //输入电话号码

@property (nonatomic) UIColor       *textColorHighlight;    //被选中文字的底色

@property (nonatomic) BOOL          editable;               //是否可编辑

//"Default" "Go" "Google" "Join" "Next" "Route" "Search" "Send" "Yahoo" "Done" "EmergencyCall" "Continue"
@property (nonatomic) NSString*     returnKeyType;        //右下角按键样式

//"textUri","textEmailAddress","textPersonName","textPassword","numberPassword","number","numberSigned","numberDecimal","phone"
@property (nonatomic) NSString      *inputType;

@property (nonatomic) UITextFieldViewMode clearButtonMode;

@property (nonatomic) NSString* textFieldClass;
//TODO: textfield回调

- (UITextField *)textField;

- (BOOL)onEvent:(UIControlEvents)controlEvents action:(ControlEventBlock)actionBlock;

@end
