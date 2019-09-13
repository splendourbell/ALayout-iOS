//
//  UIView+Params.m
//  ALayout
//
//  Created by splendourbell on 2017/4/19.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import <objc/runtime.h>
#import "UIView+Params.h"
#import "UIView+ALayout.h"
#import "Drawable.h"
#import "LayoutParams.h"
#import "UIView+DataBinder.h"
#import "AAction.h"

@protocol NoUsedProtocol
@optional
- (void)extParseAttr:(AttributeReader*)attrReader useDefault:(BOOL)useDefault; 
@end


static void* RegisterViewParsePropertyKey = &RegisterViewParsePropertyKey;

NSArray<ParseAttrBlock>* GetViewParsePropertyByClass(Class cls)
{
    return objc_getAssociatedObject(cls, RegisterViewParsePropertyKey);
}

void RegisterViewParsePropertyByClass(Class cls, ParseAttrBlock parseAttrBlock)
{
    if(parseAttrBlock)
    {
        NSMutableArray<ParseAttrBlock>* existPro = (NSMutableArray<ParseAttrBlock>*)GetViewParsePropertyByClass(cls);
        if(!existPro)
        {
            existPro = [NSMutableArray array];
        }
        [existPro addObject:parseAttrBlock];
        objc_setAssociatedObject(cls, RegisterViewParsePropertyKey, existPro, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@interface ViewParams()

@property (nonatomic, readwrite) NSMutableDictionary<NSString*, VoidBlock_CGRect>* willLayouts;

@property (nonatomic, readwrite) NSMutableDictionary<NSString*, VoidBlock_CGRect>* didLayouts;

@property (nonatomic) BOOL hasSetMeasuredSize;

@property (nonatomic, readwrite) CGSize measuredSize;

@end

@implementation ViewParams
{
    __weak UIView* _hostView;
}

- (instancetype)initWithHost:(UIView*)view
{
    if(self = [self init])
    {
        _hostView = view;
        _requestLayout = YES;
    }
    return self;
}

- (NSMutableDictionary<NSString*, NSValue*>*)measureCache
{
    if(!_measureCache)
    {
        _measureCache = [NSMutableDictionary new];
    }
    return _measureCache;
}

- (void)setVisibility:(VisibilityMode)visibilityMode
{
    if(Visibility_VISIBLE == visibilityMode)
    {
        if(_hostView.isHidden) _hostView.hidden = NO;
    }
    else
    {
        if(!_hostView.isHidden) _hostView.hidden = YES;
    }
    _hostView.viewParams.requestLayout = NO;
    _visibility = visibilityMode;

    [_hostView requestLayout];
}

- (void)setEnabled:(BOOL)enabled
{
    if(enabled != _hostView.userInteractionEnabled)
    {
        _hostView.userInteractionEnabled = enabled;
    }
}

- (void)setMinSize:(CGSize)minSize
{
    _minSize = minSize;
    [_hostView requestLayout];
}

- (void)setPadding:(UIEdgeInsets)padding
{
    _padding = padding;
    [_hostView requestLayout];
}

- (id)extData
{
    if(_extData)
    {
        return _extData;
    }
    else
    {
        return _hostView.superview.viewParams.extData;
    }
}

@end

@interface UIResponder(enabled)
- (void)setEnabled:(BOOL)enabled;
@end
@implementation UIResponder(enabled)
- (void)setEnabled:(BOOL)enabled {}
@end

@implementation UIView(ViewParams)

- (ViewParams*)viewParams
{
    static void* KEY_viewParams = &KEY_viewParams;
    
    ViewParams* viewParams = objc_getAssociatedObject(self, KEY_viewParams);
    if(!viewParams)
    {
        viewParams = [[ViewParams alloc] initWithHost:self];
        viewParams.requestLayout = NO;
        objc_setAssociatedObject(self, KEY_viewParams, viewParams, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return viewParams;
}

- (void)parseAttr:(AttributeReader*)attrReader
{
    [self parseAttr:attrReader useDefault:YES];
}

- (void)parseAttr:(AttributeReader*)attrReader useDefault:(BOOL)useDefault
{
    if(useDefault)
    {
        [attrReader addDefaultAttribute:self.defaultStyle];
    }

    ViewParams* viewParams = self.viewParams;
    
    if(attrReader[@"extData"])
    {
        viewParams.extData = attrReader[@"extData"];
    }
    CGSize minSize     = viewParams.minSize;
    ATTR_ReadAttrEq(minSize.width,  A_minWidth,     Dimension, 0);
    ATTR_ReadAttrEq(minSize.height, A_minHeight,    Dimension, 0);
    viewParams.minSize = minSize;
    
    CGSize maxSize     = viewParams.maxSize;
    ATTR_ReadAttrEq(maxSize.width,  A_maxHeight,    Dimension, MAXFLOAT);
    ATTR_ReadAttrEq(maxSize.height, A_maxHeight,    Dimension, MAXFLOAT);
    viewParams.maxSize = maxSize;
    
    ATTR_ReadAttrEq(self.exclusiveTouch, A_exclusiveTouch, BOOL, YES);
    
    UIEdgeInsets paddingInsets = UIEdgeInsetsZero;
    if (!useDefault)
    {
        paddingInsets = viewParams.padding;
    }
    
    CGFloat paddings = -1;
    ATTR_ReadAttrEq(paddings, A_padding, Dimension, -1);
    if(paddings < 0)
    {
        ATTR_ReadAttrEq(paddingInsets.top,    A_paddingTop,    Dimension, 0);
        ATTR_ReadAttrEq(paddingInsets.left,   A_paddingLeft,   Dimension, 0);
        ATTR_ReadAttrEq(paddingInsets.bottom, A_paddingBottom, Dimension, 0);
        ATTR_ReadAttrEq(paddingInsets.right,  A_paddingRight,  Dimension, 0);
    }
    else
    {
        paddingInsets.top    = paddings;
        paddingInsets.left   = paddings;
        paddingInsets.bottom = paddings;
        paddingInsets.right  = paddings;
    }
    viewParams.padding = paddingInsets;
    
    Drawable* oldBackgroud = viewParams.backgroud;
    if(oldBackgroud && [attrReader hasKey:ValueKey(A_background)])
    {
        [oldBackgroud reset:self];
    }
    
    ATTR_ReadAttrEq(viewParams.backgroud, A_background, Drawable, nil);
    if(viewParams.backgroud)
    {
        __weak typeof(self) weakSelf = self;
        [self addDidLayoutBlock:@"UIView_backgroud" block:^(CGRect rect) {
            typeof(self) strongSelf = weakSelf;
            if(strongSelf)
            {
                [strongSelf.viewParams.backgroud attachBackground:strongSelf.layer stateView:strongSelf];
            }
        }];
    }
    ATTR_ReadAttrEq(self.tag,  A_tag, int, 0);
    ATTR_ReadAttrEq(self.viewId,  A_id, NSString, nil);
    ATTR_ReadAttrEq(viewParams.clickable, A_clickable, BOOL, NO);
    
    if(ATTR_CanRead(A_enabled))
    {
        BOOL enabled = ATTR_ReadAttr(A_enabled, BOOL, YES);
        [self setEnabled:enabled];
    }
    
    if(ATTR_CanRead(A_selected))
    {
        BOOL selected = ATTR_ReadAttr(A_selected, BOOL, NO);
        [self setSelected:selected];
    }
    
    if (ATTR_CanRead(A_dataBinder))
    {
        NSString* dataBinder = ATTR_ReadAttr(A_dataBinder, NSString, nil);
        if([dataBinder hasPrefix:@"@script/"])
        {
            dataBinder = [dataBinder substringFromIndex:@"@script/".length];
        }
        viewParams.dataBinder = dataBinder;
    }
    
    if (ATTR_CanRead(A_visibility))
    {
        NSString* visibilityStr = ATTR_ReadAttr(A_visibility, NSString, nil);
        if([visibilityStr isEqualToString:@"invisible"])
        {
            viewParams.visibility = Visibility_INVISIBLE;
        }
        else if([visibilityStr isEqualToString:@"gone"])
        {
            viewParams.visibility = Visibility_GONE;
        }
        else// default "visible"
        {
            viewParams.visibility = Visibility_VISIBLE;
        }
    }
    
    if ([attrReader hasKey:ValueKey(A_ios_action)])
    {
        assert([self isKindOfClass:UIControl.class]);
        NSString* actionString = ATTR_ReadAttr(A_ios_action, NSString, nil);
        AAction* action = [AAction actionWithString:actionString];
        BOOL attached = [(UIControl*)self attachAction:action withTarget:attrReader.target forControlEvents:UIControlEventTouchUpInside];
        if(!attached)
        {
            [(UIControl*)self detachActionWithTarget:attrReader.target forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    if([self respondsToSelector:@selector(extParseAttr:useDefault:)])
    {
        NSMethodSignature *sig = [self.class instanceMethodSignatureForSelector:@selector(extParseAttr:useDefault:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        invocation.target = self;
        invocation.selector = @selector(extParseAttr:useDefault:);
        [invocation setArgument:&attrReader atIndex:2];
        [invocation setArgument:&useDefault atIndex:3];
        [invocation invoke];
    }
//    
//    
//    NSArray<NSString*>* customParsekeys = GetViewParsePropertyByClass(self.class);
//    for(NSString* key in customParsekeys)
//    {
//        if(useDefault || [attrReader hasKey:key])
//        {
//            [self setValue:attrReader[key] forKey:key];
//        }
//    }
    
    if (!useDefault)
    {
        [self.layoutParams parseAttr:attrReader useDefault:useDefault];
    }
    
    //TODO: read specil key
    NSDictionary *delayBindData = [attrReader fetchPrefixStr:@"params_"];
    if (delayBindData.count > 0)
    {
        self.viewParams.delayBindData = delayBindData;
    }
    
    [self requestLayout];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    self.viewParams.enabled = enabled;
}

- (void)setSelected:(BOOL)selected
{
    
}

- (NSMutableDictionary*)defaultStyle
{
    return @{ValueKey(A_clickable) : @"false"}.mutableCopy;
}

static void* KEY_viewId = &KEY_viewId;

- (NSString*)viewId
{
    return objc_getAssociatedObject(self, KEY_viewId);
}

- (void)setViewId:(NSString *)viewId
{
    objc_setAssociatedObject(self, KEY_viewId, viewId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (__kindof UIView*)objectForKeyedSubscript:(NSString*)viewId
{
    NSArray* array = [viewId componentsSeparatedByString:@"."];
    NSInteger i = 0;
    UIView* view = self;
    do {
        view = [view findByViewId:array[i]];
    }while(++i < array.count);
    return view;
}

- (__kindof UIView*)findSuperviewByViewId:(NSString*)viewId
{
    if (self.viewId.hash == viewId.hash)
    {
        return self;
    }
    else
    {
        return [self.superview findSuperviewByViewId:viewId];
    }
}

- (__kindof UIView*)findByViewId:(NSString*)viewId
{
    return [self findByViewIdHash:[viewId hash]];
}

- (__kindof UIView *)findByViewIdHash:(NSUInteger)viewIdHash
{
    if ([self.viewId hash] == viewIdHash)
    {
        return self;
    }
    else
    {
        NSArray* subViews = self.subviews;
        for(UIView* view in subViews)
        {
            UIView* subView = [view findByViewIdHash:viewIdHash];
            if(subView)
            {
                return subView;
            }
        }
        return nil;
    }
}

- (void)addWillLayoutBlock:(NSString*)key block:(VoidBlock_CGRect)willLayout
{
    ViewParams* viewParams = self.viewParams;
    if(!viewParams.willLayouts)
    {
        viewParams.willLayouts = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    key = key ?: @"_default_";
    viewParams.willLayouts[key] = willLayout;
}

- (void)removeWillLayoutBlock:(NSString*)key
{
    ViewParams* viewParams = self.viewParams;
    key = key ?: @"_default_";
    [viewParams.willLayouts removeObjectForKey:key];
}

- (void)addDidLayoutBlock:(NSString*)key block:(VoidBlock_CGRect)didLayout
{
    ViewParams* viewParams = self.viewParams;
    if(!viewParams.didLayouts)
    {
        viewParams.didLayouts = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    key = key ?: @"_default_";
    viewParams.didLayouts[key] = didLayout;
}

- (void)removeDidLayoutBlock:(NSString*)key
{
    ViewParams* viewParams = self.viewParams;
    key = key ?: @"_default_";
    [viewParams.didLayouts removeObjectForKey:key];
}

- (void)onAddChildrenFinished
{
    if (self.viewParams.delayBindData)
    {
        [self autoBindData:self.viewParams.delayBindData];
    }
}

- (NSString*)mainKey
{
    return nil;
}

@end
