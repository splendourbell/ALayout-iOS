//
//  RelativeLayoutParams.m
//  ALayout
//
//  Created by splendourbell on 2017/4/11.
//  Copyright © 2017年 ajja.sdjkf.sd. All rights reserved.
//

#import "RelativeLayoutParams.h"
#import <objc/message.h>

@implementation RelativeLayoutParams

- (void)parseAttr:(AttributeReader*)attrReader useDefault:(BOOL)useDefault
{
    if (!_rules)
    {
        _rules = [NSMutableDictionary dictionary];
    }
    
//    _alignWithParent = ATTR_ReadAttr(A_layout_alignWithParentIfMissing, BOOL, NO);
//    
//    _rules[@(RelativeLayout_LEFT_OF)]   = ATTR_ReadAttr(A_layout_toLeftOf, NSString, nil);
//    _rules[@(RelativeLayout_RIGHT_OF)]  = ATTR_ReadAttr(A_layout_toRightOf, NSString, nil);
//    _rules[@(RelativeLayout_ABOVE)]     = ATTR_ReadAttr(A_layout_above, NSString, nil);
//    _rules[@(RelativeLayout_BELOW)]     = ATTR_ReadAttr(A_layout_below, NSString, nil);
//    
//    _rules[@(RelativeLayout_ALIGN_LEFT)]   = ATTR_ReadAttr(A_layout_alignLeft, NSString, nil);
//    _rules[@(RelativeLayout_ALIGN_TOP)]    = ATTR_ReadAttr(A_layout_alignTop, NSString, nil);
//    _rules[@(RelativeLayout_ALIGN_RIGHT)]  = ATTR_ReadAttr(A_layout_alignRight, NSString, nil);
//    _rules[@(RelativeLayout_ALIGN_BOTTOM)] = ATTR_ReadAttr(A_layout_alignBottom, NSString, nil);
//    _rules[@(RelativeLayout_ALIGN_START)]  = ATTR_ReadAttr(A_layout_alignStart, NSString, nil);
//    _rules[@(RelativeLayout_ALIGN_END)]    = ATTR_ReadAttr(A_layout_alignEnd, NSString, nil);
    
    
//    _rules[@(RelativeLayout_ALIGN_PARENT_LEFT)]   = ATTR_ReadAttr(A_layout_alignParentLeft, BOOL, NO)?@(YES):nil;
//    _rules[@(RelativeLayout_ALIGN_PARENT_TOP)]    = ATTR_ReadAttr(A_layout_alignParentTop, BOOL, NO)?@(YES):nil;
//    _rules[@(RelativeLayout_ALIGN_PARENT_RIGHT)]  = ATTR_ReadAttr(A_layout_alignParentRight, BOOL, NO)?@(YES):nil;
//    _rules[@(RelativeLayout_ALIGN_PARENT_BOTTOM)] = ATTR_ReadAttr(A_layout_alignParentBottom, BOOL, NO)?@(YES):nil;
//    
//    _rules[@(RelativeLayout_CENTER_IN_PARENT)]    = ATTR_ReadAttr(A_layout_centerInParent, BOOL, NO)?@(YES):nil;
//    _rules[@(RelativeLayout_CENTER_HORIZONTAL)]   = ATTR_ReadAttr(A_layout_centerHorizontal, BOOL, NO)?@(YES):nil;
//    _rules[@(RelativeLayout_CENTER_VERTICAL)]     = ATTR_ReadAttr(A_layout_centerVertical, BOOL, NO)?@(YES):nil;
    
    [super parseAttr:attrReader useDefault:useDefault];
    
    ATTR_ReadAttrEq(_alignWithParent, A_layout_alignWithParentIfMissing, BOOL, NO);
    
    ATTR_ReadAttrEq(_rules[@(RelativeLayout_LEFT_OF)],  A_layout_toLeftOf, NSString, nil);
    ATTR_ReadAttrEq(_rules[@(RelativeLayout_RIGHT_OF)], A_layout_toRightOf, NSString, nil);
    ATTR_ReadAttrEq(_rules[@(RelativeLayout_ABOVE)],    A_layout_above, NSString, nil);
    ATTR_ReadAttrEq(_rules[@(RelativeLayout_BELOW)],    A_layout_below, NSString, nil);
    
    ATTR_ReadAttrEq(_rules[@(RelativeLayout_ALIGN_LEFT)],   A_layout_alignLeft, NSString, nil);
    ATTR_ReadAttrEq(_rules[@(RelativeLayout_ALIGN_TOP)],    A_layout_alignTop, NSString, nil);
    ATTR_ReadAttrEq(_rules[@(RelativeLayout_ALIGN_RIGHT)],  A_layout_alignRight, NSString, nil);
    ATTR_ReadAttrEq(_rules[@(RelativeLayout_ALIGN_BOTTOM)], A_layout_alignBottom, NSString, nil);
    ATTR_ReadAttrEq(_rules[@(RelativeLayout_ALIGN_START)],  A_layout_alignStart, NSString, nil);
    ATTR_ReadAttrEq(_rules[@(RelativeLayout_ALIGN_END)],    A_layout_alignEnd, NSString, nil);
    
    if (useDefault)
    {
        _rules[@(RelativeLayout_ALIGN_PARENT_LEFT)]   = ATTR_ReadAttr(A_layout_alignParentLeft, BOOL, NO)?@(YES):nil;
        _rules[@(RelativeLayout_ALIGN_PARENT_TOP)]    = ATTR_ReadAttr(A_layout_alignParentTop, BOOL, NO)?@(YES):nil;
        _rules[@(RelativeLayout_ALIGN_PARENT_RIGHT)]  = ATTR_ReadAttr(A_layout_alignParentRight, BOOL, NO)?@(YES):nil;
        _rules[@(RelativeLayout_ALIGN_PARENT_BOTTOM)] = ATTR_ReadAttr(A_layout_alignParentBottom, BOOL, NO)?@(YES):nil;
        
        _rules[@(RelativeLayout_CENTER_IN_PARENT)]    = ATTR_ReadAttr(A_layout_centerInParent, BOOL, NO)?@(YES):nil;
        _rules[@(RelativeLayout_CENTER_HORIZONTAL)]   = ATTR_ReadAttr(A_layout_centerHorizontal, BOOL, NO)?@(YES):nil;
        _rules[@(RelativeLayout_CENTER_VERTICAL)]     = ATTR_ReadAttr(A_layout_centerVertical, BOOL, NO)?@(YES):nil;
    }
    else
    {
        
#define ATTR_ReadRelativeAttr(KEY1, KEY2) \
if ([attrReader hasKey:ValueKey(KEY1)]) \
{ \
    _rules[@(KEY2)]   = ATTR_ReadAttr(KEY1, BOOL, NO)?@(YES):nil; \
}
        
        ATTR_ReadRelativeAttr(A_layout_alignParentLeft,     RelativeLayout_ALIGN_PARENT_LEFT)
        ATTR_ReadRelativeAttr(A_layout_alignParentTop,      RelativeLayout_ALIGN_PARENT_TOP)
        ATTR_ReadRelativeAttr(A_layout_alignParentRight,    RelativeLayout_ALIGN_PARENT_RIGHT)
        ATTR_ReadRelativeAttr(A_layout_alignParentBottom,   RelativeLayout_ALIGN_PARENT_BOTTOM)
        
        ATTR_ReadRelativeAttr(A_layout_centerInParent,      RelativeLayout_CENTER_IN_PARENT)
        ATTR_ReadRelativeAttr(A_layout_centerHorizontal,    RelativeLayout_CENTER_HORIZONTAL)
        ATTR_ReadRelativeAttr(A_layout_centerVertical,      RelativeLayout_CENTER_VERTICAL)
        
#undef ATTR_ReadRelativeAttr
    }
}

- (RelativeRule*)getRules:(int)layoutDirection
{
    return _rules;
}

- (void)setRule:(id)rule forType:(RelativeLayoutType)type
{
    if (!_rules)
    {
        _rules = [NSMutableDictionary dictionary];
    }
    _rules[@(type)] = rule;
}


@end
