//
//  EffectView.m
//  ALayout
//
//  Created by splendourbell on 2019/7/12.
//  Copyright © 2019 splendourbell All rights reserved.
//

#import "EffectView.h"
#import "AttributeReader.h"
#import "UIView+Params.h"
#import "UIView+ALayout.h"

@implementation EffectView
{
    NSArray<NSString*>* _effectStyleEnums;
    UIBlurEffectStyle _usingEffectStyle;
    BOOL _usingVibrancy;
}

- (void)parseAttr:(AttributeReader *)attrReader useDefault:(BOOL)useDefault
{
    [super parseAttr:attrReader useDefault:useDefault];
    ATTR_ReadAttrEq(_effectStyle,  A_effectStyle, NSString, nil);
    ATTR_ReadAttrEq(_vibrancy,  A_vibrancy, BOOL, NO);
    
    _usingEffectStyle = -1;
    if(!_effectStyleEnums)
    {
        _effectStyleEnums = @[@"ExtraLight", @"Light", @"Dark", @"ExtraDark", @"Regular", @"Prominent"];
    }
}

- (void)onLayout:(CGRect)rect
{
    UIBlurEffectStyle style = -1;
    if(_effectStyle)
    {
        style = [_effectStyleEnums indexOfObject:_effectStyle];
        if(NSNotFound == style )
        {
            style = -1;
        }
    }
    
    if(_usingEffectStyle != style || _vibrancy != _usingVibrancy)
    {
        if(-1 ==(NSInteger)style) {
            self.effect = nil;
        }
        else {
            if(_vibrancy){
                self.effect = [UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:style]];
            } else {
                self.effect = [UIBlurEffect effectWithStyle:style];
            }
        }
    }
    _usingVibrancy = _vibrancy;
    _usingEffectStyle = style;
}

- (void)setEffectStyle:(NSString *)effectStyle
{
    _effectStyle = [effectStyle copy];
    [self requestLayout];
}

@end
