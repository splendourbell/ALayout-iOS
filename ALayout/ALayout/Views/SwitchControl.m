//
//  SwitchControl.m
//  ALayout
//
//  Created by Peak.Liu on 2017/6/20.
//  Copyright © 2017年 com.aiospace.zone. All rights reserved.
//

#import "SwitchControl.h"
#import "Drawable.h"
#import "AViewCreator.h"
#import "UIView+Params.h"

@interface SwitchControl ()
{
    UISwitch        *_switch;
}
@end

@implementation SwitchControl

RegisterView(SwitchControl)

- (void)parseAttr:(AttributeReader *)attrReader useDefault:(BOOL)useDefault
{
    [super parseAttr:attrReader useDefault:useDefault];
    BOOL on = YES;
    ATTR_ReadAttrEq(on,            on,             BOOL,       NO);
    ATTR_ReadAttrEq(_onImage,       onImage,        UIImage,    nil);
    ATTR_ReadAttrEq(_offImage,      offImage,       UIImage,    nil);
    ATTR_ReadAttrEq(_onTintColor,   A_onTintColor,  UIColor,    nil);
    ATTR_ReadAttrEq(_scale,   scale,  CGFloat,    1.0);
    [self.switchControl setOn:on animated:NO];
}

//ddih
- (void)onMeasure:(MeasureSpec)widthSpec heightSpec:(MeasureSpec)heightSpec
{
    CGAffineTransform mtrx = CGAffineTransformIdentity;
    _switch.layer.affineTransform = CGAffineTransformScale(mtrx, self.scale, self.scale);
    [self setMeasuredDimensionRaw:_switch.frame.size];
}

- (UISwitch *)switchControl
{
    if (!_switch)
    {
        _switch = [[UISwitch alloc] init];
        [self addSubview:_switch];
        [_switch addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _switch;
}

- (void)onLayout:(CGRect)rect
{
    [super onLayout:rect];
    
    UISwitch *switchView    = self.switchControl;
    switchView.onImage  = _onImage;
    switchView.offImage = _offImage;
    switchView.onTintColor = _onTintColor;
}


- (void)setOn:(BOOL)on
{
    [self.switchControl setOn:on animated:YES];
}

- (BOOL)isOn 
{
    return self.switchControl.isOn;
}

- (void)setEnabled:(BOOL)enabled
{
    [self.switchControl setEnabled:enabled];
}

- (BOOL)isEnabled
{
    return self.switchControl.isEnabled;
}

- (void)switchValueChange:(UISwitch *)switchView
{
    if (_valueChanged)
    {
        _valueChanged(self.switchControl);
    }
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self.switchControl addTarget:target action:action forControlEvents:controlEvents];
}

- (void)dealloc
{
    [self.viewParams.backgroud detach:self];
}

@end
