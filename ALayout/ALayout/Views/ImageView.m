//
//  ImageView.m
//  ALayout
//
//  Created by splendourbell on 2017/5/5.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "ImageView.h"
#import "BitmapDrawable.h"
#import "ColorDrawable.h"

static NSString * __ALayoutMaskCornerRadiusLayer   = @"__ALayoutMaskCornerRadiusLayer";

@interface ImageView ()
{
    UIImageView* _imageView;
}

@property (nonatomic) GravityMode gravity;

@end

@implementation ImageView

- (void)parseAttr:(AttributeReader *)attrReader useDefault:(BOOL)useDefault
{
    [super parseAttr:attrReader useDefault:useDefault];
    
    ATTR_ReadAttrEq(_scaleType,         A_scaleType,        ScaleType,  ScaleType_CENTER_CROP);
    ATTR_ReadAttrEq(_adjustViewBounds,  A_adjustViewBounds, BOOL,       NO);
    ATTR_ReadAttrEq(_maxWidth,          A_maxWidth,         Dimension,  INT_MAX);
    ATTR_ReadAttrEq(_maxHeight,         A_maxHeight,        Dimension,  INT_MAX);
    ATTR_ReadAttrEq(_image,             A_src,              UIImage,    nil);
    ATTR_ReadAttrEq(_roundAsCircle,     A_roundAsCircle,    BOOL,       NO);
    ATTR_ReadAttrEq(_aspectRatio,       A_aspectRatio,      Dimension,  -1);
    ATTR_ReadAttrEq(_defaultImage,      A_defaultImage,     UIImage,    nil);
    if (!_defaultImage && _image)
    {
        _defaultImage = _image;
    }
    
    UICornerRadius cornerRadius = UICornerRadiusZero;
    CGFloat radius = -1;
    ATTR_ReadAttrEq(radius, A_radius, Dimension, -1);
    if (radius < 0)
    {
        ATTR_ReadAttrEq(cornerRadius.topLeft    , A_topLeftRadius,     Dimension, radius);
        ATTR_ReadAttrEq(cornerRadius.topRight   , A_topRightRadius,    Dimension, radius);
        ATTR_ReadAttrEq(cornerRadius.bottomRight, A_bottomRightRadius, Dimension, radius);
        ATTR_ReadAttrEq(cornerRadius.bottomLeft , A_bottomLeftRadius,  Dimension, radius);
    }
    else
    {
        cornerRadius.topLeft     = radius;
        cornerRadius.topRight    = radius;
        cornerRadius.bottomRight = radius;
        cornerRadius.bottomLeft  = radius;
    }
    
    self.cornerRadius = cornerRadius;

    if (_adjustViewBounds)
    {
        _scaleType = ScaleType_FIT_CENTER;
    }
}

- (UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [UIImageView new];
        [self addSubview:_imageView];
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (void)onMeasure:(MeasureSpec)widthSpec heightSpec:(MeasureSpec)heightSpec
{
    CGFloat w;
    CGFloat h;
    
    CGFloat desiredAspect = 0.0f;
    
    BOOL resizeWidth = NO;
    BOOL resizeHeight = NO;
    
    MeasureSpecMode widthSpecMode = widthSpec.mode;
    MeasureSpecMode heightSpecMode = heightSpec.mode;
    
    if (_aspectRatio > 0.01)
    {
        if ((MeasureSpec_EXACTLY == widthSpecMode && widthSpec.size > 0.01) && (MeasureSpec_EXACTLY != heightSpecMode || heightSpec.size < 0.01))
        {
            heightSpec.size = widthSpec.size / _aspectRatio;
            heightSpec.mode = MeasureSpec_EXACTLY;
        }
        else if ((MeasureSpec_EXACTLY == heightSpecMode && heightSpec.size > 0.01) && (MeasureSpec_EXACTLY != widthSpecMode || widthSpec.size < 0.01))
        {
            widthSpec.size = heightSpec.size * _aspectRatio;
            widthSpec.mode = MeasureSpec_EXACTLY;
        }
    }
    
    CGSize imgSize = _image.size;
    
    if (!_image)
    {
        imgSize.width = -1;
        imgSize.height = -1;
        w = h = 0;
    }
    else
    {
        if (MeasureSpec_EXACTLY == widthSpecMode && MeasureSpec_EXACTLY == heightSpecMode)
        {
            w = widthSpec.size;
            h = heightSpec.size;
        }
        else
        {
            w = imgSize.width;
            h = imgSize.height;
        }
        
        if (w <= 0) w = 1;
        if (h <= 0) h = 1;
        
        if (_adjustViewBounds)
        {
            resizeWidth   = widthSpecMode  != MeasureSpec_EXACTLY;
            resizeHeight  = heightSpecMode != MeasureSpec_EXACTLY;
            desiredAspect = w / h;
        }
    }
    
    UIEdgeInsets padding = self.viewParams.padding;
    
    CGFloat pleft   = padding.left;
    CGFloat pright  = padding.right;
    CGFloat ptop    = padding.top;
    CGFloat pbottom = padding.bottom;
    
    CGFloat widthSize;
    CGFloat heightSize;
    
    if (resizeWidth || resizeHeight)
    {
        widthSize  = [self resolveAdjustedSize:(w + pleft + pright) maxSize:_maxWidth  measureSpec:widthSpec];
        heightSize = [self resolveAdjustedSize:(h + ptop + pbottom) maxSize:_maxHeight measureSpec:heightSpec];
        
        if (0 != desiredAspect)
        {
            CGFloat actualAspect = (widthSize - pleft - pright) / (heightSize - ptop - pbottom);
            if (ABS(actualAspect - desiredAspect) > 0.0000001)
            {
                BOOL done = NO;
                if (resizeWidth)
                {
                    int newWidth = (int)(desiredAspect * (heightSize - ptop - pbottom)) + pleft + pright;
                    
                    if (!resizeHeight)
                    {
                        widthSize = [self resolveAdjustedSize:newWidth maxSize:_maxWidth measureSpec:widthSpec];
                    }
                    
                    if (newWidth <= widthSize)
                    {
                        widthSize = newWidth;
                        done = true;
                    }
                }
                
                if (!done && resizeHeight)
                {
                    CGFloat newHeight = (widthSize - pleft - pright) / desiredAspect + ptop + pbottom;
                    
                    if (!resizeWidth)
                    {
                        heightSize = [self resolveAdjustedSize:newHeight maxSize:_maxHeight measureSpec:heightSpec];
                    }
                    
                    if (newHeight <= heightSize)
                    {
                        heightSize = newHeight;
                    }
                }
            }
        }
    }
    else
    {
        w += pleft + pright;
        h += ptop + pbottom;
    
        w = MAX(w, self.suggestedMinimumWidth);
        h = MAX(h, self.suggestedMinimumHeight);
        
        widthSize  = [self resolveSize:w measureSpec:widthSpec];
        heightSize = [self resolveSize:h measureSpec:heightSpec];
    }
    
    [self setMeasuredDimensionRaw:CGSizeMake(widthSize, heightSize)];
}

- (void)onLayout:(CGRect)rect
{
    UIImageView* imageView = self.imageView;
    if (!_defaultImage && _image)
    {
        _defaultImage = _image;
    }
    
    imageView.image = _image?:_defaultImage;
    
    CGFloat dwidth  = _image.size.width;
    CGFloat dheight = _image.size.height;
    
    UIEdgeInsets padding  = self.viewParams.padding;
    CGSize measuredSize   = self.viewParams.measuredSize;
    
    CGFloat paddingLeft   = padding.left;
    CGFloat paddingRight  = padding.right;
    CGFloat paddingTop    = padding.top;
    CGFloat paddingBottom = padding.bottom;
    
    CGFloat vwidth  = measuredSize.width  - paddingLeft - paddingRight;
    CGFloat vheight = measuredSize.height - paddingTop  - paddingBottom;
    
    dwidth  = MIN(vwidth, dwidth);
    dheight = MIN(vheight, dheight);

    if (dwidth <= 0 || dheight <= 0 || ScaleType_FIT_XY == _scaleType)
    {
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.frame = (CGRect){paddingLeft, paddingTop,vwidth,vheight};
    }
    else
    {
        CGRect imgFrame = (CGRect){0, 0, dwidth, dheight};
        
        if (ScaleType_MATRIX == _scaleType)
        {
            imgFrame.origin = (CGPoint){paddingLeft, paddingTop};
            imageView.frame = imgFrame;
        }
        else if (ScaleType_CENTER == _scaleType)
        {
            imageView.contentMode = UIViewContentModeCenter;
            imgFrame = CGRectOffset(imgFrame, (vwidth - dwidth)/2 + paddingLeft, (vheight - dheight)/2 + paddingTop);
        }
        else if (ScaleType_CENTER_CROP == _scaleType)
        {
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imgFrame = (CGRect){paddingLeft, paddingTop,vwidth,vheight};
        }
        else if (ScaleType_CENTER_INSIDE == _scaleType)
        {
            CGFloat scale, dx = 0, dy = 0;
            
            if (dwidth <= vwidth && dheight <= vheight)
            {
                scale = 1.0f;
            }
            else
            {
                scale = MIN(vwidth / dwidth, vheight / dheight);
            }
            
            dx = (vwidth - dwidth * scale) * 0.5f;
            dy = (vheight - dheight * scale) * 0.5f;

            imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            imgFrame.origin.x = dx + paddingLeft;
            imgFrame.origin.y = dy + paddingTop;
            
            imgFrame.size.width  /= scale;
            imgFrame.size.height /= scale;
        }
        else
        {
            CGFloat scale;
            CGFloat dx = 0, dy = 0;
            
            if (dwidth / dheight  > vwidth / vheight )
            {
                scale = vwidth / dwidth;
                if(ScaleType_FIT_END == _scaleType)
                {
                    dy = vheight - dheight * scale;
                }
                else if(ScaleType_FIT_CENTER == _scaleType)
                {
                    dy = (vheight - dheight * scale) / 2;
                }
            }
            else
            {
                scale = vheight / dheight;
                if(ScaleType_FIT_END == _scaleType)
                {
                    dx = (vwidth - dwidth * scale);
                }
                else if(ScaleType_FIT_CENTER == _scaleType)
                {
                    dx = (vwidth - dwidth * scale) / 2;
                }
            }
            
            imgFrame = CGRectOffset(imgFrame, dx + paddingLeft, dy + paddingTop);
            imgFrame.size.width  *= scale;
            imgFrame.size.height *= scale;
            imageView.contentMode = UIViewContentModeScaleToFill;
        }
        
        imageView.frame = imgFrame;
    }
    
    [self updateCornerRadius];
}

- (CGFloat)resolveAdjustedSize:(CGFloat)desiredSize maxSize:(CGFloat)maxSize measureSpec:(MeasureSpec)measureSpec
{
    CGFloat result = desiredSize;
    MeasureSpecMode specMode = measureSpec.mode;
    CGFloat specSize =  measureSpec.size;
    
    switch (specMode)
    {
        case MeasureSpec_UNSPECIFIED:
            result = MIN(desiredSize, maxSize);
            break;
        
        case MeasureSpec_AT_MOST:
            result = MIN(MIN(desiredSize, specSize), maxSize);
            break;
        
        case MeasureSpec_EXACTLY:
            result = specSize;
            break;
    }
    
    return result;
}

- (void)removeMaskShapeLayer
{
    CAShapeLayer *maskLayer = (CAShapeLayer *)_imageView.layer.mask;
    if (maskLayer && [maskLayer isKindOfClass:[CAShapeLayer class]] &&
        [maskLayer.name isEqualToString:__ALayoutMaskCornerRadiusLayer])
    {
        _imageView.layer.mask = nil;
    }
}


- (CAShapeLayer *)getMaskShapeLayer
{
    CAShapeLayer *maskLayer = (CAShapeLayer *)_imageView.layer.mask;
    if (maskLayer)
    {
        if ([maskLayer isKindOfClass:[CAShapeLayer class]] &&
            [maskLayer.name isEqualToString:__ALayoutMaskCornerRadiusLayer])
        {
            return maskLayer;
        }
        else
        {
            return nil;
        }
    }
    else
    {
        maskLayer       = [CAShapeLayer new];
        maskLayer.name  = __ALayoutMaskCornerRadiusLayer;
        _imageView.layer.mask      = maskLayer;
    }
    
    return maskLayer;
}

#define FloatEq(_A_, _B_) (ABS(_A_ - _B_) <= (1e-6))

- (void)updateCornerRadius
{
    if (_roundAsCircle)
    {
        CAShapeLayer * maskLayer = [self getMaskShapeLayer];
        if (maskLayer)
        {
            UIBezierPath* rectRadiuPath = [UIBezierPath bezierPathWithOvalInRect:_imageView.bounds];
            maskLayer.frame         = _imageView.bounds;
            maskLayer.path          = [rectRadiuPath CGPath];
        }
    }
    else if (!FloatEq(_cornerRadius.topLeft, _cornerRadius.topRight) ||
             !FloatEq(_cornerRadius.topLeft, _cornerRadius.bottomLeft) ||
             !FloatEq(_cornerRadius.topLeft, _cornerRadius.bottomRight))
    {
        CAShapeLayer * maskLayer = [self getMaskShapeLayer];
        if (maskLayer)
        {
            UIBezierPath *rectRadiuPath = [UIBezierPath new];
            CGRect bounds = _imageView.bounds;
            CGFloat layerW = CGRectGetWidth(bounds);
            CGFloat layerH = CGRectGetHeight(bounds);
            if (_cornerRadius.topLeft > 0.001)
            {
                [rectRadiuPath moveToPoint:CGPointMake(0, _cornerRadius.topLeft)];
                [rectRadiuPath addArcWithCenter:CGPointMake(_cornerRadius.topLeft, _cornerRadius.topLeft) radius:_cornerRadius.topLeft startAngle:M_PI endAngle:1.5 * M_PI clockwise:YES];
            }
            else
            {
                [rectRadiuPath moveToPoint:CGPointZero];
            }
            
            if (_cornerRadius.topRight > 0.001)
            {
                [rectRadiuPath addLineToPoint:CGPointMake(layerW - _cornerRadius.topRight, 0)];
                [rectRadiuPath addArcWithCenter:CGPointMake(layerW - _cornerRadius.topRight, _cornerRadius.topRight) radius:_cornerRadius.topRight startAngle:1.5 * M_PI endAngle:M_PI * 2 clockwise:YES];
            }
            else
            {
                [rectRadiuPath addLineToPoint:CGPointMake(layerW, 0)];
            }
            
            
            if (_cornerRadius.bottomRight > 0.001)
            {
                [rectRadiuPath addLineToPoint:CGPointMake(layerW, layerH - _cornerRadius.bottomRight)];
                [rectRadiuPath addArcWithCenter:CGPointMake(layerW - _cornerRadius.bottomRight, layerH - _cornerRadius.bottomRight) radius:_cornerRadius.bottomRight startAngle:0 endAngle:M_PI / 2 clockwise:YES];
            }
            else
            {
                [rectRadiuPath addLineToPoint:CGPointMake(layerW, layerH)];
            }
            
            
            if (_cornerRadius.bottomLeft > 0.001)
            {
                [rectRadiuPath addLineToPoint:CGPointMake(_cornerRadius.bottomLeft, layerH)];
                [rectRadiuPath addArcWithCenter:CGPointMake(_cornerRadius.bottomLeft, layerH - _cornerRadius.bottomLeft) radius:_cornerRadius.bottomLeft startAngle:M_PI / 2  endAngle:M_PI clockwise:YES];
            }
            else
            {
                [rectRadiuPath addLineToPoint:CGPointMake(0, layerH)];
            }
            
            
            if (_cornerRadius.topLeft > 0.001)
            {
                [rectRadiuPath addLineToPoint:CGPointMake(0, _cornerRadius.topLeft)];
            }
            else
            {
                [rectRadiuPath addLineToPoint:CGPointMake(0, 0)];
            }
            
            [rectRadiuPath closePath];
            
            maskLayer.frame = _imageView.bounds;
            maskLayer.path = [rectRadiuPath CGPath];
        }
    }
    else
    {
        [self removeMaskShapeLayer];
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

- (void)setImage:(UIImage *)image
{
    if (_image != image || !_image)
    {
        _image = image;
        [self requestLayout];
        
        if (!_image && _defaultImage)
        {
            _image = _defaultImage;
            self.imageView.image = _defaultImage;
        }
        else if(_imageView && _image)
        {
            self.imageView.image = _image;
        }
        
        if(ScaleType_CENTER_CROP == _scaleType && UIViewContentModeScaleAspectFill != self.imageView.contentMode)
        {
            self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        }
    }
}

- (NSString*)mainKey
{
    return ValueKey(A_url);
}

- (void)dealloc {
    [self.viewParams.backgroud detach:self];
}

DEF_NEEDLAYOUT_SETTER(ScaleType,   ScaleType,        scaleType)
DEF_NEEDLAYOUT_SETTER(BOOL,        AdjustViewBounds, adjustViewBounds)
DEF_NEEDLAYOUT_SETTER(CGFloat,     MaxWidth,         maxWidth)
DEF_NEEDLAYOUT_SETTER(CGFloat,     MaxHeight,        maxHeight)

@end
