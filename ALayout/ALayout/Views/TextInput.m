//
//  TextInput.m
//  ASpace
//
//  Created by Peak.Liu on 2017/5/26.
//  Copyright © 2017年 com.aiospace.zone. All rights reserved.
//

#import "TextInput.h"
#import <ALayout/ALayout.h>
#import "Drawable.h"

const NSInteger UIControlEventEditingDidReturn = (1<<25);
const NSInteger UIControlEventWillBeginEditing = (1<<26);

@interface TextInput ()<UITextFieldDelegate>
{
    UITextField     *_textField;
    UIFont          *_font;
    
    UIKeyboardType  keyBoardType;
    BOOL            isPassWord;
    
    NSString        *_parseText;
    UIReturnKeyType _returnKeyTypeEnum;
    
    ControlEventBlock  _textFieldShouldReturnBlock;
    ControlEventBlock  _textFieldShouldBeginEditing;
}
@end

@implementation TextInput

RegisterView(TextInput)

- (UITextField *)textField
{
    if (!_textField)
    {
        UITextField *t  = nil;
        if(_textFieldClass.length){
            Class cls = NSClassFromString(_textFieldClass);
            t = [[cls alloc] init];
        }
        t = t ?: UITextField.new;
        
        t.delegate      = self;
        t.returnKeyType = _returnKeyTypeEnum;
        t.text          = _parseText;
        [self setTextField:t];
    }
    
    return _textField;
}

- (void)setTextSize:(CGFloat)textSize
{
    if(_textSize != textSize)
    {
        _textSize = textSize;
        _font = nil;
        [self requestLayout];
    }
}

- (UIFont*)font
{
    if(!_font)
    {
        if(_textSize <= 0)
        {
            _textSize = UIFont.systemFontSize;
        }
        if(StrEq(@"bold", _textStyle))
        {
            _font = [UIFont boldSystemFontOfSize:_textSize];
        }
        else if(StrEq(@"italic", _textStyle))
        {
            _font = [UIFont italicSystemFontOfSize:_textSize];
        }
        else if(!_typeface)
        {
            _font = [UIFont systemFontOfSize:_textSize];
        }
        else
        {
            _font = [UIFont fontWithName:_typeface size:_textSize];
        }
    }
    return _font;
}

- (void)setTextColorDrawable:(Drawable *)textColorDrawable
{
    _textColorDrawable = textColorDrawable;
    
    if(textColorDrawable)
    {
        __weak typeof(self) weakSelf = self;
        [self addDidLayoutBlock:@"TextLabel_textColorDrawable" block:^(CGRect rect) {
            id strongSelf = weakSelf;
            if(strongSelf)
            {
                [textColorDrawable attachUIColor:strongSelf forKey:@"textColor" stateView:strongSelf];
            }
        }];
    }
    else
    {
        [self removeDidLayoutBlock:@"TextLabel_textColorDrawable"];
    }
}

- (void)setText:(NSString *)text
{
    if (text.length > _maxLength)
    {
        text = [text substringToIndex:_maxLength];
    }
    [self requestLayout];
    _parseText = text;
    self.textField.text = text;
}

- (NSString*)text
{
    return self.textField.text;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    if (textColor)
    {
        self.textField.textColor = textColor;
    }
}

- (void)setTextField:(UITextField *)textField
{
    if(_textField != textField)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:textField];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:UITextFieldTextDidChangeNotification object:textField];
        
        [_textField removeFromSuperview];
        if (textField)
        {
            [self addSubview:textField];
        }
        _textField = textField;
    }
}

- (void)setClearButtonMode:(UITextFieldViewMode)clearButtonMode
{
    self.textField.clearButtonMode = clearButtonMode;
}

- (UITextFieldViewMode)clearButtonMode
{
    return self.textField.clearButtonMode;
}

- (void)setReturnKeyType:(NSString *)returnKeyType
{
    returnKeyType = returnKeyType?: @"Done";
    NSArray* typeArr = @[@"Default", @"Go", @"Google", @"Join", @"Next", @"Route", @"Search", @"Send", @"Yahoo", @"Done", @"EmergencyCall",@"Continue"];
    _returnKeyTypeEnum = (UIReturnKeyType)[typeArr indexOfObject:returnKeyType];
    if(_textField)
    {
        _textField.returnKeyType = _returnKeyTypeEnum;
    }
}

-(void)setTextAlignment:(NSTextAlignment)textAlignment
{
    self.textField.textAlignment = textAlignment;
}

- (void)parseAttr:(AttributeReader *)attrReader useDefault:(BOOL)useDefault
{
    [super parseAttr:attrReader useDefault:useDefault];
    
    self.userInteractionEnabled = YES;
    
    ATTR_ReadAttrEq(_textFieldClass, A_textFieldClass, NSString, nil);
    ATTR_ReadAttrEq(_parseText,      A_text,     TextString, @"");
    ATTR_ReadAttrEq(_textSize,  A_textSize, Dimension,  UIFont.systemFontSize);
    ATTR_ReadAttrEq(self.textColorDrawable, A_textColor, Drawable, self.textColorDrawable);
    
    if (ATTR_CanRead(A_textAlignment))
    {
        NSString* textAlignment = ATTR_ReadAttr(A_textAlignment, NSString, nil);
        if(StrEq(textAlignment, @"textStart"))
        {
            self.textAlignment = NSTextAlignmentLeft;
        }
        else if(StrEq(textAlignment, @"textEnd"))
        {
            self.textAlignment = NSTextAlignmentRight;
        }
        else if(StrEq(textAlignment, @"center"))
        {
            self.textAlignment = NSTextAlignmentCenter;
        }
        else
        {
            self.textAlignment = NSTextAlignmentLeft;
        }
    }

    ATTR_ReadAttrEq(_width,     A_width,     Dimension,  INT_MIN);
    ATTR_ReadAttrEq(_height,    A_height,    Dimension,  INT_MIN);
    ATTR_ReadAttrEq(_typeface,  A_typeface,  NSString,   nil);
    ATTR_ReadAttrEq(_textStyle, A_textStyle, NSString,   nil);
    ATTR_ReadAttrEq(_maxLength, A_maxLength, int, INT_MAX);
    
    ATTR_ReadAttrEq(_hint,               A_hint, NSString, nil);
    ATTR_ReadAttrEq(_textColorHighlight, A_textColorHighlight, UIColor, nil);
    ATTR_ReadAttrEq(_editable,           A_editable, BOOL, YES);
    
    ATTR_ReadAttrEq(_numberic,    A_numberic, NSString, nil);
    ATTR_ReadAttrEq(_password,    A_password, BOOL, NO);
    ATTR_ReadAttrEq(_phoneNumber, A_phoneNumber, BOOL, NO);
    ATTR_ReadAttrEq(_inputType,   A_inputType, NSString, nil);
    
    NSString* clearButtonModeText = nil;
    ATTR_ReadAttrEq(clearButtonModeText,   A_clearButtonMode, NSString, nil);
    
    if(clearButtonModeText.length)
    {
        NSArray<NSString*>* modeArray = @[@"Never", @"WhileEditing", @"UnlessEditing", @"Always"];
        NSUInteger index = [modeArray indexOfObject:clearButtonModeText];
        if(index >= 0 && index < modeArray.count)
        {
            self.clearButtonMode = (UITextFieldViewMode)index;
        }
    }    
    
    NSString* returnKeyTypeStr = nil;
    
    ATTR_ReadAttrEq(returnKeyTypeStr,   returnKeyType, NSString, @"Done");
    self.returnKeyType = returnKeyTypeStr;
    
    keyBoardType       = UIKeyboardTypeDefault;
    
    if (!_inputType)
    {
        if (_numberic.length > 0)
        {
            if ([_numberic isEqualToString:@"decimal"])
            {
                keyBoardType = UIKeyboardTypeDecimalPad;
            }
            else if ([_numberic isEqualToString:@"integer"])
            {
                keyBoardType = UIKeyboardTypeNumberPad;
            }
        }
        else if (_phoneNumber)
        {
            keyBoardType = UIKeyboardTypePhonePad;
        }
    }
    else
    {
        if ([_inputType isEqualToString:@"textUri"])
        {
            keyBoardType = UIKeyboardTypeURL;
        }
        if ([_inputType isEqualToString:@"textEmailAddress"])
        {
            keyBoardType = UIKeyboardTypeEmailAddress;
        }
        else if ([_inputType isEqualToString:@"textPersonName"])
        {
            keyBoardType = UIKeyboardTypeNamePhonePad;
        }
        else if ([_inputType isEqualToString:@"textPassword"])
        {
            isPassWord = true;
        }
        else if ([_inputType isEqualToString:@"numberPassword"])
        {
            isPassWord = true;
            keyBoardType = UIKeyboardTypeNumberPad;
        }
        else if ([_inputType isEqualToString:@"number"])
        {
            keyBoardType = UIKeyboardTypeNumberPad;
        }
        else if ([_inputType isEqualToString:@"numberSigned"])
        {
            keyBoardType = UIKeyboardTypeNumbersAndPunctuation;
        }
        else if ( [_inputType isEqualToString:@"numberDecimal"])
        {
            keyBoardType = UIKeyboardTypeDecimalPad;
        }
        else if ([_inputType isEqualToString:@"phone"])
        {
            keyBoardType = UIKeyboardTypePhonePad;
        }
    }
}

- (void)onMeasure:(MeasureSpec)widthSpec heightSpec:(MeasureSpec)heightSpec
{
    UIEdgeInsets padding = self.viewParams.padding;
    
    CGFloat computeWidth  = padding.left + padding.right;
    CGFloat computeHeight = padding.top  + padding.bottom;
    
    CGFloat width  = 0;
    CGFloat height = 0;
    
    CGFloat maxAvailableWidth  = widthSpec.size;
    CGFloat maxAvailableHeight = heightSpec.size;
    
    MeasureSpec textWidthSpec;
    MeasureSpec textHeightSpec;
    
    maxAvailableWidth  -= computeWidth;
    maxAvailableHeight -= computeHeight;
    
    maxAvailableWidth   = MAX(0, maxAvailableWidth);
    maxAvailableHeight  = MAX(0, maxAvailableHeight);
    
    if(MeasureSpec_EXACTLY == widthSpec.mode)
    {
        width = widthSpec.size;
        textWidthSpec.mode = MeasureSpec_EXACTLY;
    }
    else
    {
        textWidthSpec.mode = MeasureSpec_AT_MOST;
    }
    textWidthSpec.size = maxAvailableWidth;
    
    if(MeasureSpec_EXACTLY == heightSpec.mode)
    {
        height = heightSpec.size;
        textHeightSpec.mode = MeasureSpec_EXACTLY;
    }
    else
    {
        textHeightSpec.mode = MeasureSpec_AT_MOST;
    }
    
    textHeightSpec.size = maxAvailableHeight;
    
    if(MeasureSpec_EXACTLY != widthSpec.mode)
    {
        widthSpec.mode = MeasureSpec_EXACTLY;
        width = computeWidth;
    }
    
    if(MeasureSpec_EXACTLY != heightSpec.mode)
    {
        heightSpec.mode = MeasureSpec_EXACTLY;
        height = computeHeight;
    }
    
    [self setMeasuredDimensionRaw:CGSizeMake(width, height)];
}

- (void)onLayout:(CGRect)rect
{
    UIEdgeInsets padding = self.viewParams.padding;
    CGSize measuredSize = self.viewParams.measuredSize;

    UITextField *textField      = [self textField];
    textField.secureTextEntry   = isPassWord;
    textField.keyboardType      = keyBoardType;
    textField.enabled           = self.editable;
    textField.placeholder       = self.hint;
    textField.font              = self.font;
    textField.frame = CGRectMake(padding.left, padding.top, measuredSize.width - padding.left - padding.right, measuredSize.height - padding.top - padding.bottom);
}

- (void)setSecureTextEntry:(BOOL)secure
{
    [self textField].secureTextEntry = secure;
}

- (BOOL)secureTextEntry
{
    return [self textField].secureTextEntry;
}

- (void)setKeyboardType:(UIKeyboardType)type
{
    keyBoardType = type;
    self.textField.keyboardType = type;
}

- (UIKeyboardType)keyboardType
{
    return self.textField.keyboardType;
}


- (void)textFiledEditChanged:(NSNotification*)notification 
{  
    UITextField* textField = notification.object;
    if(textField == _textField)
    {
        UITextRange *selectedRange = textField.markedTextRange;  
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];  
        
        if (!position) 
        {
            if (textField.text.length > _maxLength)
            {
                textField.text = [textField.text substringToIndex:_maxLength];
            }
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(_textFieldShouldReturnBlock)
    {
        _textFieldShouldReturnBlock(textField, nil);
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(_textFieldShouldBeginEditing)
    {
        NSLog(@"_textFieldShouldBeginEditing");
        _textFieldShouldBeginEditing(textField, nil);
    }
    return YES;
}

#pragma mark textfield delegate
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    UITextRange *selectedRange = textField.markedTextRange;  
//    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];  
//    
//    if (!position)
//    {
//        
//    }
//    NSString *checkText = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    if (checkText.length > _maxLength)
//    {
//        return NO;
//    }
//    
//    return true;
//}


- (id)inputView
{
    return _textField;
}

- (BOOL)becomeFirstResponder
{
    return [self.textField becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return [self.textField canBecomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    return [self.textField resignFirstResponder];
}


- (BOOL)onEvent:(UIControlEvents)controlEvents action:(ControlEventBlock)actionBlock
{
    if(UIControlEventEditingDidReturn == controlEvents)
    {
        _textFieldShouldReturnBlock = actionBlock;
        return YES;
    }
    else if(UIControlEventWillBeginEditing == controlEvents)
    {
        _textFieldShouldBeginEditing = actionBlock;
        return YES;
    }
    return [self.textField onEvent:controlEvents action:actionBlock];
}

- (void)dealloc
{
    [self.viewParams.backgroud detach:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString*)mainKey
{
    return ValueKey(A_text);
}

DEF_NEEDLAYOUT_SETTER(CGFloat,         Height,        height)
DEF_NEEDLAYOUT_SETTER(CGFloat,         Width,         width)
@end


//Android:hint="请输入数字！"//设置显示在空间上的提示信息
//
//Android:numeric="integer"//设置只能输入整数，如果是小数则是：decimal
//android:password="true"//设置只能输入密码
//
////android:textColorHighlight="#cccccc"//被选中文字的底色，默认为蓝色
//
//android:layout_weight="1"//权重，控制控件之间的地位,在控制控件显示的大小时蛮有用的。
//android:textAppearance="?android:attr/textAppearanceLargeInverse"//文字外观
//android:layout_gravity="center_vertical"//设置控件显示的位置：默认top，这里居中显示，还有bottom
//
//android：phoneNumber //输入电话号码
//
//android：editable //是否可编辑

//inputType
/*
 android:inputType="none"--输入普通字符
 
 android:inputType="text"--输入普通字符
 
 android:inputType="textCapCharacters"--输入普通字符
 
 android:inputType="textCapWords"--单词首字母大小
 
 android:inputType="textCapSentences"--仅第一个字母大小
 
 android:inputType="textAutoCorrect"--前两个自动完成
 
 android:inputType="textAutoComplete"--前两个自动完成
 
 android:inputType="textMultiLine"--多行输入
 
 android:inputType="textImeMultiLine"--输入法多行（不一定支持）
 
 android:inputType="textNoSuggestions"--不提示
 
 android:inputType="textUri"--URI格式
 
 android:inputType="textEmailAddress"--电子邮件地址格式
 
 android:inputType="textEmailSubject"--邮件主题格式
 
 android:inputType="textShortMessage"--短消息格式
 
 android:inputType="textLongMessage"--长消息格式
 
 android:inputType="textPersonName"--人名格式
 
 android:inputType="textPostalAddress"--邮政格式
 
 android:inputType="textPassword"--密码格式
 
 android:inputType="textVisiblePassword"--密码可见格式
 
 android:inputType="textWebEditText"--作为网页表单的文本格式
 
 android:inputType="textFilter"--文本筛选格式
 
 android:inputType="textPhonetic"--拼音输入格式
 
 android:inputType="number"--数字格式
 
 android:inputType="numberSigned"--有符号数字格式
 
 android:inputType="numberDecimal"--可以带小数点的浮点格式
 
 android:inputType="phone"--拨号键盘
 
 android:inputType="datetime"
 
 android:inputType="date"--日期键盘
 
 android:inputType="time"--时间键盘
 */
