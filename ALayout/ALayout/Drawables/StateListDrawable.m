//
//  StateListDrawable.m
//  ALayout
//
//  Created by splendourbell on 2017/5/11.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import <objc/message.h>
#import "StateListDrawable.h"

typedef NS_ENUM(int, ViewState)
{
    ViewStateSelected,
    ViewStateFocused,
    ViewStateEnable,
    ViewStatePressed
//    ViewStateActivated,
//    ViewStateWindowFocused,
//    ViewStateChecked,
//    ViewStateCheckable,
//    ViewStatehovered
};

@implementation StateItem

- (void)parseAttr:(AttributeReader*)attrReader
{
    _states = [[NSMutableDictionary alloc] init];
    if(attrReader[ValueKey(state_selected)])
    {
        _states[@(ViewStateSelected)] = @(ATTR_ReadAttr(A_state_selected, BOOL, YES));
    }
    else if(attrReader[ValueKey(state_focused)])
    {
        _states[@(ViewStateFocused)] = @(ATTR_ReadAttr(A_state_focused,  BOOL, YES));
    }
    else if(attrReader[ValueKey(state_enabled)])
    {
        _states[@(ViewStateEnable)] = @(ATTR_ReadAttr(A_state_enabled,   BOOL, YES));
    }
    else if(attrReader[ValueKey(state_pressed)])
    {
        _states[@(ViewStatePressed)] = @(ATTR_ReadAttr(A_state_pressed,  BOOL, YES));
    }
    else
    {
        //TODO:
        //android:state_hovered
        //android:state_checkable
        //android:state_checked
        //android:state_window_focused
        //android:state_activated
    }
    _drawable = ATTR_ReadAttr(A_drawable, Drawable, nil);
    if(!_drawable)
    {
        _drawable = ATTR_ReadAttr(A_color, Drawable, nil);
    }
}

- (BOOL)matchState:(BOOL (^)(ViewState viewState, BOOL value))matched
{
    if(!_states.count)
    {
        return YES;
    }
    
    if(!matched)
    {
        return NO;
    }
    
    for(NSNumber* stateNumber in _states)
    {
        if(!matched(stateNumber.intValue, [_states[stateNumber] boolValue]))
        {
            return NO;
        }
    }
    return YES;
}

@end

@implementation StateListDrawable
{
    NSMutableArray<StateItem*>* _itemList;
    
    __weak UIView* _observedView;
    
    void (^attachBlock)(Drawable* drawable);
    
    NSMutableArray<NSString*>* _oldObservedKeys;
}

+ (NSDictionary<NSNumber*, NSString*>*)stateValueKeys
{
    static NSDictionary<NSNumber*, NSString*>* stateMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stateMap = @{
                     @(ViewStateSelected) : @"selected",
                     @(ViewStateFocused)  : @"highlighted",
                     @(ViewStateEnable)   : @"enabled",
                     @(ViewStatePressed)  : @"highlighted"
                     };
    });
    return stateMap;
}

- (void)parseAttr:(AttributeReader*)attrReader
{
    [super parseAttr:attrReader];
    
    _itemList = [[NSMutableArray alloc] init];
    NSArray<NSDictionary*>* children = attrReader[@"children"];
    for(NSDictionary* attr in children)
    {
        AttributeReader* childAttrReader = [[AttributeReader alloc] initWithDictionary:attr resMgr:attrReader.resourceManager];
        StateItem* stateItem = [[StateItem alloc] init];
        [stateItem parseAttr:childAttrReader];
        [_itemList addObject:stateItem];
    }
}

- (void)attachBackground:(CALayer*)layer stateView:(UIView*)stateView
{
    __weak CALayer* weakLayer = layer;
    __weak UIView*  weakView  = stateView;
    attachBlock = ^(Drawable* drawable) {
        [drawable attachBackground:weakLayer stateView:weakView];
    };
    self.observedView = stateView;
}

- (void)attachUIColor:(id)hostView forKey:(NSString*)colorKey stateView:(UIView*)stateView
{
    __weak UIView*  weakStateView = stateView;
    __weak id weakHostView = hostView;
    attachBlock = ^(Drawable* drawable) {
        [drawable attachUIColor:weakHostView forKey:colorKey stateView:weakStateView];
    };
    self.observedView = stateView;
}

- (void)detach:(UIView*)stateView
{
    [self removeObservers:stateView];
    self.observedView = nil;
}

- (void)setObservedView:(UIView*)observedView
{
    if(_observedView != observedView)
    {
        [self removeObservers:_observedView];
        _observedView = observedView;
        [self addObservers];
        [self matchItem];
    }
}

- (UIView*)observedView
{
    return _observedView;
}



- (void)matchItem
{
    UIView* observedView = self.observedView;
    StateItem* matchItem = nil;
    
    BOOL (*Send_BOOL_Arg2)(id, SEL) = ((BOOL (*)(id, SEL)) objc_msgSend);
    
    for(StateItem* stateItem in _itemList)
    {
        BOOL matched = [stateItem matchState:^BOOL(ViewState viewState, BOOL value) {
            switch (viewState)
            {
                case ViewStateSelected:
                    return value == Send_BOOL_Arg2(observedView, @selector(isSelected));
                
                case ViewStateFocused:
                case ViewStatePressed:
                    return value == Send_BOOL_Arg2(observedView, @selector(isHighlighted));
                
                case ViewStateEnable:
                    return value == Send_BOOL_Arg2(observedView, @selector(isEnabled));

                default:
                    break;
            }
            return NO;
        }];
        
        if(matched)
        {
            matchItem = stateItem;
            break;
        }
    }
    if(attachBlock && matchItem.drawable)
    {
        attachBlock(matchItem.drawable);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if(keyPath && [_oldObservedKeys containsObject:keyPath])
    {
        int oldValue = [change[NSKeyValueChangeOldKey] intValue];
        int newValue = [change[NSKeyValueChangeNewKey] intValue];
        if(oldValue != newValue)
        {
            [self matchItem];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (NSMutableSet<NSString*>*)collectionValueKey
{
    NSDictionary<NSNumber*, NSString*>* stateValueKeys = StateListDrawable.stateValueKeys;
    
    NSMutableSet<NSString*>* stateKeys = [[NSMutableSet alloc] init];
    
    for(StateItem* stateItem in _itemList)
    {
        for(NSNumber* viewStateNumber in stateItem.states)
        {
            [stateKeys addObject: stateValueKeys[viewStateNumber]];
        }
    }
    return stateKeys;
}

- (void)addObservers
{
    UIView* observedView = self.observedView;
    if(observedView)
    {
        [self removeObservers:observedView];
        _oldObservedKeys = [[NSMutableArray alloc] init];
        NSMutableSet<NSString*>* collectionValueKey = self.collectionValueKey;
        for(NSString* k in collectionValueKey)
        {
            [observedView addObserver:self forKeyPath:k options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
            [_oldObservedKeys addObject:k];
        }
    }
}

- (void)removeObservers:(UIView*)observedView
{
    if(observedView && _oldObservedKeys)
    {
        for(NSString* key in _oldObservedKeys)
        {
            [observedView removeObserver:self forKeyPath:key context:nil];
        }
    }
    _oldObservedKeys = nil;
}

- (void)dealloc
{
    [self removeObservers:self.observedView];
}

@end
