//
//  TextLabel.m
//  ALayout
//
//  Created by splendourbell on 2017/4/25.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "TextLabel.h"
#import "UIView+ALayout.h"
#import "UIView+Params.h"
#import "Drawable.h"
#import <CoreText/CoreText.h>

@interface ViewParams(measuredSizePri)
@property (nonatomic, readwrite) CGSize measuredSize;
@end

@implementation TextLabel
{
    UIFont* _font;
    
    UILabel* _textLabel;
    BOOL _needResetTextLabel;
    CGSize _textLabelContentSize;
    
    NSMutableAttributedString* _textAttributedString;
    
    BOOL        _needStrBounds;
    CGRect      _strBounds;
    CGSize      _strBaseSize;
    CGRect      _realBounds;
}

- (void)requestLayout
{
    _needStrBounds = true;
    [super requestLayout];
}

- (void)setTextColorDrawable:(Drawable *)textColorDrawable
{
    _textColorDrawable = textColorDrawable;
    
    if(textColorDrawable)
    {
        __weak typeof(self) weakSelf = self;
        __weak Drawable* weak_textColorDrawable = textColorDrawable;
        [self addDidLayoutBlock:@"TextLabel_textColorDrawable" block:^(CGRect rect) {
            id strongSelf = weakSelf;
            Drawable* strong_textColorDrawable = weak_textColorDrawable;
            if(strongSelf && strong_textColorDrawable)
            {
                [strong_textColorDrawable attachUIColor:strongSelf forKey:@"textColor" stateView:strongSelf];
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
    if (_text)
    {
        if(_textAttributedString)
        {
            [_textAttributedString addAttribute:NSForegroundColorAttributeName value:self.textColor range:NSMakeRange(0, _textAttributedString.length)];
            self.textLabel.attributedText = self.textAttributedString;
        }
    }
}

- (void)parseAttr:(AttributeReader *)attrReader useDefault:(BOOL)useDefault
{
    [super parseAttr:attrReader useDefault:useDefault];
    
    ATTR_ReadAttrEq(_text,       A_text,        TextString, nil);
    ATTR_ReadAttrEq(_textSize,   A_textSize,    Dimension,  UIFont.systemFontSize);
    ATTR_ReadAttrEq(_gravity,    A_gravity,     GravityMode, Gravity_TOP | Gravity_LEFT);
    
    if (ATTR_CanRead(A_textSize))
    {   
        _textSize = ATTR_ReadAttr(A_textSize, Dimension, UIFont.systemFontSize);
        if(attrReader.resourceManager.fontScale) {
            _textSize = attrReader.resourceManager.fontScale(_textSize);
        }
    }
    
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
    
    ATTR_ReadAttrEq(_width,      A_width,     Dimension,  INT_MIN);
    ATTR_ReadAttrEq(_height,     A_height,    Dimension,  INT_MIN);
    ATTR_ReadAttrEq(_maxWidth,   A_maxWidth,  Dimension,  INT_MAX);
    ATTR_ReadAttrEq(_maxHeight,  A_maxHeight, Dimension,  INT_MAX);
    ATTR_ReadAttrEq(_minWidth,   A_minWidth,  Dimension,  0);
    ATTR_ReadAttrEq(_minHeight,  A_minHeight, Dimension,  0);
    ATTR_ReadAttrEq(_typeface,   A_typeface,  NSString,   nil);
    ATTR_ReadAttrEq(_textStyle,  A_textStyle, NSString,   nil);
    ATTR_ReadAttrEq(_lines,      A_lines,     int,        -1);
    ATTR_ReadAttrEq(_maxLines,   A_maxLines,  int,        INT_MAX);
    
    ATTR_ReadAttrEq(_minLines,           A_minLines,         int,    1);
    ATTR_ReadAttrEq(_maxLength,          A_maxLength,        int,    INT_MAX);
    ATTR_ReadAttrEq(_lineSpacingExtra,   A_lineSpacingExtra, CGFloat, -1.0f);
    ATTR_ReadAttrEq(_shadowColor,        A_shadowColor,      UIColor, nil);
    ATTR_ReadAttrEq(_shadowDx,           A_shadowDx,         CGFloat, 0);
    ATTR_ReadAttrEq(_shadowDy,           A_shadowDy,         CGFloat, -3);
    ATTR_ReadAttrEq(_shadowRadius,       A_shadowRadius,     CGFloat, 0);
    
    _maxLines = MAX(self.maxLines, 0);
    _minLines = MAX(self.minLines, 0);
    _minLines = MIN(self.maxLines, self.minLines);
    if(_lines >= 0)
    {
        _lines = MIN(self.maxLines, self.lines);
        _lines = MAX(self.minLines, self.lines);
    }
    
    _drawableTop = nil;
    
    if(self.shadowColor)
    {
        self.layer.shadowColor = self.shadowColor.CGColor;
    }
    
//    self.layer.shadowOffset = CGSizeMake(self.shadowDx, self.shadowDy);
//    self.layer.cornerRadius = self.shadowRadius;
    
    _needStrBounds = YES;
    
    if (!useDefault)
    {
        if ([attrReader hasKey:ValueKey(A_textSize)] || [attrReader hasKey:ValueKey(A_textStyle)] || [attrReader hasKey:ValueKey(A_typeface)])
        {
            _font = nil;
        }
        
        _textAttributedString   = nil;
        _needResetTextLabel     = YES;
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
        else if (StrEq(@"light", _textStyle))
        {
            _font = [UIFont systemFontOfSize:_textSize weight:UIFontWeightLight];
        }else if (StrEq(@"thin", _textStyle))
        {
            _font = [UIFont systemFontOfSize:_textSize weight:UIFontWeightThin];
        }
        else if(!_typeface)
        {
            _font = [UIFont systemFontOfSize:_textSize];
        }
        else
        {
            //TODO:
            _font = [UIFont fontWithName:_typeface size:_textSize];
        }
    }
    return _font;
}

- (void)setTextStyle:(NSString *)textStyle
{
    _textStyle = textStyle.copy;
    _font = nil;
    _textAttributedString   = nil;
    _needResetTextLabel     = YES;
    [self requestLayout];
}

- (void)setText:(NSString *)text
{
    if (_text != text)
    {
        _text = [text copy];
        _textAttributedString   = nil;
        _needResetTextLabel     = YES;
        [self requestLayout];
    }
}

- (NSAttributedString*)textAttributedString
{
    if(!_textAttributedString && _text)
    {
        NSMutableDictionary* attributes = [NSMutableDictionary new];
        attributes[NSFontAttributeName] = self.font;
        attributes[NSForegroundColorAttributeName] = self.textColor;
        
//        if (_shadowColor)
//        {
//            NSShadow *shadow        = [NSShadow new];
//            shadow.shadowOffset     = CGSizeMake(_shadowDx, _shadowDy);
//            shadow.shadowColor      = _shadowColor;
//            shadow.shadowBlurRadius = _shadowRadius;
//        }
        
        NSMutableParagraphStyle *paragraphStyle = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
        paragraphStyle.alignment = self.textAlignment;
        paragraphStyle.lineBreakMode = self.ellipsize;
        attributes[NSParagraphStyleAttributeName] = paragraphStyle;
        
        if (self.lineSpacingExtra > 0)
        {
            paragraphStyle.lineSpacing  = self.lineSpacingExtra;
        }

        NSString* showString = _text;
        if(showString.length > self.maxLength)
        {
            showString = [showString substringToIndex:self.maxLength];
        }
        
        _textAttributedString = [[NSMutableAttributedString alloc] initWithString:showString attributes:attributes];
    }
    
    return _textAttributedString;
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    if (attributedText != _attributedText)
    {
        if (attributedText.length > self.maxLength)
        {
            _textAttributedString = [[attributedText attributedSubstringFromRange:NSMakeRange(0, self.maxLength)] mutableCopy];
        }
        else
        {
            _textAttributedString = [attributedText mutableCopy];
        }
        
        _needResetTextLabel = YES;
        [self requestLayout];
    }
    
    _text = nil;
}

- (CGRect)contentRect {
    return self.textLabel.frame;
}

- (UILabel*)textLabel
{
    if (!_textLabel || _needResetTextLabel)
    {
        _needResetTextLabel = NO;
        UILabel *label = nil;
        if(_textLabel)
        {
            label = _textLabel;
        }
        else
        {
            label = [[UILabel alloc] init];
        }
        
        label.font              = self.font;
        label.lineBreakMode     = self.ellipsize;
        label.textAlignment     = self.textAlignment;
        
        if (self.lines < 0)
        {
            label.numberOfLines = 0;
        }
        else
        {
            label.numberOfLines = self.lines;
        }

        if (self.textColor)
        {
            label.textColor = self.textColor;
        }
        
        if (self.shadowColor)
        {
            label.shadowColor = self.shadowColor;
            label.shadowOffset = (CGSize){self.shadowDx, self.shadowDy};
        }
        
        label.attributedText    = self.textAttributedString;
        [self setTextLabel:label];
    }
    
    return _textLabel;
}

- (void)setTextLabel:(UILabel*)newTextLabel
{
    [_textLabel removeFromSuperview];
    
    if (newTextLabel)
    {
        [self addSubview:newTextLabel];
    }
    _textLabel = newTextLabel;
}

- (CGSize)textOnMeasure:(MeasureSpec)widthSpec textHeightSpec:(MeasureSpec)heightSpec
{
    if(_height >= 0)
    {
        heightSpec.mode = MeasureSpec_EXACTLY;
        heightSpec.size = _height;
    }
    else if(MeasureSpec_EXACTLY != heightSpec.mode)
    {
        heightSpec.mode = MeasureSpec_AT_MOST;
    }
    
    if(_width >= 0)
    {
        widthSpec.mode = MeasureSpec_EXACTLY;
        widthSpec.size = _width;
    }
    else if(MeasureSpec_EXACTLY != widthSpec.mode)
    {
        widthSpec.mode = MeasureSpec_AT_MOST;
    }
    
    CGSize contentSize = CGSizeZero;
    
    
    NSMutableAttributedString* attributedString = (NSMutableAttributedString *)self.textAttributedString;
    if(attributedString)
    {
        CGRect bounds   = CGRectZero;
        CGSize sizeTmp  = CGSizeMake(widthSpec.size, heightSpec.size);
        if (_needStrBounds || !CGSizeEqualToSize(sizeTmp, _strBaseSize))
        {
            _needStrBounds  = false;
            _strBaseSize    = sizeTmp;
            _realBounds = CGRectZero;
            NSMutableDictionary *cachDict = [NSMutableDictionary dictionary];
            [attributedString enumerateAttribute:(NSString*)kCTParagraphStyleAttributeName inRange:NSMakeRange(0, [attributedString length]) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
                if (value) {
                    NSMutableParagraphStyle* paragraphStyle = [value mutableCopy];
                    if ([paragraphStyle lineBreakMode] != NSLineBreakByWordWrapping)
                    {
                        cachDict[NSStringFromRange(range)] = @([paragraphStyle lineBreakMode]);
                        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
                    }
                    
                    [attributedString removeAttribute:(NSString*)kCTParagraphStyleAttributeName range:range];
                    [attributedString addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
                }
              
            }];
            
            bounds = [self _attibuteString:attributedString boundIngRectWithSize:sizeTmp];
            
            if (cachDict.count)
            {
                [attributedString enumerateAttribute:(NSString*)kCTParagraphStyleAttributeName inRange:NSMakeRange(0, [attributedString length]) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
                    NSNumber *lineBreakMode = cachDict[NSStringFromRange(range)];
                    if (lineBreakMode)
                    {
                        NSMutableParagraphStyle* paragraphStyle = [value mutableCopy];
                        paragraphStyle.lineBreakMode = [lineBreakMode integerValue];
                        [attributedString removeAttribute:(NSString*)kCTParagraphStyleAttributeName range:range];
                        [attributedString addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
                    }
                }];
            }
            
            _strBounds = bounds;
            
        }
        else
        {
            bounds = _strBounds;
        }
        
        contentSize = bounds.size;
        
        if(MeasureSpec_EXACTLY != widthSpec.mode)
        {
            widthSpec.size = bounds.size.width;
            widthSpec.mode = MeasureSpec_EXACTLY;
        }
        
        if(MeasureSpec_EXACTLY != heightSpec.mode)
        {
            heightSpec.size = MIN(bounds.size.height, heightSpec.size);
            heightSpec.mode = MeasureSpec_EXACTLY;
        }
        contentSize.height = MIN(contentSize.height, heightSpec.size);
    }
    else
    {
        if(MeasureSpec_EXACTLY != widthSpec.mode)
        {
            widthSpec.mode = MeasureSpec_EXACTLY;
            widthSpec.size = 0;
        }
        if(MeasureSpec_EXACTLY != heightSpec.mode)
        {
            heightSpec.mode = MeasureSpec_EXACTLY;
            heightSpec.size = 0;
        }
    }

    assert(MeasureSpec_EXACTLY == widthSpec.mode && MeasureSpec_EXACTLY == heightSpec.mode);
    
    CGSize measuredSize = CGSizeMake(widthSpec.size, heightSpec.size);
    self.textLabel.viewParams.measuredSize = measuredSize;
    _textLabelContentSize = contentSize;
    if(!CGRectEqualToRect(_realBounds, CGRectZero))
    {
        _textLabelContentSize.height = MIN(_textLabelContentSize.height, _realBounds.size.height);
        _textLabelContentSize.width = MIN(_textLabelContentSize.width, _realBounds.size.width);
    }
    return measuredSize;
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
    
    if(maxAvailableWidth >= _maxWidth)
    {
        textWidthSpec.mode = MeasureSpec_AT_MOST;
        maxAvailableWidth  = _maxWidth;
    }
    
    if(maxAvailableWidth <= _minWidth)
    {
        textWidthSpec.mode = MeasureSpec_EXACTLY;
        maxAvailableWidth  = _minWidth;
    }
    
    if(maxAvailableHeight >= _maxHeight)
    {
        textHeightSpec.mode = MeasureSpec_AT_MOST;
        maxAvailableHeight  = _maxHeight;
    }
    
    if(maxAvailableHeight <= _minHeight)
    {
        textHeightSpec.mode = MeasureSpec_EXACTLY;
        maxAvailableHeight  = _minHeight;
    }
    
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
        if(_drawableLeft)
        {
            computeWidth += _drawableLeft.bounds.size.width + _drawablePadding;
        }
        
        if(_drawableRight)
        {
            computeWidth += _drawableRight.bounds.size.width + _drawablePadding;
        }
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
        if(_drawableTop)
        {
            computeHeight += _drawableTop.bounds.size.height + _drawablePadding;
        }
        
        if(_drawableBottom)
        {
            computeHeight += _drawableBottom.bounds.size.height + _drawablePadding;
        }
    }

    textHeightSpec.size = maxAvailableHeight;
    
    CGSize textMeasuredSize = [self textOnMeasure:textWidthSpec textHeightSpec:textHeightSpec];
    
    computeWidth  += textMeasuredSize.width;
    computeHeight += textMeasuredSize.height;
    
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
    CGFloat left = padding.left;
    CGFloat top  = padding.top;
    
    if(_drawableLeft)
    {
        left += _drawableLeft.bounds.size.width + _drawablePadding;
    }
    
    if(_drawableTop)
    {
        top += _drawableTop.bounds.size.height + _drawablePadding;
    }

    CGSize measuredSize = self.viewParams.measuredSize;
    CGSize contentSize = _textLabelContentSize;
    contentSize.width = MIN(contentSize.width, measuredSize.width);
    UIEdgeBounds container = UIEdgeInsetsMake(top, left, measuredSize.height - padding.bottom, measuredSize.width - padding.right);
    UIEdgeBounds targetBounds = [Gravity apply:_gravity w:contentSize.width h:contentSize.height container:container layoutDirection:LayoutDirection_LTR];
    
    self.textLabel.frame = (CGRect){{targetBounds.left,targetBounds.top}, (CGSize){targetBounds.right - targetBounds.left, targetBounds.bottom - targetBounds.top}};
}


#pragma -mark 计算文本的content Rect

/**
 *  根据lines maxLines minLines计算布局rect， label的实际计算的rect conentSize
 *
 *  @param attStr       NSAttributedString
 *  @param csize        计算csize
 *
 *  @return 计算得到的结果
 */
- (CGRect)_attibuteString:(NSAttributedString *)attStr boundIngRectWithSize:(CGSize)csize
{
    NSInteger maxLine   = 0;
    NSInteger minLine   = 0;
    _contentLines = 1;
    
    CGRect bounds       = CGRectZero;
    if (_lines == -1)
    {
        if (_maxLines == 0 && _minLines == 0)
        {
            bounds = [attStr boundingRectWithSize:CGSizeMake(csize.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        }
        else
        {
            maxLine = MAX(maxLine, _maxLines);
            minLine = MAX(minLine, _minLines);
        }
    }
    else
    {
        if (_lines == 0)
        {}
        else if (_lines == 1)
        {
            bounds = [attStr boundingRectWithSize:csize options:0 context:nil];
            bounds.size.width = MIN(bounds.size.width, csize.width);
        }
        else
        {
            maxLine = minLine = _lines;
            if (_maxLines > 0 || _minLines > 0)
            {
                maxLine = MIN(maxLine, _maxLines);
                minLine = MAX(minLine, _minLines);
            }
        }
    }
    
    if (maxLine > 0 || minLine > 0)
    {
        CGMutablePathRef pathRef        = CGPathCreateMutable();
        CGRect pathRect                 = CGRectMake(0, 0, csize.width, CGFLOAT_MAX);
        CGPathAddRect(pathRef, NULL, pathRect);
        CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
        CTFrameRef frameRef             = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, attStr.length), pathRef, nil);
        
        CFArrayRef lines        = CTFrameGetLines(frameRef);
        NSInteger lineCount     = CFArrayGetCount(lines);
        _contentLines = (int)lineCount;
        if (minLine > lineCount)
        {
            _realBounds = [attStr boundingRectWithSize:CGSizeMake(csize.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
                        
            bounds = [self _appendEnterCount:minLine - lineCount originAttStr:attStr cacluteSize:csize];
        }
        else if (maxLine < lineCount)
        {
            bounds = [self _getLastLineMaxY:maxLine - 1 lines:lines originAttStr:attStr baseWidth:csize.width];
        }
        else
        {
            bounds = [attStr boundingRectWithSize:CGSizeMake(csize.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        }
        
        CFRelease(pathRef);
        CFRelease(frameRef);
        CFRelease(framesetterRef);
    }
    return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
}


/**
 *  根据需要的最大行数大于内容的行数rect conentSize
 *
 *  @param count       需要加载行数
 *  @param attStr         原NSAttributedString
 *  @param cSize       计算csize
 *
 *  @return 计算得到的结果
 */
- (CGRect)_appendEnterCount:(NSInteger)count originAttStr:(NSAttributedString *)attStr cacluteSize:(CGSize)cSize
{
    NSMutableAttributedString *cAtt = [[NSMutableAttributedString alloc] initWithAttributedString:attStr];
    NSMutableString *tmp = [NSMutableString new];
    while (count > 0)
    {
        count--;
        [tmp appendFormat:@"\n"];
    }
    
    NSMutableDictionary* attributes = [NSMutableDictionary new];
    attributes[NSFontAttributeName] = self.font;
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = self.textAlignment;
    if (self.lineSpacingExtra > 0)
    {
        paragraphStyle.lineSpacing  = self.lineSpacingExtra;
    }
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;

    [cAtt appendAttributedString:[[NSAttributedString alloc] initWithString:tmp attributes:attributes]];
    
    NSStringDrawingOptions drawingOptions = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    return [cAtt boundingRectWithSize:CGSizeMake(cSize.width, CGFLOAT_MAX) options:drawingOptions context:nil];
}

/**
 *  根据内容的行数大于需要的最大行数
 *
 *  @param index       需要计算到行数
 *  @param lines       原文本的lines
 *  @param attStr      原NSAttributedString
 *
 *  @return 计算得到的结果
 */
- (CGRect)_getLastLineMaxY:(NSInteger)index lines:(CFArrayRef)lines originAttStr:(NSAttributedString *)attStr baseWidth:(CGFloat)baseWidth
{
    CTLineRef lineRef= CFArrayGetValueAtIndex(lines, index);
    CFRange lastIndex = CTLineGetStringRange(lineRef);
    
    CGFloat totalHeight = 0;
    CGFloat lineSpacingExtra = 0;
    if(self.lineSpacingExtra > 0)
    {
        lineSpacingExtra = self.self.lineSpacingExtra;
    }
    
    for(NSInteger i=0; i<= index; i++)
    {
        CGFloat ascent;
        CGFloat descent;
        CGFloat leading;
        CTLineRef lineRef= CFArrayGetValueAtIndex(lines, i);
        CTLineGetTypographicBounds(lineRef, &ascent, &descent, &leading);
        if(0 == i)
        {
            totalHeight += ascent + descent + leading;
        }
        else 
        {
            totalHeight += ascent + descent + leading + lineSpacingExtra;
        }
    }
    
    NSMutableAttributedString *tmpSubStr = [[attStr attributedSubstringFromRange:NSMakeRange(0, lastIndex.location + lastIndex.length)] mutableCopy];
    CGRect rect = [tmpSubStr boundingRectWithSize:CGSizeMake(baseWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    rect.size.height = MAX(totalHeight, rect.size.height);
    return rect;
}

- (void)dealloc
{
    [self.viewParams.backgroud detach:self];
    [_textColorDrawable detach:self];
}

DEF_NEEDLAYOUT_SETTER(CGFloat,  Height,     height)
DEF_NEEDLAYOUT_SETTER(CGFloat,  Width,      width)
DEF_NEEDLAYOUT_SETTER(CGFloat,  MaxHeight,  maxHeight)
DEF_NEEDLAYOUT_SETTER(CGFloat,  MinHeight,  minHeight)
DEF_NEEDLAYOUT_SETTER(CGFloat,  MaxWidth,   maxWidth)
DEF_NEEDLAYOUT_SETTER(CGFloat,  MinWidth,   minWidth)
DEF_NEEDLAYOUT_SETTER(int,      MaxLines,   maxLines)
DEF_NEEDLAYOUT_SETTER(int,      MinLines,   minLines)

- (void)setTextSize:(CGFloat)textSize
{
    if (_textSize != textSize)
    {
        _textSize   = textSize;
        _font       = nil;
        _needResetTextLabel = true;
        _textAttributedString = nil;
        [self requestLayout];
    }
}

- (void)setFont:(UIFont*)font
{
    if(_font != font)
    {
        _font = font;
        _needResetTextLabel = true;
        _textAttributedString = nil;
        [self requestLayout];
    }
}

- (void)setTypeface:(NSString *)typeface
{
    if ([typeface isEqualToString:typeface])
    {
        _typeface   = [typeface copy];
        _font       = nil;
        _needResetTextLabel = true;
        [self requestLayout];
    }
}

- (void)setLines:(int)lines
{
    if (_lines != lines)
    {
        _lines = lines;
        _needResetTextLabel = true;
        [self requestLayout];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
#ifdef DEBUG
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:@"ALayoutDebugClicked"];
    if(enable)
    {
        BOOL resetEnable = self.isEnabled;
        if(!self.isEnabled)
        {
            self.enabled = YES;
        }
        UIView* view = [super hitTest:point withEvent:event];
        if(self.isEnabled != resetEnable)
        {
            self.enabled = resetEnable;
        }
        if(self == view)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ALayoutViewClicked" object:view];
            return nil;
        }
    }
#endif
    UIView* view = [super hitTest:point withEvent:event];
    if(!self.viewParams.clickable && self == view)
    {
        view = nil;
    }
    return view;
}

- (NSString*)mainKey
{
    return ValueKey(A_text);
}

@end

//Android:autoLink设置是否当文本为URL链接/email/电话号码/map时，文本显示为可点击的链接。可选值(none/web /email/phone/map/all)
//android:autoText如果设置，将自动执行输入值的拼写纠正。此处无效果，在显示输入法并输入的时候起作用。
//android:bufferType指定getText()方式取得的文本类别。选项editable 类似于StringBuilder可追加字符，也就是说getText后可调用append方法设置文本内容。spannable 则可在给定的字符区域使用样式，参见这里1、这里2。
//android:capitalize设置英文字母大写类型。此处无效果，需要弹出输入法才能看得到，参见EditView此属性说明。
//android:cursorVisible设定光标为显示/隐藏，默认显示。
//android:digits设置允许输入哪些字符。如“1234567890.+-*/% ()”

//android:editable设置是否可编辑。
//android:editorExtras设置文本的额外的输入数据。

//android:freezesText设置保存文本的内容以及光标的位置。

//android:hintText为空时显示的文字提示信息，可通过textColorHint设置提示信息的颜色。此属性在 EditView中使用，但是这里也可以用。
//android:imeOptions附加功能，设置右下角IME动作与编辑框相关的动作，如actionDone右下角将显示一个“完成”，而不设置默认是一个回车符号。这个在EditView中再详细说明，此处无用。


//android:inputMethod为文本指定输入法，需要完全限定名(完整的包名)。例如：com.google.android.inputmethod.pinyin，但是这里报错找不到。
//android:inputType设置文本的类型，用于帮助输入法显示合适的键盘类型。在EditView中再详细说明，这里无效果。
//android:linksClickable设置链接是否点击连接，即使设置了autoLink。


//android:numeric如果被设置，该TextView有一个数字输入法。此处无用，设置后唯一效果是TextView有点击效果，此属性在EdtiView将详细说明。
//android:password以小点”.”显示文本
//android:phoneNumber设置为电话号码的输入方式。
//android:privateImeOptions设置输入法选项，此处无用，在EditText将进一步讨论。
//android:scrollHorizontally设置文本超出TextView的宽度的情况下，是否出现横拉条。
//android:selectAllOnFocus如果文本是可选择的，让他获取焦点而不是将光标移动为文本的开始位置或者末尾位置。 TextView中设置后无效果。

//android:textColorHighlight被选中文字的底色，默认为蓝色
//android:textColorHint设置提示信息文字的颜色，默认为灰色。与hint一起使用。
//android:textColorLink文字链接的颜色.

//? android:textScaleX设置文字之间间隔，默认为1.0f。
//?android:textAppearance设置文字外观。如 “?android:attr/textAppearanceLargeInverse”这里引用的是系统自带的一个外观，?表示系统是否有这种外观，否则使用默认的外观。可设置的值如下：textAppearanceButton/textAppearanceInverse/textAppearanceLarge/textAppearanceLargeInverse/textAppearanceMedium/textAppearanceMediumInverse/textAppearanceSmall/textAppearanceSmallInverse
//?android:imeActionId设置IME动作ID。
//?android:imeActionLabel设置IME动作标签。


//- android:marqueeRepeatLimit在ellipsize指定marquee的情况下，设置重复滚动的次数，当设置为 marquee_forever时表示无限次。
//-android:ems设置TextView的宽度为N个字符的宽度。这里测试为一个汉字字符宽度
//-android:maxEms设置TextView的宽度为最长为N个字符的宽度。与ems同时使用时覆盖ems选项。
//-android:minEms设置TextView的宽度为最短为N个字符的宽度。与ems同时使用时覆盖ems选项。



//android:drawableBottom在text的下方输出一个drawable，如图片。如果指定一个颜色的话会把text的背景设为该颜色，并且同时和background使用时覆盖后者。
//android:drawableLeft在text的左边输出一个drawable，如图片。
//android:drawablePadding设置text与drawable(图片)的间隔，与drawableLeft、 drawableRight、drawableTop、drawableBottom一起使用，可设置为负数，单独使用没有效果。
//android:drawableRight在text的右边输出一个drawable。
//android:drawableTop在text的正上方输出一个drawable。
//android:gravity设置文本位置，如设置成“center”，文本将居中显示。
//android:includeFontPadding设置文本是否包含顶部和底部额外空白，默认为true。
//android:marqueeRepeatLimit在ellipsize指定marquee的情况下，设置重复滚动的次数，当设置为 marquee_forever时表示无限次。
//android:ems设置TextView的宽度为N个字符的宽度。这里测试为一个汉字字符宽度
//android:maxEms设置TextView的宽度为最长为N个字符的宽度。与ems同时使用时覆盖ems选项。
//android:minEms设置TextView的宽度为最短为N个字符的宽度。与ems同时使用时覆盖ems选项。
//android:maxLength限制显示的文本长度，超出部分不显示。
//android:lines设置文本的行数，设置两行就显示两行，即使第二行没有数据。
//android:maxLines设置文本的最大显示行数，与width或者layout_width结合使用，超出部分自动换行，超出行数将不显示。
//android:minLines设置文本的最小行数，与lines类似。
//android:lineSpacingExtra设置行间距。
//android:lineSpacingMultiplier设置行间距的倍数。如”1.2”
//android:shadowColor指定文本阴影的颜色，需要与shadowRadius一起使用。
//android:shadowDx设置阴影横向坐标开始位置。
//android:shadowDy设置阴影纵向坐标开始位置。
//android:shadowRadius设置阴影的半径。设置为0.1就变成字体的颜色了，一般设置为3.0的效果比较好。
//android:text设置显示文本.
//android:textColor设置文本颜色
//android:textSize设置文字大小，推荐度量单位”sp”，如”15sp”
//android:textStyle设置字形[bold(粗体) 0, italic(斜体) 1, bolditalic(又粗又斜) 2] 可以设置一个或多个，用“|”隔开
//android:typeface设置文本字体，必须是以下常量值之一：normal 0, sans 1, serif 2, monospace(等宽字体) 3]
//android:height设置文本区域的高度，支持度量单位：px(像素)/dp/sp/in/mm(毫米)
//android:maxHeight设置文本区域的最大高度
//android:minHeight设置文本区域的最小高度
//android:width设置文本区域的宽度，支持度量单位：px(像素)/dp/sp/in/mm(毫米)，与layout_width 的区别看这里。
//android:maxWidth设置文本区域的最大宽度
//android:minWidth设置文本区域的最小宽度



