//
//  AttributeReader.h
//  ALayout
//
//  Created by splendourbell on 2017/4/19.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttributeKey.h"
#import "Gravity.h"

@class Drawable;

typedef NS_ENUM(int, LayoutParamsMode)
{
    LayoutParams_MATCH_PARENT = -1,
    LayoutParams_WRAP_CONTENT = -2
};

typedef NS_ENUM(int, OrientationMode)
{
    Orientation_HORIZONTAL,
    Orientation_VERTICAL
};

typedef NS_ENUM(int, ScaleType)
{
    ScaleType_MATRIX,
    ScaleType_FIT_XY,
    ScaleType_FIT_START,
    ScaleType_FIT_CENTER,
    ScaleType_FIT_END,
    ScaleType_CENTER,
    ScaleType_CENTER_CROP,
    ScaleType_CENTER_INSIDE
};

typedef CGFloat  Dimension;
typedef NSString TextString;
typedef struct UICornerRadius
{
    CGFloat topLeft, topRight, bottomRight, bottomLeft;
} UICornerRadius;
#define UICornerRadiusZero ((UICornerRadius){0})

typedef NS_ENUM(int, ResourceType)
{
    ResourceNormal,
    ResourceString,
    ResourceDrawable,
    ResourceColor,
    ResourceLayout,
    ResourceDimen
};

typedef NS_ENUM(int, ResourceValueType)
{
    ResourceValueUnkown,
    ResourceValueJson,
    ResourceValueImage,
    ResourceValueRaw
};

@interface ResourceInfo : NSObject

@property (nonatomic, copy) NSString* resourceName;

@property (nonatomic, copy) NSString* value;

@property (nonatomic, readonly) ResourceType resourceType;

@property (nonatomic, readonly) ResourceValueType valueType;

@end

@interface ResourceManager : NSObject

@property (nonatomic) NSMapTable* imageCache;

@property (nonatomic) CGFloat scale;

@property (nonatomic) CGFloat (^fontScale)(CGFloat);

@property (nonatomic) NSString* (^getCurrentLanguage)(void);

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

//must be called first
+ (void)Config:(void(^)(ResourceManager* manager))configBlock;

- (void)configFirstPath:(NSString*)firstPath secondPath:(NSString*)secondPath;

+ (ResourceManager*)defualtResourceManager;

+ (NSString*)getSourceString:(NSString*)name;

+ (NSDictionary*)getSourceAttribute:(NSString*)name;

- (ResourceInfo*)resourceInfo:(NSString*)resourceName;

- (void)addLanguageChangedNotify:(NSString*)notifyName;

@end

@interface AttributeReader : NSObject

@property (nonatomic, readonly) ResourceManager* resourceManager;

@property (nonatomic, weak) id target;

#ifdef DEBUG
@property (nonatomic, strong) NSString* filepath;
#endif

- (instancetype)initWithDictionary:(NSDictionary*)dictionary resMgr:(ResourceManager*)resMgr;

- (void)addDefaultAttribute:(NSDictionary*)defaultAttribute;

- (id)objectForKeyedSubscript:(NSString*)key;

- (NSEnumerator<NSString*>*)keyEnumerator;

- (int)read_int:(NSString*)key default:(CGFloat)defValue;

- (CGFloat)read_CGFloat:(NSString*)key default:(CGFloat)defValue;

- (Dimension)read_Dimension:(NSString*)key default:(Dimension)defValue;

- (BOOL)read_BOOL:(NSString*)key default:(BOOL)defValue;

- (NSNumber*)read_NSNumber:(NSString*)key default:(NSNumber*)defValue;

- (NSString*)read_NSString:(NSString*)key default:(NSString*)defValue;

- (TextString*)read_TextString:(NSString*)key default:(TextString*)defValue;

- (UIColor*)read_UIColor:(NSString*)key default:(UIColor*)defValue;

- (CGSize)read_CGSize:(NSString*)key default:(CGSize)defValue;

- (CGRect)read_CGRect:(NSString*)key default:(CGRect)defValue;

//- (UIEdgeInsets)read_UIEdgeInsets:(NSString*)key default:(UIEdgeInsets)defValue;

- (GravityMode)read_GravityMode:(NSString*)key default:(GravityMode)defValue;

- (OrientationMode)read_OrientationMode:(NSString*)key default:(OrientationMode)defValue;

- (Drawable*)read_Drawable:(NSString*)key default:(Drawable*)defValue;

- (ScaleType)read_ScaleType:(NSString*)key default:(ScaleType)defValue;

- (UIImage*)read_UIImage:(NSString*)key default:(UIImage*)defValue;

- (NSDate*)read_NSDate:(NSString*)key default:(NSDate*)defValue;

- (AttributeReader*)read_AttributeReader:(NSString*)key default:(AttributeReader*)defValue;

- (NSArray*)read_NSArray:(NSString*)key default:(NSArray*)defValue;

- (BOOL)hasKey:(NSString*)key;

- (NSDictionary *)fetchPrefixStr:(NSString *)prefix;

+ (id)toBackgroudAttr:(id)backgroud;

+ (id)toStrokeAttr:(id)width color:(id/*string|UIColor*/)color;

+ (NSString*)toColorAttr:(id/*string|UIColor*/)color;

+ (NSDictionary*)toSolidAttr:(id/*string|UIColor*/)color;

+ (id)toCornersAttr:(id)radius;

@end

#define MakePropName(KEY) _##KEY
#define MakePriProp(KEY) MakePropName(KEY)

#define ATTR_ReadAttr(KEY, TYPE, DEFAULT_VALUE)\
            [attrReader read_##TYPE:ValueKey(KEY) default:DEFAULT_VALUE]

#define ATTR_ReadAttrEq(LEFT_VALUE, KEY, TYPE, DEFAULT_VALUE) \
    if(useDefault || [attrReader hasKey:ValueKey(KEY)]) \
    { \
        LEFT_VALUE = [attrReader read_##TYPE:ValueKey(KEY) default:DEFAULT_VALUE]; \
    }

#define ATTR_CanRead(KEY) \
    useDefault || [attrReader hasKey:ValueKey(KEY)]

#define StrEq(_a_, _b_) \
    [(_b_) isEqualToString:(_a_)]

#define isNSString(__value__)       [(__value__) isKindOfClass:NSString.class]
#define isNSNumber(__value__)       [(__value__) isKindOfClass:NSNumber.class]
#define isNSDictionary(__value__)   [(__value__) isKindOfClass:NSDictionary.class]
#define isNSArray(__value__)        [(__value__) isKindOfClass:NSArray.class]
#define isUIColor(__value__)        [(__value__) isKindOfClass:UIColor.class]

#define A_Background(_background_)  ValueKey(A_background)  :   [AttributeReader toBackgroudAttr:(_background_)]
#define A_Children(array)           ValueKey(A_children)    :   (array?:@[])
#define A_Corners(radius)           ValueKey(A_corners)     :   [AttributeReader toCornersAttr:radius]
#define A_Gone(bool)                ValueKey(A_visibility)  :   ((bool)?@"visible":@"gone")
#define A_Solid(color)              ValueKey(A_solid)       :   [AttributeReader toSolidAttr:color]
#define A_Selected(_selected)       ValueKey(A_selected)    :   ((_selected)?@"true":@"false")
#define A_Stroke(width, _color_)    ValueKey(A_stroke)      :   [AttributeReader toStrokeAttr:width color:_color_]
#define A_Tag(_tag_)                ValueKey(A_tag)         :   ((_tag_).stringValue)
#define A_Text(text)                ValueKey(A_text)        :   ((text)?:@"")
#define A_TextColor(color)          ValueKey(A_textColor)   :   [AttributeReader toColorAttr:color]
#define A_Url(url)                  ValueKey(A_url)         :   ((url)?:@"")
#define A_Visible(bool)             ValueKey(A_visibility)  :   ((bool)?@"visible":@"invisible")

#define A_Layout(layout, valueData) @{ValueKey(A_layout):((layout)?:@""), @"data":valueData}
#define A_LayoutTarget(layout, valueData, _target_) @{ValueKey(A_layout):((layout)?:@""), @"data":valueData, @"target":_target_}


