//
//  UIView+Params.h
//  ALayout
//
//  Created by splendourbell on 2017/4/19.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttributeReader.h"

typedef NS_ENUM(int, VisibilityMode)
{
    Visibility_VISIBLE      = 0x00000000,
    Visibility_INVISIBLE    = 0x00000004,
    Visibility_GONE         = 0x00000008
};

typedef void (^ParseAttrBlock)(__kindof UIView* view, AttributeReader* attrReader, BOOL useDefault);

void RegisterViewParsePropertyByClass(Class cls, ParseAttrBlock parseAttrBlock);
NSArray<ParseAttrBlock>* GetViewParsePropertyByClass(Class cls);

//#define RegisterViewParseProperty(propnames) \
//+ (void)load\
//{\
//    RegisterViewParsePropertyByClass(self, propnames);\
//}

#define DEF_NEEDLAYOUT_SETTER(_Type_, _Fun_, _Pro_) \
    - (void)set##_Fun_:(_Type_)_Pro_ {\
        if(_Pro_ != _##_Pro_)\
        {\
            _##_Pro_ = _Pro_;\
            [self requestLayout];\
        }\
    }

typedef void (^VoidBlock_CGRect)(CGRect rect);

@interface ViewParams : NSObject

@property (nonatomic, readonly) CGSize measuredSize;

@property (nonatomic) CGSize minSize;

@property (nonatomic) CGSize maxSize;

@property (nonatomic) UIEdgeInsets padding;

@property (nonatomic) VisibilityMode visibility;

@property (nonatomic) BOOL enabled;

@property (nonatomic) BOOL clickable;

@property (nonatomic, strong) NSString* onClick;

@property (nonatomic, strong) NSMutableDictionary<NSString*, NSValue*>* measureCache;

@property (nonatomic, strong) Drawable* backgroud;

@property (nonatomic) BOOL requestLayout;

@property (nonatomic) CGSize (^availableLayoutSize)(CGSize size);

@property (nonatomic, readonly) NSMutableDictionary<NSString*, VoidBlock_CGRect>* willLayouts;

@property (nonatomic, readonly) NSMutableDictionary<NSString*, VoidBlock_CGRect>* didLayouts;

@property (nonatomic, copy) NSString* dataBinder;

@property (nonatomic, strong) NSDictionary <NSString *, NSDictionary *>* delayBindData;

@property (nonatomic, assign) BOOL animating;

@property (nonatomic) id extData;

@property (nonatomic) NSString* layout;

#ifdef DEBUG
@property (nonatomic, strong) NSString* filePath;
#endif

@end

@interface UIView(ViewParams)

@property (nonatomic) NSString* viewId;

- (ViewParams*)viewParams;

- (void)parseAttr:(AttributeReader*)attrReader;

- (void)parseAttr:(AttributeReader*)attrReader useDefault:(BOOL)useDefault;

- (NSMutableDictionary*)defaultStyle;

- (__kindof UIView*)findSuperviewByViewId:(NSString*)viewId;

- (__kindof UIView*)findByViewId:(NSString*)viewId;

- (__kindof UIView*)objectForKeyedSubscript:(NSString*)viewId;

- (void)addWillLayoutBlock:(NSString*)key block:(VoidBlock_CGRect)willLayout;

- (void)removeWillLayoutBlock:(NSString*)key;

- (void)addDidLayoutBlock:(NSString*)key block:(VoidBlock_CGRect)didLayout;

- (void)removeDidLayoutBlock:(NSString*)key;

- (void)onAddChildrenFinished;

- (NSString*)mainKey;

@end

