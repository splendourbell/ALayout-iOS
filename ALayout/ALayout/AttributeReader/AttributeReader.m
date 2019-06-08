//
//  AttributeReader.m
//  ALayout
//
//  Created by splendourbell on 2017/4/19.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "AttributeReader.h"
#import "AttributeReader+UIColor.h"
#import "AttributeReader+Gravity.h"
#import "DrawableFactory.h"
#import "ColorDrawable.h"
#import "BitmapDrawable.h"
#import "ScriptDataBinder.h"

#define isStringRef(__value__)   [(__value__) hasPrefix:@"@string/"]
#define isDrawableRef(__value__) [(__value__) hasPrefix:@"@drawable/"]
#define isColorRef(__value__)    [(__value__) hasPrefix:@"@color/"]
#define isDimenRef(__value__)    [(__value__) hasPrefix:@"@dimen/"]
#define isLayoutRef(__value__)   [(__value__) hasPrefix:@"@layout/"]

#define isReferenceSource(__value__) [(__value__) hasPrefix:@"@"]
#define isFullPath(__value__)   [(__value__) hasPrefix:@"/"]
#define GetRelativePath(__value__) [(__value__) substringFromIndex:1]

@interface ResourceInfo()
@property (nonatomic, readwrite) ResourceType resourceType;
@property (nonatomic, readwrite) ResourceValueType valueType;
@end
@implementation ResourceInfo : NSObject
@end

@interface ResourceManager()

@property (nonatomic) NSMutableDictionary<NSString*, NSString*>* colorsTable;

@property (nonatomic) NSMutableDictionary<NSString*, NSString*>* stringsTable;

@property (nonatomic) NSMutableDictionary<NSString*, NSString*>* dimensTable;

@property (nonatomic, copy) NSString* secondPath;

@property (nonatomic, copy) NSString* firstPath;

- (instancetype)initInternal;

@end

static inline UIImage* __getGifImage(NSString* imagePath)
{
    static SEL sd_imageWithData = nil;
    if(!sd_imageWithData)
    {
        sd_imageWithData = NSSelectorFromString(@"sd_imageWithData:");
    }
    if([UIImage respondsToSelector:sd_imageWithData])
    {
        NSData* gifData = [NSData dataWithContentsOfFile:imagePath];
        if(gifData)
        {
            return [UIImage performSelector:sd_imageWithData withObject:gifData];
        }
    }
    return nil;
}

static void (^gManagerConfigBlock)(ResourceManager* manager);

@implementation ResourceManager
{
    NSString* _currentLanguage;
}

+ (void)Config:(void(^)(ResourceManager* manager))configBlock
{
    gManagerConfigBlock = configBlock;
}

+ (ResourceManager*)defualtResourceManager
{
    static ResourceManager* _defualtResourceManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defualtResourceManager = [[ResourceManager alloc] initInternal];
        if(gManagerConfigBlock)
        {
            gManagerConfigBlock(_defualtResourceManager);
        }
    });
    return _defualtResourceManager;
}

+ (NSString*)getSourceString:(NSString*)name
{
    ResourceManager* resourceManager = [ResourceManager defualtResourceManager];
    ResourceInfo* info = [resourceManager resourceInfo:name];
    NSString* string = [NSString stringWithContentsOfFile:info.value encoding:NSUTF8StringEncoding error:nil];
    return string;
}

+ (NSDictionary*)getSourceAttribute:(NSString*)name
{
    ResourceManager* resourceManager = [ResourceManager defualtResourceManager];
    ResourceInfo* info = [resourceManager resourceInfo:name];
    NSData* data = [NSData dataWithContentsOfFile:info.value];
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return dict;
}

- (instancetype)initInternal
{
    if(self = [super init])
    {
        self.scale = [UIScreen mainScreen].scale;
        self.imageCache = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

- (void)configFirstPath:(NSString*)firstPath secondPath:(NSString*)secondPath
{
    if(firstPath.length){
        _firstPath = firstPath.copy;
    } else {
        _firstPath = nil;
    }
    
    _secondPath = secondPath.copy;
    NSString* firstScriptPath = [firstPath stringByAppendingPathComponent:@"script"];
    NSString* secondScriptPath = [firstPath stringByAppendingPathComponent:@"script"];
    [[ScriptDataBinder defaultDataBinder] addScriptSearchPath:firstScriptPath];
    [[ScriptDataBinder defaultDataBinder] addScriptSearchPath:secondScriptPath];
}

- (void)getDrawableInfo:(ResourceInfo*)info
{
    NSString* resourceName = info.resourceName;
    
    info.resourceType = ResourceDrawable;
    resourceName = GetRelativePath(resourceName);
    
    NSString* fullPath = resourceName;
    fullPath = [self findPath:fullPath];
    
    NSString* ext = fullPath.pathExtension;
    if(StrEq(@"json", ext))
    {
        info.valueType = ResourceValueJson;
    }
    else if(StrEq(@"png", ext) || StrEq(@"jpg", ext) || StrEq(@"gif", ext))
    {
        info.valueType = ResourceValueImage;
    }
    
    info.value = fullPath;
}

- (ResourceInfo*)resourceInfo:(NSString*)resourceName
{
    ResourceInfo* info = [[ResourceInfo alloc] init];
    info.resourceName = resourceName;
    
    if(isReferenceSource(resourceName))
    {
        if(isDrawableRef(resourceName))
        {
            [self getDrawableInfo:info];
        }
        else if(isColorRef(resourceName))
        {
            info.resourceType = ResourceColor;
            info.valueType = ResourceValueRaw;
            info.value = resourceName.lastPathComponent;
            if(![self colorForName:info.value])
            {
                [self getDrawableInfo:info];
            }
        }
        else if(isStringRef(resourceName))
        {
            info.resourceType = ResourceString;
            info.valueType = ResourceValueRaw;
            info.value = resourceName.lastPathComponent;
        }
        else if(isDimenRef(resourceName))
        {
            info.resourceType = ResourceDimen;
            info.valueType = ResourceValueRaw;
            info.value = resourceName.lastPathComponent;
        }
        else if(isLayoutRef(resourceName))
        {
            info.resourceType = ResourceLayout;
            resourceName = GetRelativePath(resourceName);
            
            NSString* fullPath = resourceName;
            fullPath = [self findPath:fullPath];
            
            NSString* ext = fullPath.pathExtension;
            if(StrEq(@"json", ext))
            {
                info.valueType = ResourceValueJson;
            }
            info.value = fullPath;
        }
    }
    else
    {
        info.resourceType = ResourceNormal;
        info.valueType = ResourceValueRaw;
        info.value = resourceName;
    }

    return info;
}


- (NSString*)getFirstPath:(NSString*)fullPath
{
    NSString* resultPath = nil;
    if(fullPath && !isFullPath(fullPath))
    {
        if(_firstPath)
        {
            resultPath = [_firstPath stringByAppendingPathComponent:fullPath];
        }
    }
    else
    {
        resultPath = fullPath; 
    }
    return resultPath;
}

- (NSString*)getSecondPath:(NSString*)fullPath
{
    NSString* resultPath = nil;
    if(fullPath && !isFullPath(fullPath))
    {
        if(_secondPath)
        {
            resultPath = [_secondPath stringByAppendingPathComponent:fullPath];
        }
    }
    else
    {
        resultPath = fullPath; 
    }
    return resultPath;
}

- (NSString*)findPath:(NSString*)fullPath
{
    NSString* resultPath = [self getFirstPath:fullPath];
    resultPath = [self scaledPath:resultPath];
    if(!resultPath.length)
    {
        resultPath = [self getSecondPath:fullPath];
        resultPath = [self scaledPath:resultPath];
    }
    return resultPath ?: fullPath;
}

- (NSString*)scaledPath:(NSString*)fullPath
{
    NSString* retPath = nil;
    NSString* pathExtension = fullPath.pathExtension;

    NSString* fileName = fullPath.stringByDeletingPathExtension;
    NSArray* validExts = @[@"json",@"png",@"jpg",@"gif"];
    if(pathExtension.length)
    {
        validExts = @[pathExtension];
    }
    for(NSString* ext in validExts)
    {
        retPath = [self scaledPath:fileName ext:ext];
        if(retPath)
        {
            break;
        }
    }
    
    return retPath;
}

- (NSString*)scaledPath:(NSString*)fileName ext:(NSString*)ext
{
    NSString* retPath = nil;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    int curScale = self.scale + 0.5;
    assert(curScale <= 3);
    assert(curScale >= 2);
    
    if(StrEq(@"json", ext))
    {
        NSArray* array = (curScale >= 3) ? @[@"", @"@2x", @"@3x"] : @[@"", @"@2x"];
        for(NSString* scaleExt in array)
        {
            NSString* __nonnull guessPath = (NSString* __nonnull)[fileName stringByAppendingFormat:@"%@.%@", scaleExt, ext];
            if([fileManager fileExistsAtPath:guessPath])
            {
                retPath = guessPath;
                break;
            }
        }
    }
    else if(StrEq(@"png", ext) || StrEq(@"jpg", ext) || StrEq(@"gif", ext))
    {
        NSArray* array = (curScale >= 3) ? @[@"@3x", @"@2x", @""] : @[@"@2x", @""];
        for(NSString* scaleExt in array)
        {
            NSString* __nonnull guessPath = (NSString* __nonnull)[fileName stringByAppendingFormat:@"%@.%@", scaleExt, ext];
            if([fileManager fileExistsAtPath:guessPath])
            {
                retPath = guessPath;
                break;
            }
        }
    }
    return retPath;
}

- (NSString*)colorForName:(NSString*)name
{
//    #if !TARGET_OS_SIMULATOR
        if(!_colorsTable)
//    #endif
        {
            [self parseAllValues];
        }
    return _colorsTable[name];
}

- (NSString*)stringForName:(NSString*)name
{
    //#if !TARGET_OS_SIMULATOR
        if(!_stringsTable)
//    #endif
        {
            [self parseAllValues];
        }
    return _stringsTable[name];
}

- (NSString*)dimenForName:(NSString*)name
{
//    #if !TARGET_OS_SIMULATOR
        if(!_dimensTable)
//    #endif
        {
            [self parseAllValues];
        }
    return _dimensTable[name];
}

- (void)setGetCurrentLanguage:(NSString *(^)(void))getCurrentLanguage
{
    _getCurrentLanguage = getCurrentLanguage;
    [self currentLanguageChanged];
}

- (void)addLanguageChangedNotify:(NSString*)notifyName
{
    if(notifyName)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentLanguageChanged) name:notifyName object:nil];
}

- (BOOL)currentLanguageChanged
{
    if(!self.getCurrentLanguage)
    {
        self.getCurrentLanguage = self.class.defualtResourceManager.getCurrentLanguage;
    }
    if(self.getCurrentLanguage)
    {
        NSString* newLanguage = self.getCurrentLanguage();
        return [self setCurrentLanguage:newLanguage];
    }
    return NO;
}
- (BOOL)setCurrentLanguage:(NSString *)currentLanguage
{
    _currentLanguage = _currentLanguage ?: @"";
    currentLanguage  =  currentLanguage ?: @"";
    
    if(![_currentLanguage isEqualToString:currentLanguage])
    {
        _currentLanguage = currentLanguage.copy;
        _dimensTable = nil;
        _stringsTable = nil;
        _colorsTable = nil;
        return YES;
    }
    return NO;
}

- (void)parseAllValues
{
    _colorsTable  = [[NSMutableDictionary alloc] init];
    _stringsTable = [[NSMutableDictionary alloc] init];
    _dimensTable  = [[NSMutableDictionary alloc] init];
    [self parseAllValuesForPath:_secondPath];
    [self parseAllValuesForPath:_firstPath];
}

- (void)parseAllValuesForPath:(NSString*)rootPath
{
    if(!rootPath.length)
    {
        return;
    }
    
    NSString* valuePath = [rootPath stringByAppendingPathComponent:@"values"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString* filename = nil;
    NSDirectoryEnumerator* directoryEnumerator = [fileManager enumeratorAtPath:valuePath];
    while(filename = [directoryEnumerator nextObject])
    {
        if([filename.pathExtension isEqualToString:@"json"])
        {
            filename = [valuePath stringByAppendingPathComponent:filename];
            NSData* data = [NSData dataWithContentsOfFile:filename];
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSDictionary* colorsDict = dict[@"colors"];
            if(colorsDict.count)
            {
                [_colorsTable addEntriesFromDictionary:colorsDict];
            }
            
            NSDictionary* stringsDict = dict[@"strings"];
            if(stringsDict.count)
            {
                [_stringsTable addEntriesFromDictionary:stringsDict];
            }
            
            NSDictionary* dimensDict = dict[@"dimens"];
            if(dimensDict.count)
            {
                [_dimensTable addEntriesFromDictionary:dimensDict];
            }
        }
    }
    [self parseValuesCurrentLanguage:rootPath];
}

- (void)parseValuesCurrentLanguage:(NSString*)rootPath
{
    NSString* currentLanguage = _currentLanguage;
    if(!currentLanguage.length)
    {
        return;
    }
    NSString* valuePath = [rootPath stringByAppendingFormat:@"/values-%@", currentLanguage];
    [self parseValuesForPath:valuePath];
}

- (void)parseValuesForPath:(NSString*)valuePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    if(![fileManager fileExistsAtPath:valuePath isDirectory:&isDirectory] || !isDirectory)
    {
        return;
    }
    
    NSDirectoryEnumerator* directoryEnumerator = [fileManager enumeratorAtPath:valuePath];
    _colorsTable  = _colorsTable    ?:  [[NSMutableDictionary alloc] init];
    _stringsTable = _stringsTable   ?:  [[NSMutableDictionary alloc] init];
    _dimensTable  = _dimensTable    ?:  [[NSMutableDictionary alloc] init];
    
    NSString* filename = nil;
    while(filename = [directoryEnumerator nextObject])
    {
        if([filename.pathExtension isEqualToString:@"json"])
        {
            filename = [valuePath stringByAppendingPathComponent:filename];
            NSData* data = [NSData dataWithContentsOfFile:filename];
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSDictionary* colorsDict = dict[@"colors"];
            if(colorsDict.count)
            {
                [_colorsTable addEntriesFromDictionary:colorsDict];
            }
            
            NSDictionary* stringsDict = dict[@"strings"];
            if(stringsDict.count)
            {
                [_stringsTable addEntriesFromDictionary:stringsDict];
            }
            
            NSDictionary* dimensDict = dict[@"dimens"];
            if(dimensDict.count)
            {
                [_dimensTable addEntriesFromDictionary:dimensDict];
            }
        }
    }
}

@end

@implementation AttributeReader
{
    NSDictionary* _attribute;
    NSMutableDictionary<NSString*, id>* _cacheObject;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary resMgr:(ResourceManager*)resMgr
{
    if(self = [self init])
    {
        _attribute = dictionary;
        _resourceManager = resMgr;
        _cacheObject = [NSMutableDictionary new];
        assert(resMgr);
    }
    return self;
}

- (void)addDefaultAttribute:(NSDictionary*)defaultAttribute
{
    if(defaultAttribute.count)
    {
        NSMutableDictionary* mutableAttri = (NSMutableDictionary*)_attribute;
        if(![mutableAttri isKindOfClass:NSMutableDictionary.class] || [mutableAttri isKindOfClass:NSClassFromString(@"__NSCFDictionary")])
        {
            mutableAttri = [mutableAttri mutableCopy];
        }
        [defaultAttribute enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if(!mutableAttri[key]) mutableAttri[key] = obj;
        }];
        _attribute = mutableAttri;
    }
}

- (id)objectForKeyedSubscript:(NSString*)key
{
    return _attribute[key];
}

- (NSEnumerator<NSString*>*)keyEnumerator
{
    return [_attribute keyEnumerator];
}

- (int)read_int:(NSString*)key default:(CGFloat)defValue;
{
    NSNumber* value = _attribute[key];
    return (value ? [value intValue] : defValue);
}

- (CGFloat)read_CGFloat:(NSString*)key default:(CGFloat)defValue;
{
    id value = _attribute[key];
    if(isNSNumber(value))
    {
        return [value doubleValue];
    }
    else if(isNSString(value))
    {
        return [(NSString*)value doubleValue];
    }
    return defValue;
}

- (Dimension)read_Dimension:(NSString*)key default:(Dimension)defValue
{
    id value = _attribute[key];
    if(isNSNumber(value))
    {
        return [self read_CGFloat:key default:defValue];
    }
    else if(isNSString(value))
    {
        NSString* strValue = (NSString*)value;
        if(StrEq(ValueKey(A_match_parent), strValue))
        {
            return LayoutParams_MATCH_PARENT;
        }
        else if(StrEq(ValueKey(A_wrap_content), strValue))
        {
            return LayoutParams_WRAP_CONTENT;
        }
        else if(isDimenRef(strValue))
        {
            ResourceInfo* info = [self.resourceManager resourceInfo:strValue];
            id value = [self.resourceManager dimenForName:info.value];
            return [self parse_Dimension:value default:defValue];
        }
        else if([strValue hasSuffix:@"dp"] || [strValue hasSuffix:@"px"])
        {
            return [self parse_Dimension:strValue default:defValue];
        }
        else
        {
            return [strValue doubleValue];
        }
    }
    return defValue;
}

- (Dimension)parse_Dimension:(id)value default:(Dimension)defValue
{
    if(isNSString(value))
    {
        NSString* strValue = (NSString*)value;
        if([strValue hasSuffix:@"dp"])
        {
            strValue = [strValue substringToIndex:strValue.length-2];
            return [strValue doubleValue];
        }
        else if([strValue hasSuffix:@"px"])
        {
            strValue = [strValue substringToIndex:strValue.length-2];
            return [strValue doubleValue] * 750 / 1080;//TODO: OR  * 2 / 3 ?
        }
        else
        {
            return [strValue doubleValue];
        }
    }
    return defValue;
}

- (BOOL)read_BOOL:(NSString*)key default:(BOOL)defValue;
{
    id value = _attribute[key];
    if(isNSNumber(value))
    {
        return [value boolValue];
    }
    else if(isNSString(value))
    {
        return StrEq(value, @"true");
    }
    return defValue;
}

- (NSNumber*)read_NSNumber:(NSString*)key default:(NSNumber*)defValue
{
    NSNumber* value = _attribute[key];
    if(isNSNumber(value))
    {
        return value;
    }
    else if(isNSString(value))
    {
        return @([(NSString*)value doubleValue]);
    }
    return defValue;
}

- (NSString*)read_NSString:(NSString*)key default:(NSString*)defValue;
{
    NSString* value = _attribute[key];
    return (value ? value : defValue);
}

- (TextString*)read_TextString:(NSString*)key default:(TextString*)defValue
{
    id value = _attribute[key];
    ResourceInfo* info = [self.resourceManager resourceInfo:value];
    if(ResourceString == info.resourceType)
    {
        NSString* textString = [self.resourceManager stringForName:info.value];
        return textString ?: defValue;
    }
    else
    {
        return [self read_NSString:key default:defValue];
    }
}

- (UIColor*)read_UIColor:(NSString*)key default:(UIColor*)defValue;
{
    id value = _attribute[key];
    UIColor* retColor = defValue;
    if(isNSString(value))
    {
        NSString* strValue = (NSString*)value;
        ResourceInfo* info = [_resourceManager resourceInfo:strValue];

        if(ResourceColor == info.resourceType)
        {
            if(ResourceValueRaw == info.valueType)
            {
                id colorValue = [self.resourceManager colorForName:info.value];
                return [self parse_UIColor:colorValue default:defValue];
            }
        }
        else
        {
            retColor = [self parse_UIColor:value default:defValue];
        }
    }
    return retColor ?: defValue;
}

- (CGSize)read_CGSize:(NSString*)key default:(CGSize)defValue
{
    NSDictionary* value = _attribute[key];
    if(!value) return defValue;
    
    CGFloat width =  [value[@"width"]  doubleValue];
    CGFloat height = [value[@"height"] doubleValue];
    
    return CGSizeMake(width, height);
}

- (CGRect)read_CGRect:(NSString*)key default:(CGRect)defValue;
{
    id value = _attribute[key];
    if( [value isKindOfClass:NSDictionary.class])
    {
        CGFloat x = [value[@"x"] doubleValue];
        CGFloat y = [value[@"y"] doubleValue];
        CGFloat w = [value[@"w"] doubleValue];
        CGFloat h = [value[@"h"] doubleValue];
        return CGRectMake(x, y, w, h);
    }
    else if([value isKindOfClass:NSArray.class])
    {
        CGFloat rect_xywh[4] = {0};
        int i = 0;
        for(NSNumber* number in (NSArray*)value)
        {
            if(i >= 4) break;

            rect_xywh[i++] = [number doubleValue];
        }
        return CGRectMake(rect_xywh[0], rect_xywh[1], rect_xywh[2], rect_xywh[3]);
    }
    return defValue;
}

//- (UIEdgeInsets)read_UIEdgeInsets:(NSString*)key default:(UIEdgeInsets)defValue
//{
//    id value = _attribute[key];
//    if(isNSDictionary(value))
//    {
//        CGFloat top    = [value[@"top"]    doubleValue];
//        CGFloat left   = [value[@"left"]   doubleValue];
//        CGFloat bottom = [value[@"bottom"] doubleValue];
//        CGFloat right  = [value[@"right"]  doubleValue];
//        
//        return UIEdgeInsetsMake(top, left, bottom, right);
//    }
//    else if(isNSArray(value))
//    {
//        CGFloat edge_tlbr[4] = {0};
//        int i = 0;
//        for(NSNumber* number in (NSArray*)value)
//        {
//            if(i >= 4) break;
//            
//            edge_tlbr[i++] = [number doubleValue];
//        }
//        return UIEdgeInsetsMake(edge_tlbr[0], edge_tlbr[1], edge_tlbr[2], edge_tlbr[3]);
//    }
//    else if(isNSNumber(value) || isNSString(value))
//    {
//        CGFloat padding = [value doubleValue];
//        return UIEdgeInsetsMake(padding, padding, padding, padding);
//    }
//    return defValue;
//}

//- (UICornerRadius)read_UICornerRadius:(NSString*)key default:(UICornerRadius)defValue
//{
//    id value = _attribute[key];
//    if(isNSDictionary(value))
//    {
//        CGFloat top    = [value[@"top"]    doubleValue];
//        CGFloat left   = [value[@"left"]   doubleValue];
//        CGFloat bottom = [value[@"bottom"] doubleValue];
//        CGFloat right  = [value[@"right"]  doubleValue];
//        
//        return UIEdgeInsetsMake(top, left, bottom, right);
//    }
//    else if(isNSArray(value))
//    {
//        CGFloat edge_tlbr[4] = {0};
//        int i = 0;
//        for(NSNumber* number in (NSArray*)value)
//        {
//            if(i >= 4) break;
//            
//            edge_tlbr[i++] = [number doubleValue];
//        }
//        return UIEdgeInsetsMake(edge_tlbr[0], edge_tlbr[1], edge_tlbr[2], edge_tlbr[3]);
//    }
//    else if(isNSNumber(value) || isNSString(value))
//    {
//        CGFloat padding = [value doubleValue];
//        return UIEdgeInsetsMake(padding, padding, padding, padding);
//    }
//    return defValue;
//}

- (GravityMode)read_GravityMode:(NSString*)key default:(GravityMode)defValue
{
    return [self read_GravityMode_imp:key default:defValue];
}

- (OrientationMode)read_OrientationMode:(NSString*)key default:(OrientationMode)defValue
{
    id value = _attribute[key];
    if( isNSString(value) )
    {
        NSString* strValue = (NSString*)value;
        if(StrEq(strValue, @"vertical"))
        {
            return Orientation_VERTICAL;
        }
    }
    return Orientation_HORIZONTAL;
}

- (BOOL)isImageFile:(NSString*)fileExt
{
    return [@[@"jpg",@"png",@"gif"] containsObject:fileExt];
}

- (Drawable*)read_Drawable:(NSString*)key default:(Drawable*)defValue
{
    Drawable* drawable = defValue;
    id value = _attribute[key];
    if(isNSString(value))
    {
        NSString* strValue = (NSString*)value;
        ResourceInfo* info = [_resourceManager resourceInfo:strValue];

        if(ResourceDrawable == info.resourceType)
        {
            if(ResourceValueJson == info.valueType)
            {
                NSString* jsonPath = info.value;
                NSData* jsonData = [NSData dataWithContentsOfFile:jsonPath];
                NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
                AttributeReader* attrReader = [[AttributeReader alloc] initWithDictionary:dict resMgr:self.resourceManager];
                drawable = [DrawableFactory createDrawable:attrReader];
            }
            else if(ResourceValueImage == info.valueType)
            {
                NSString* imagePath = info.value;
                BitmapDrawable* bitmapDrawable = [[BitmapDrawable alloc] init];
                
                UIImage* image = [_resourceManager.imageCache objectForKey:imagePath];
                if(!image)
                {
                    if([imagePath hasSuffix:@"gif"])
                    {
                        image = __getGifImage(imagePath);
                    }
                    if(!image)
                    {
                        image = [UIImage imageWithContentsOfFile:imagePath];
                    }
                    if(image)
                    {
                        [_resourceManager.imageCache setObject:image forKey:imagePath];
                    }
                }
                bitmapDrawable.image = image;
                drawable = bitmapDrawable;
            }
        }
        else if(ResourceColor == info.resourceType)
        {
            NSString* colorName = info.value;
            id colorValue = [self.resourceManager colorForName:colorName];
            UIColor* color = [self parse_UIColor:colorValue default:nil];
            if(color)
            {
                ColorDrawable* colorDrawable = [[ColorDrawable alloc] init];
                colorDrawable.color = color;
                drawable = colorDrawable;
            }
        }
        else
        {
            UIColor* color = [self read_UIColor:key default:nil];
            if(color)
            {
                ColorDrawable* colorDrawable = [[ColorDrawable alloc] init];
                colorDrawable.color = color;
                drawable = colorDrawable;
            }
        }
    } 
    else if(isNSDictionary(value))
    {
        NSDictionary* dict = (NSDictionary*)value;
        AttributeReader* attrReader = [[AttributeReader alloc] initWithDictionary:dict resMgr:self.resourceManager];
        drawable = [DrawableFactory createDrawable:attrReader];
    }
    return drawable ?: defValue;
}

- (ScaleType)read_ScaleType:(NSString*)key default:(ScaleType)defValue
{
    ScaleType scaleType = defValue;
    id value = _attribute[key];
    if(isNSString(value))
    {
        if(StrEq(@"matrix", value))
        {
            scaleType = ScaleType_MATRIX;
        }
        else if(StrEq(@"fitXY", value))
        {
            scaleType = ScaleType_FIT_XY;
        }
        else if(StrEq(@"fitStart", value))
        {
            scaleType = ScaleType_FIT_START;
        }
        else if(StrEq(@"fitCenter", value))
        {
            scaleType = ScaleType_FIT_CENTER;
        }
        else if(StrEq(@"fitEnd", value))
        {
            scaleType = ScaleType_FIT_END;
        }
        else if(StrEq(@"center", value))
        {
            scaleType = ScaleType_CENTER;
        }
        else if(StrEq(@"centerCrop", value))
        {
            scaleType = ScaleType_CENTER_CROP;
        }
        else if(StrEq(@"centerInside", value))
        {
            scaleType = ScaleType_CENTER_INSIDE;
        }
    }
    return scaleType;
}

- (UIImage*)read_UIImage:(NSString*)key default:(UIImage*)defValue
{
    id value = _attribute[key];
    if(isNSString(value))
    {
        NSString* strValue = (NSString*)value;
        ResourceInfo* info = [self.resourceManager resourceInfo:strValue];
        if(ResourceDrawable == info.resourceType)
        {
            if(ResourceValueImage == info.valueType)
            {
                NSString* imagePath = info.value;
                UIImage* image = [_resourceManager.imageCache objectForKey:imagePath];
                if(!image)
                {
                    if([imagePath hasSuffix:@"gif"])
                    {
                        image = __getGifImage(imagePath);
                    }
                    if(!image)
                    {
                        image = [UIImage imageWithContentsOfFile:imagePath];
                    }
                    if(image)
                    {
                        [_resourceManager.imageCache setObject:image forKey:imagePath];
                    }
                }
                return image;
            }
        }
    }
    return defValue;
}

- (NSDate*)read_NSDate:(NSString*)key default:(NSDate*)defValue
{
    id value = _attribute[key];
    NSDate* retDate = nil;
    if(isNSString(value))
    {
        NSString* strValue = (NSString*)value;
        if([strValue isEqualToString:@"now"])
        {
            retDate = NSDate.date;
        }
        else
        {
            NSDateFormatter* dateFormat = _cacheObject[@"NSDateFormatter:yyyy-MM-dd"];
            if(!dateFormat)
            {
                dateFormat = [[NSDateFormatter alloc] init] ;
                [dateFormat setDateFormat:@"yyyy-MM-dd"];
                _cacheObject[@"NSDateFormatter:yyyy-MM-dd"] = dateFormat;
            }
            
            retDate = [dateFormat dateFromString:strValue];
        }
    }
    return retDate ?: defValue;
}

- (AttributeReader*)read_AttributeReader:(NSString*)key default:(AttributeReader*)defValue
{
    id value = _attribute[key];
    if([value isKindOfClass:NSDictionary.class])
    {
        NSDictionary* dict = (NSDictionary*)value;
        AttributeReader* attrReader = [[AttributeReader alloc] initWithDictionary:dict resMgr:self.resourceManager];
        return attrReader;
    }
    return defValue;
}

- (NSArray*)read_NSArray:(NSString*)key default:(NSArray*)defValue
{
    id value = _attribute[key];
    if([value isKindOfClass:NSArray.class])
    {
        return value;
    }
    return defValue;
}


- (NSArray<AttributeReader *> *)mergeChildren:(NSString *)name
{
    ResourceInfo* info = [_resourceManager resourceInfo:name];
    NSData* jsonData = [NSData dataWithContentsOfFile:info.value];
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    
    NSMutableArray *childrenArr = [NSMutableArray array];
    NSArray *children = dict[ValueKey(A_children)];
    for (NSDictionary *child in children)
    {
        AttributeReader* childAttribute = [[AttributeReader alloc] initWithDictionary:child resMgr:self.resourceManager];
        [childrenArr addObject:childAttribute];
    }
    
    return childrenArr;
}

- (void)includeLayout:(NSString*)name
{
    ResourceInfo* info = [_resourceManager resourceInfo:name];
    NSData* jsonData = [NSData dataWithContentsOfFile:info.value];
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    if(dict.count)
    {
        NSMutableDictionary* mutableDictionary = nil;
        if([_attribute isKindOfClass:NSMutableDictionary.class] && ![_attribute isKindOfClass:NSClassFromString(@"__NSCFDictionary")])
        {
            mutableDictionary = (NSMutableDictionary*)_attribute;
        }
        else
        {
            mutableDictionary = [_attribute mutableCopy];
            _attribute = mutableDictionary;
        }
        
        id idObj         = mutableDictionary[ValueKey(A_id)];
        
        id layout_width  = mutableDictionary[ValueKey(A_layout_width)];
        id layout_height = mutableDictionary[ValueKey(A_layout_height)];
        
        BOOL sameAsAndroid = false;
#ifdef ANDROID
        sameAsAndroid = true;
#endif
        if(sameAsAndroid)
        {
            //include时，Android要求此属性必须同时存在才起效
            if (layout_width && layout_height)
            {
                for (NSString *keyStr in dict)
                {
                    if ([keyStr hasPrefix:@"layout_"])
                    {
                        if (!mutableDictionary[keyStr])
                        {
                            mutableDictionary[keyStr] = dict[keyStr];
                        }
                    }
                    else
                    {
                        mutableDictionary[keyStr] = dict[keyStr];
                    }
                }
            }
            else
            {
                [mutableDictionary addEntriesFromDictionary:dict];
            }
        }
        else
        {
            for (NSString *keyStr in dict)
            {
                if (!mutableDictionary[keyStr])
                {
                    mutableDictionary[keyStr] = dict[keyStr];
                }
            }
            mutableDictionary[@"class"] = dict[@"class"];
        }
        
        if (idObj)
        {
            mutableDictionary[ValueKey(A_id)] = idObj;
        }
    }
}

- (BOOL)hasKey:(NSString*)key
{
    return !!_attribute[key];
}

- (NSDictionary *)fetchPrefixStr:(NSString *)prefix
{
    if (prefix.length == 0)
    {
        return nil;
    }
    
    NSMutableDictionary *parmasDict = [NSMutableDictionary dictionary];
    NSDictionary* attribute = _attribute;
    [_attribute.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj hasPrefix:prefix])
        {
            parmasDict[[obj substringFromIndex:prefix.length]] = attribute[obj];
        }
    }];
    
    return parmasDict;
}

+ (id)toBackgroudAttr:(id)backgroud
{
    if(isNSDictionary(backgroud))
    {
        NSDictionary* bgDict = backgroud;
        NSMutableArray* children = NSMutableArray.new;
        
        NSDictionary* stroke = bgDict[ValueKey(A_stroke)];
        if(isNSDictionary(stroke))
        {
            [children addObject:stroke];
        }
        
        NSDictionary* corners = bgDict[ValueKey(A_corners)];
        if(isNSDictionary(corners))
        {
            [children addObject:corners];
        }
        
        NSDictionary* solid = bgDict[ValueKey(A_solid)];
        if(isNSDictionary(solid))
        {
            [children addObject:solid];
        }
        
        return @{
          @"class" : @"shape",
          @"shape" : @"rectangle",
          @"children" : children
          };
    }
    else
    {
        return [self colorToHexString:backgroud];
    }
}

+ (id)toStrokeAttr:(id)width color:(id/*string|UIColor*/)color
{
    if(isNSNumber(width))
    {
        width = [NSString stringWithFormat:@"%@px", width];
    }
    if(isNSString(width))
    {
        return @{
                 ValueKey(A_class) : ValueKey(A_stroke),
                 ValueKey(A_color) : [self colorToHexString:color],
                 ValueKey(A_width) : width
                 };
    }
    return @"";
}

+ (NSString*)toColorAttr:(id/*string|UIColor*/)color
{
    return [self colorToHexString:color];
}

+ (NSDictionary*)toSolidAttr:(id/*string|UIColor*/)color
{
    return @{
             ValueKey(A_class) : ValueKey(A_solid),
             ValueKey(A_color) : [self colorToHexString:color]
             };
}

+ (id)toCornersAttr:(id)radius
{
    if(isNSString(radius))
    {
        return @{
                 ValueKey(A_class) : ValueKey(A_corners),
                 ValueKey(A_radius) : radius
                 };
    }
    else if(isNSNumber(radius))
    {
        return @{
                 ValueKey(A_class) : ValueKey(A_corners),
                 ValueKey(A_corners) : [NSString stringWithFormat:@"%@dp", radius]
                 };
    }
    return @"";
}

+ (NSString*)colorToHexString:(id)color
{
    if(isNSString(color))
    {
        return color;
    }
    else if(isUIColor(color))
    {
        CGFloat r,g,b,a;
        [color getRed:&r green:&g blue:&b alpha:&a];
        int red = (int)(r * 255 + 0.5);
        int green = (int)(g * 255 + 0.5);
        int blue = (int)(b * 255 + 0.5);
        int alpha = (int)(a * 255 + 0.5);
        NSString* hexString = [NSString stringWithFormat:@"#%02X%02X%02X%02X", alpha, red, green, blue];
        return hexString;
    }
    return @"";
}

#if DEBUG
- (NSString *)description
{
    return [NSString stringWithFormat:@"<AttributeReader %p \nattribute:%@>", (void *)self, _attribute];
}
#endif

@end
