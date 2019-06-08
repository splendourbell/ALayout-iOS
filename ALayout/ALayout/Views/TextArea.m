//
//  TextArea.m
//  ALayout
//
//  Created by Peak.Liu on 2017/5/26.
//  Copyright © 2017年 com.aiospace.zone. All rights reserved.
//

#import "TextArea.h"
#import "Drawable.h"
#import "AViewCreator.h"
#import "UIView+Params.h"

@interface TextArea()<UITextViewDelegate>
{
    UITextView     *_textView;
    UIFont         *_font;
    
    CGSize         _contentSize;
    CGSize         _preTextSize;
}
@end

@implementation TextArea

RegisterView(TextArea)

- (UITextView *)textView
{
    if (!_textView)
    {
        UITextView *t       = [UITextView new];
        t.font              = self.font;
        t.textColor         = self.textColor;
        t.text              = self.text;
        t.textAlignment     = self.textAlignment;
        t.delegate          = self;
        t.showsHorizontalScrollIndicator    = NO;
        t.showsVerticalScrollIndicator      = NO;
        t.backgroundColor   = [UIColor clearColor];
        t.returnKeyType     = UIReturnKeyDefault;
    
        [self setTextView:t];
    }
    
    return _textView;
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

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    if (_textView)
    {
        _textView.textColor = textColor;
    }
}

- (void)setTextView:(UITextView *)textView
{
    [_textView removeFromSuperview];
    if (textView)
    {
        [self addSubview:textView];
    }
    _textView = textView;
}

- (void)parseAttr:(AttributeReader *)attrReader useDefault:(BOOL)useDefault
{
    [super parseAttr:attrReader useDefault:useDefault];
    
    if (ATTR_CanRead(A_textColor))
    {
        Drawable* textColorDrawable = ATTR_ReadAttr(A_textColor, Drawable, nil);
        if(textColorDrawable)
        {
            self.textColorDrawable = textColorDrawable;
        }
        else
        {
            self.textColor = UIColor.blackColor;
        }
    }
    
    if (ATTR_CanRead(A_ellipsize))
    {
        NSString* ellipsize = ATTR_ReadAttr(A_ellipsize, NSString, nil);
        if(StrEq(ellipsize, @"start"))
        {
            self.ellipsize = NSLineBreakByTruncatingHead;
        }
        else if(StrEq(ellipsize, @"end"))
        {
            self.ellipsize = NSLineBreakByTruncatingTail;
        }
        else if(StrEq(ellipsize, @"middle"))
        {
            self.ellipsize = NSLineBreakByTruncatingMiddle;
        }
        else
        {
            self.ellipsize = NSLineBreakByWordWrapping;
        }
    }
    
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
    
    ATTR_ReadAttrEq(_gravity,   A_gravity, GravityMode, Gravity_TOP | Gravity_LEFT);
    ATTR_ReadAttrEq(_text,      A_text,     TextString, nil);
    ATTR_ReadAttrEq(_textSize,  A_textSize,  Dimension, UIFont.systemFontSize);
    
    ATTR_ReadAttrEq(_width,     A_width,     Dimension,  INT_MIN);
    ATTR_ReadAttrEq(_height,    A_height,    Dimension,  INT_MIN);
    ATTR_ReadAttrEq(_maxWidth,  A_maxWidth,  Dimension,  INT_MAX);
    ATTR_ReadAttrEq(_maxHeight, A_maxHeight, Dimension,  INT_MAX);
    ATTR_ReadAttrEq(_minWidth,  A_minWidth,  Dimension,  0);
    ATTR_ReadAttrEq(_minHeight, A_minHeight, Dimension,  0);
    ATTR_ReadAttrEq(_typeface,  A_typeface,  NSString,   nil);
    ATTR_ReadAttrEq(_textStyle, A_textStyle, NSString,   nil);
    ATTR_ReadAttrEq(_lines,     A_lines,     int, -1);
    ATTR_ReadAttrEq(_maxLines,  A_maxLines,  int, INT_MAX);
    ATTR_ReadAttrEq(_minLines,  A_minLines,  int, 1);
    ATTR_ReadAttrEq(_maxLength, A_maxLength, int, INT_MAX);
    
    ATTR_ReadAttrEq(_shadowColor,  A_shadowColor,  UIColor, nil);
    ATTR_ReadAttrEq(_shadowDx,     A_shadowDx,     CGFloat, 0);
    ATTR_ReadAttrEq(_shadowDy,     A_shadowDy,     CGFloat, -3);
    ATTR_ReadAttrEq(_shadowRadius, A_shadowRadius, CGFloat, 0);
    
    _maxLines = MAX(self.maxLines, 0);
    _minLines = MAX(self.minLines, 0);
    _minLines = MIN(self.maxLines, self.minLines);
    if(_lines >= 0)
    {
        _lines = MIN(self.maxLines, self.lines);
        _lines = MAX(self.minLines, self.lines);
    }

    if(self.shadowColor)
    {
        self.layer.shadowColor = self.shadowColor.CGColor;
    }
    
    _textColorHint = ATTR_ReadAttr(textColorHint, UIColor, UIColor.darkGrayColor);
    _hint = ATTR_ReadAttr(hint, TextString, @"");
    
    self.layer.shadowOffset = CGSizeMake(self.shadowDx, self.shadowDy);
    self.layer.cornerRadius = self.shadowRadius;
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

- (void)setText:(NSString *)text
{
    if (_text != text)
    {
        _text = [text copy];
        [self requestLayout];
    }
}


- (void)onMeasure:(MeasureSpec)widthSpec heightSpec:(MeasureSpec)heightSpec
{
    self.userInteractionEnabled = YES;
    
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
    _contentSize        = CGSizeMake(textWidthSpec.size, textHeightSpec.size);
    
    if (_minLines > 1 && _minHeight < 0.001)
    {
        NSString *preStr = self.textView.text;
        CGPoint contentOffset = self.textView.contentOffset;
        NSMutableString *mineStr = [@" " mutableCopy];
        NSInteger index = 0;
        while (index < _minLines - 1) {
            [mineStr appendString:@"\n"];
            index++;
        }
        self.textView.text = mineStr;
        _minHeight = [self.textView sizeThatFits:CGSizeMake(textWidthSpec.size, 10000)].height;
        self.textView.text = preStr;
        self.textView.contentOffset = contentOffset;
    }
    
    if (_maxLines < INT_MAX && _maxLines > 0)
    {
        NSString *preStr = self.textView.text;
        CGPoint contentOffset = self.textView.contentOffset;
        NSMutableString *maxStr = [@" " mutableCopy];
        NSInteger index = 0;
        while (index < _maxLines - 1) {
            [maxStr appendString:@"\n"];
            index++;
        }
        
        self.textView.text = maxStr;
        _maxHeight = [self.textView sizeThatFits:CGSizeMake(textWidthSpec.size, CGFLOAT_MAX)].height;
        self.textView.text = preStr;
        self.textView.contentOffset = contentOffset;
    }
    
    if (_minHeight > 0)
    {
        CGSize contentSize = [self.textView contentSize];
        _contentSize.height = MAX(contentSize.height,_minHeight);
    }
    
    if (_maxHeight > 0)
    {
        _contentSize.height = MIN(_maxHeight, _contentSize.height);
    }
    
    computeWidth  += _contentSize.width;
    computeHeight += _contentSize.height;
    
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
    CGRect cFrame = CGRectMake(padding.left, padding.top, _contentSize.width, _contentSize.height);
    
    NSRange selectRange = self.textView.selectedRange;
    if (!CGRectEqualToRect(self.textView.frame, cFrame))
    {
        self.textView.frame = cFrame;
        [self.textView scrollRangeToVisible:selectRange];
    }
    //这个放在这会影响超过最大输入的中文输入
//     [self checkInputText];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [self.viewParams.backgroud detach:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)textDidChange:(NSNotification *)notify
{
    if (notify.object == self.textView)
    {
        NSString *lang = [[[UITextInputMode activeInputModes] firstObject] primaryLanguage];//当前的输入模式
        if ([lang isEqualToString:@"zh-Hans"] || [lang isEqualToString:@"zh-Hant"])
        {
            UITextRange *range = [_textView markedTextRange];
            
            UITextPosition *position = [_textView positionFromPosition:range.start offset:0];
            if (!position)
            {
                [self checkInputText];
            }
        }
        else
        {
            [self checkInputText];
        }
        
        
        [self checkTextViewFrame];
    }
}

- (void)checkTextViewFrame
{
    CGSize cSize =_textView.frame.size;
    CGSize newSize = [_textView sizeThatFits:CGSizeMake(cSize.width,MAXFLOAT)];
    
    if (fabs(_preTextSize.height - newSize.height) > 0.001)
    {
        _preTextSize = newSize;
        [self requestLayout];
    }
}

- (void)checkInputText
{
    NSRange selectRange = _textView.selectedRange;
    NSInteger length = _textView.text.length;
    if (length > _maxLength)
    {
        if (length > _maxLength + 5)
        {
            length = _maxLength + 5;
            _textView.text = [_textView.text substringToIndex:_maxLength + 5];
        }
    }
    
    if (self.textView.isFirstResponder == false)
    {
        self.placeHanderLabel.hidden = (length > 0);
    }
    else
    {
        self.placeHanderLabel.hidden = true;
    }
    
    if (selectRange.location + selectRange.length > _textView.text.length)
    {
        selectRange.length = 0;
        selectRange.location = _textView.text.length;
        _textView.selectedRange = selectRange;
        [_textView scrollRangeToVisible:_textView.selectedRange];
    }
}

#pragma --mark
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.placeHanderLabel.hidden = true;
    return true;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    self.placeHanderLabel.hidden = textView.text.length > 0;
    return true;
}

- (UILabel *)placeHanderLabel
{
    if (!_placeHanderLabel)
    {
        _placeHanderLabel = [UILabel new];
        [self addSubview:_placeHanderLabel];
        _placeHanderLabel.text      = self.hint;
        _placeHanderLabel.font      = self.font;
        _placeHanderLabel.textColor = self.textColorHint;
        [_placeHanderLabel sizeToFit];
        CGRect frame        = _placeHanderLabel.frame;
        frame.origin        = CGPointMake(2, 4);
        _placeHanderLabel.frame = frame;
    }
    
    return _placeHanderLabel;
}

- (id)inputView
{
    return _textView;
}

@end
