//
//  ShapeDrawable.m
//  ALayout
//
//  Created by Splendour Bell on 2017/5/13.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "ShapeDrawable.h"

static NSString * __ALayoutBorderShapeLayer = @"__ALayoutBorderShapeLayer";
static NSString * __ALayoutMaskShapeLayer   = @"__ALayoutMaskShapeLayer";

@implementation ShapeStroke

- (void)parseAttr:(AttributeReader *)attrReader
{
    self.width      = ATTR_ReadAttr(A_width,        Dimension, 0);
    self.color      = ATTR_ReadAttr(A_color,        UIColor,   UIColor.blackColor);
    self.dashWidth  = ATTR_ReadAttr(A_dashWidth,    Dimension, 0);
    self.dashGap    = ATTR_ReadAttr(A_dashGap,      Dimension, 0);
}

@end

@implementation ShapeGradient

- (void)parseAttr:(AttributeReader *)attrReader
{
    self.angle          = ATTR_ReadAttr(A_angle,            int,        0);
    self.centerX        = ATTR_ReadAttr(A_centerX,          CGFloat,    0);
    self.centerY        = ATTR_ReadAttr(A_centerY,          CGFloat,    0);
    self.startColor     = ATTR_ReadAttr(A_startColor,       UIColor,    UIColor.blackColor);
    self.centerColor    = ATTR_ReadAttr(A_centerColor,      UIColor,    UIColor.blackColor);
    self.endColor       = ATTR_ReadAttr(A_endColor,         UIColor,    UIColor.blackColor);
    self.gradientRadius = ATTR_ReadAttr(A_gradientRadius,   Dimension,  0);
    self.useLevel       = ATTR_ReadAttr(A_useLevel,         BOOL,       NO);
}

@end

@implementation ShapeShadow

- (void)parseAttr:(AttributeReader *)attrReader
{
    Dimension shadowDx = ATTR_ReadAttr(A_shadowDx, Dimension,  0);
    Dimension shadowDy = ATTR_ReadAttr(A_shadowDy, Dimension, -3);
    
    self.shadowOffset  = CGSizeMake(shadowDx, shadowDy);
    self.shadowOpacity = ATTR_ReadAttr(A_shadowOpacity, CGFloat, 0);
    self.shadowColor   = ATTR_ReadAttr(A_shadowColor,   UIColor, nil);
    self.shadowRadius  = ATTR_ReadAttr(A_shadowRadius,  CGFloat, 3);
}

@end

@implementation ShapeDrawable
{
    CAGradientLayer* _gradientLayer;
}

- (void)parseAttr:(AttributeReader *)attrReader
{
    [super parseAttr:attrReader];
    
    NSString* shape = ATTR_ReadAttr(A_shape, NSString, @"rectangle");
    NSDictionary* shapeMap = @{
        @"rectangle": @(ShapeRectangle),
        @"oval"     : @(ShapeOval),
        @"line"     : @(ShapeLine),
        @"ring"     : @(ShapeRing)
    };
    
    self.shape = [shapeMap[shape] intValue];
    
    NSArray *children = ATTR_ReadAttr(A_children, NSArray, nil);
    if (isNSArray(children) && children.count > 0)
    {
        NSDictionary *selectDict = @{
                                     ValueKey(A_padding)    : @"parsePaddingAttr:",
                                     ValueKey(A_size)       : @"parseSizeAttr:",
                                     ValueKey(A_corners)    : @"parseCornersAttr:",
                                     ValueKey(A_solid)      : @"parseSolidAttr:",
                                     ValueKey(A_stroke)     : @"parseStrokeAttr:",
                                     ValueKey(A_gradient)   : @"parseGradientAttr:",
                                     ValueKey(A_shadow)     : @"parseShadowAttr:"
                                     };
        
        [children enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *classStr = obj[@"class"];
            if (classStr.length > 0)
            {
                NSString *selectorStr = selectDict[classStr];
                if (selectorStr)
                {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [self performSelector:NSSelectorFromString(selectorStr) withObject:[[AttributeReader alloc] initWithDictionary:obj resMgr:attrReader.resourceManager]];
#pragma clang diagnostic pop
                }
            }
        }];
    }
    
    self.ringThickness          = ATTR_ReadAttr(A_thickness, Dimension, 0);
    self.ringInnerRadius        = ATTR_ReadAttr(A_innerRadius, Dimension, 0);
    self.ringThicknessRatio     = ATTR_ReadAttr(A_thicknessRatio, CGFloat, 0);
    self.ringInnerRadiusRatio   = ATTR_ReadAttr(A_innerRadiusRatio, CGFloat, 0);
    self.ringUseLevel           = ATTR_ReadAttr(A_useLevel, BOOL, NO);
}

- (void)parsePaddingAttr:(AttributeReader *)attrReader
{
    UIEdgeInsets paddingInsets = UIEdgeInsetsZero;
    paddingInsets.top    = ATTR_ReadAttr(A_top,    Dimension, 0);
    paddingInsets.left   = ATTR_ReadAttr(A_left,   Dimension, 0);
    paddingInsets.bottom = ATTR_ReadAttr(A_bottom, Dimension, 0);
    paddingInsets.right  = ATTR_ReadAttr(A_right,  Dimension, 0);
    self.padding = paddingInsets;
}

- (void)parseSizeAttr:(AttributeReader *)attrReader
{
    CGSize size = CGSizeZero;
    size.width     = ATTR_ReadAttr(A_width,     Dimension,  INT_MIN);
    size.height    = ATTR_ReadAttr(A_height,    Dimension,  INT_MIN);
    self.size = size;
}

- (void)parseCornersAttr:(AttributeReader *)attrReader
{
    UICornerRadius cornerRadius = UICornerRadiusZero;
    CGFloat radius = ATTR_ReadAttr(A_radius, Dimension, 0);
    cornerRadius.topLeft     = ATTR_ReadAttr(A_topLeftRadius,     Dimension, radius);
    cornerRadius.topRight    = ATTR_ReadAttr(A_topRightRadius,    Dimension, radius);
    cornerRadius.bottomRight = ATTR_ReadAttr(A_bottomRightRadius, Dimension, radius);
    cornerRadius.bottomLeft  = ATTR_ReadAttr(A_bottomLeftRadius,  Dimension, radius);
    self.cornerRadius = cornerRadius;
}

- (void)parseSolidAttr:(AttributeReader *)attrReader
{
    self.solidColor = ATTR_ReadAttr(A_color, UIColor, UIColor.blackColor);
}

- (void)parseStrokeAttr:(AttributeReader *)attrReader
{
    self.stroke = [[ShapeStroke alloc] init];
    [self.stroke parseAttr:attrReader];
}

- (void)parseGradientAttr:(AttributeReader *)attrReader
{
    self.gradient = [[ShapeGradient alloc] init];
    [self.gradient parseAttr:attrReader];
}

- (void)parseShadowAttr:(AttributeReader *)attrReader
{
    self.shadow = [[ShapeShadow alloc] init];
    [self.shadow parseAttr:attrReader];
}

#define FloatEq(_A_, _B_) (ABS(_A_ - _B_) <= (1e-6))
- (void)attachBackground:(CALayer *)layer stateView:(UIView *)control
{
    CAShapeLayer *borderLayer   = [self getBorderLayer:layer];
    CAShapeLayer *maskLayer     = [self getMaskLayer:layer];
    
    switch (_shape)
    {
        case ShapeRectangle:
        {
            if (FloatEq(_cornerRadius.topLeft, _cornerRadius.topRight) &&
                FloatEq(_cornerRadius.topLeft, _cornerRadius.bottomLeft) &&
                FloatEq(_cornerRadius.topLeft, _cornerRadius.bottomRight))
            {
                CGRect frame = control.frame;
                CGFloat minSideLength = MIN(frame.size.height, frame.size.width);
                minSideLength /= 2;
                layer.cornerRadius  = MIN(_cornerRadius.topLeft, minSideLength);
                layer.masksToBounds = YES;
                
                if (_stroke)
                {
                    if (_stroke.dashWidth && _stroke.dashGap)
                    {
                        UIBezierPath* rectRadiuPath = [UIBezierPath bezierPathWithRect: layer.bounds];
                        [rectRadiuPath closePath];
                        [self addLayerBorderPath:rectRadiuPath borderLayer:borderLayer layer:layer stroke:_stroke];
                    }
                    else
                    {
                        layer.borderColor   = _stroke.color.CGColor;
                        layer.borderWidth   = _stroke.width;
                    }
                }
            }
            else
            {
                UIBezierPath *rectRadiuPath = [UIBezierPath new];
                CGFloat layerW = CGRectGetWidth(layer.bounds);
                CGFloat layerH = CGRectGetHeight(layer.bounds);
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

                [self addLayerMaskPath:rectRadiuPath maskLayer:maskLayer layer:layer];
                
                if (_stroke)
                {
                    [self addLayerBorderPath:[rectRadiuPath copy] borderLayer:borderLayer layer:layer stroke:_stroke];
                }
            }
        }
            break;
            
        case ShapeOval:
        {
            UIBezierPath* rectRadiuPath = [UIBezierPath bezierPathWithOvalInRect:layer.bounds];
            [rectRadiuPath closePath];
        
            [self addLayerMaskPath:rectRadiuPath maskLayer:maskLayer layer:layer];
            
            if (_stroke)
            {
                [self addLayerBorderPath:rectRadiuPath borderLayer:borderLayer layer:layer stroke:_stroke];
            }
        }
            
            break;
            
        case ShapeLine:
            break;
            
        case ShapeRing:
            //            self.ringThickness
            //            self.ringInnerRadius
            //            self.ringThicknessRatio
            //            self.ringInnerRadiusRatio
            //            self.ringUseLevel
            break;
            
        default:
            break;
    }
    
    if(self.gradient)
    {
        CAGradientLayer *gradientLayer = _gradientLayer;
        if(!gradientLayer)
            gradientLayer =  [CAGradientLayer layer];
        gradientLayer.frame = layer.bounds;
        [gradientLayer setColors:[NSArray arrayWithObjects:(id)[self.gradient.startColor CGColor],(id)[self.gradient.endColor CGColor], nil]];
        
        CGPoint startPoint = CGPointZero;
        CGPoint endPoint = CGPointZero;
        switch (self.gradient.angle) {
            case 0:
                endPoint.x = 1;
                break;
            case 45:
                startPoint.y = 1;
                endPoint.x = 1;
                break;
            case 90:
                startPoint.y = 1;
                break;
            case 135:
                startPoint.x = 1;
                startPoint.y = 1;
                break;
            case 180:
                startPoint.x = 1;
                break;
            case 225:
                startPoint.x = 1;
                endPoint.y = 1;
                break;
            case 270:
                endPoint.y = 1;
                break;
            case 315:
                endPoint.x = 1;
                endPoint.y = 1;
                break;
            default:
                break;
        }
        gradientLayer.startPoint = startPoint;
        gradientLayer.endPoint = endPoint;
        
        if(!_gradientLayer){
            _gradientLayer = gradientLayer;
            [layer insertSublayer:gradientLayer atIndex:0];
        }
    }
    else if(self.solidColor)
    {
        layer.backgroundColor = self.solidColor.CGColor;
    }
    
    if(!self.gradient)
    {
        [_gradientLayer removeFromSuperlayer];
        _gradientLayer = nil;
    }
    
    if(self.stroke)
    {
        
    }
    
    if(self.shadow)
    {
        layer.masksToBounds = NO;
        layer.shadowColor   = self.shadow.shadowColor.CGColor;
        layer.shadowOffset  = self.shadow.shadowOffset;
        layer.shadowRadius  = self.shadow.shadowRadius;
        layer.shadowOpacity = 1;
    }
}

- (void)attachUIColor:(id)view forKey:(NSString *)colorKey stateView:(UIView *)control
{

}

- (CAShapeLayer *)getBorderShapeLayer:(CALayer *)layer
{
    
    CAShapeLayer *borderLayer = nil;
    NSArray *arrTmp = [layer sublayers];
    for (CAShapeLayer *tmp in arrTmp)
    {
        if ([tmp isKindOfClass:[CAShapeLayer class]] && [tmp.name isEqualToString:__ALayoutBorderShapeLayer])
        {
            borderLayer = tmp;
            break;
        }
    }
    
    if (!borderLayer)
    {
        borderLayer = [CAShapeLayer new];
        borderLayer.name = __ALayoutBorderShapeLayer;
//        borderLayer.lineCap = kCALineCapRound;  // 线条拐角
//        borderLayer.lineJoin = kCALineCapRound;   //  终点处理
        borderLayer.fillColor   = [[UIColor clearColor] CGColor];
//        [layer insertSublayer:borderLayer atIndex:0];
        [layer addSublayer:borderLayer];
    }

    return borderLayer;
}

- (void)removeBorderShapeLayer:(CALayer *)layer
{
    NSArray *arrTmp = [layer sublayers];
    for (CAShapeLayer *tmp in arrTmp)
    {
        if ([tmp isKindOfClass:[CAShapeLayer class]] && [tmp.name isEqualToString:__ALayoutBorderShapeLayer])
        {
            [tmp removeFromSuperlayer];
            break;
        }
    }
}

- (CAShapeLayer *)getMaskShapeLayer:(CALayer *)layer
{
    CAShapeLayer *maskLayer = (CAShapeLayer *)layer.mask;
    if (maskLayer)
    {
        if ([maskLayer isKindOfClass:[CAShapeLayer class]] && [maskLayer.name isEqualToString:__ALayoutMaskShapeLayer])
        {
            return maskLayer;
        }
    }
    else
    {
        maskLayer       = [CAShapeLayer new];
        maskLayer.name  = __ALayoutMaskShapeLayer;
        layer.mask      = maskLayer;
    }
    return maskLayer;
}

- (void)removeMaskShapeLayer:(CALayer *)layer
{
    CAShapeLayer *maskLayer = (CAShapeLayer *)layer.mask;
    if (maskLayer && [maskLayer isKindOfClass:[CAShapeLayer class]] && [maskLayer.name isEqualToString:__ALayoutMaskShapeLayer])
    {
        layer.mask = nil;
    }
}


- (CAShapeLayer *)getMaskLayer:(CALayer *)layer
{
    CAShapeLayer *maskeLayer = nil;
    if (_shape == ShapeRectangle)
    {
        if (!FloatEq(_cornerRadius.topLeft, _cornerRadius.topRight) ||
            !FloatEq(_cornerRadius.topLeft, _cornerRadius.bottomLeft) ||
            !FloatEq(_cornerRadius.topLeft, _cornerRadius.bottomRight))
        {
            maskeLayer = [self getMaskShapeLayer:layer];
        }
        else
        {
            [self removeMaskShapeLayer:layer];
        }
    }
    else if (_shape == ShapeOval)
    {
        maskeLayer = [self getMaskShapeLayer:layer];
    }
    else
    {
        [self removeMaskShapeLayer:layer];
    }
    
    return maskeLayer;
}

- (CAShapeLayer *)getBorderLayer:(CALayer *)layer
{
    if ((ShapeRectangle == _shape || ShapeOval == _shape) || _stroke)
    {
        return [self getBorderShapeLayer:layer];
    }
    else
    {
        [self removeBorderShapeLayer:layer];
    }
    
    return nil;
}

- (void)addLayerMaskPath:(UIBezierPath *)path maskLayer:(CAShapeLayer *)maskLayer layer:(CALayer *)layer
{
    maskLayer.frame = layer.bounds;
    maskLayer.path = path.CGPath;
    maskLayer.fillColor =  self.solidColor.CGColor;
}

- (void)addLayerBorderPath:(UIBezierPath *)path borderLayer:(CAShapeLayer *)borderLayer layer:(CALayer *)layer stroke:(ShapeStroke *)stroke
{
    borderLayer.frame = layer.bounds;
    
    if (_stroke.dashGap > 0 && _stroke.dashWidth > 0)
    {
        [borderLayer setLineDashPattern:@[@(_stroke.dashWidth),@(_stroke.dashGap)]];
        [borderLayer setLineJoin:kCALineJoinRound];
    }
    else
    {
        [borderLayer setLineDashPattern:nil];
    }
    
    if (_stroke.color)
    {
        borderLayer.strokeColor = _stroke.color.CGColor;
    }
    else
    {
        borderLayer.strokeColor = nil;
    }
    
    borderLayer.lineWidth   = _stroke.width;
    borderLayer.path        = [path CGPath];
}

- (void)reset:(nullable UIView*)stateView
{
    [_gradientLayer removeFromSuperlayer];
    _gradientLayer = nil;
    
    [self removeBorderShapeLayer:stateView.layer];
    [self removeMaskShapeLayer:stateView.layer];
    
    if(self.shadow)
    {      
        stateView.layer.shadowOffset = CGSizeMake(0, -3);
        stateView.layer.shadowOpacity = 0;
        stateView.layer.shadowColor   = nil;
        stateView.layer.shadowRadius  = 3;
    }
}

@end
