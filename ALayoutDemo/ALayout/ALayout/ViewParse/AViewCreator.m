//
//  AViewCreator.m
//  ALayout
//
//  Created by splendourbell on 2017/4/24.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import <objc/runtime.h>
#import "AViewCreator.h"
#import "AttributeReader.h"
#import "LayoutParams.h"
#import "UIView+Params.h"
#import "UIView+ALayout.h"

@interface MergeHelperView : UIView
@end

static NSMutableDictionary<NSString*, Class>* ViewClassRegisters = nil;

void RegisterViewClass(NSString* className, Class cls)
{
    if(!ViewClassRegisters) ViewClassRegisters = [NSMutableDictionary new];
#ifdef DEBUG
    //不能重复注册
    assert(!ViewClassRegisters[className]);
#endif
    ViewClassRegisters[className] = cls;
}

static Class viewClass(NSString* className)
{
    Class cls = ViewClassRegisters[className];
    if(!cls)
    {
        cls = NSClassFromString(className);
    }
    return cls;
}

@interface AttributeReader(include)
- (NSArray<AttributeReader *> *)mergeChildren:(NSString *)name;
- (void)includeLayout:(NSString*)name;
@end

@implementation AViewCreator

- (instancetype)initWithAttr:(AttributeReader*)attrReader
{
    if(self = [self init])
    {
        _attrReader = attrReader;
    }
    return self;
}

- (UIView*)loadViewHierarchy
{
    return [self loadViewHierarchy:NO];
}

- (UIView*)loadViewHierarchy:(BOOL)cached
{
    if(cached && self.cacheView)
    {
        return self.cacheView;
    }
    
    UIView* view = [self parseTree:_attrReader];
    LayoutParams* layoutParams = [view generateLayoutParams:_attrReader];
    view.layoutParams = layoutParams;
    
    if(cached)
    {
        self.cacheView = view;
    }
    return view;
}

- (UIView*)loadViewAutoBounds:(BOOL)needLayout
{
    CGRect bounds = CGRectMake(0, 0, MAXFLOAT, MAXFLOAT);
    return [self loadViewAutoBounds:needLayout inBounds:bounds];
}

- (UIView*)loadViewAutoBounds:(BOOL)needLayout inBounds:(CGRect)bounds
{
    UIView* view = [self loadViewHierarchy];
    [view measureHierarchyInBounds:bounds];
    CGSize measuredSize = view.viewParams.measuredSize;
    bounds.size = measuredSize;
    if(needLayout)
    {
        [view layout:bounds];
    }
    return view;
}

- (UIView*)parseTree:(AttributeReader*)attrReader
{
    UIView* view = [self parseView:attrReader];
#ifdef DEBUG
    view.viewParams.filePath = attrReader.filepath;
#endif
    if(view)
    {
        [self parseChildren:attrReader parent:view];
    }
    return view;
}

- (UIView*)parseView:(AttributeReader*)attrReader
{
    attrReader.target = self.target;
    NSString* className = attrReader[@"class"];
    if(StrEq(@"include", className))
    {
        NSString* name = attrReader[@"layout"];
        [attrReader includeLayout:name];
        return [self parseView:attrReader];
    }
    else
    {
        Class cls = viewClass(className);
        if(cls)
        {
            UIView* view = nil;
            if([cls isSubclassOfClass:UITableView.class])
            {
                view = [[cls alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
            }
            else
            {
                view = [cls new];
            }
#ifdef DEBUG
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ALayoutViewCreated"
             object:@{@"view":view, @"attr":[attrReader valueForKey:@"_attribute"]}];
#endif
            [view parseAttr:attrReader];
            return view;
        }
    }
    return nil;
}

- (void)parseChildren:(AttributeReader*)attrReader parent:(UIView*)parent
{
    NSArray<NSDictionary*>* children = attrReader[@"children"];
    NSInteger length = children.count;
    for(NSInteger index = 0; index < length; ++index)
    {
        NSDictionary* attr = children[index];
        AttributeReader* childAttrReader = [[AttributeReader alloc] initWithDictionary:attr resMgr:attrReader.resourceManager];
#ifdef DEBUG
        childAttrReader.filepath = attrReader.filepath;
#endif
        UIView* view = [self parseTree:childAttrReader];
        if(view)
        {
            if(![view isKindOfClass:MergeHelperView.class])
            {
                view.layoutParams = [parent generateLayoutParams:childAttrReader];
                [parent addSubview:view];
            }
            else
            {
                NSArray<UIView*>* children = view.subviews;
                NSArray<AttributeReader *> *childrenArr = [childAttrReader mergeChildren:childAttrReader[@"layout"]];
                
                NSAssert(children.count == childrenArr.count, @"");
                
                for (int i = 0; i < children.count; ++i)
                {
                    UIView *child = children[i];
                    child.layoutParams = [parent generateLayoutParams:childrenArr[i]];
                    [child removeFromSuperview];
                    [parent addSubview:child];
                }
            }
        }
    }
    
    [parent onAddChildrenFinished];
}

+ (AViewCreator*)viewCreatorWithName:(NSString*)name withTarget:(id)target
{
    return [self viewCreatorWithName:name withTarget:target bindData:nil];
}

+ (AViewCreator*)viewCreatorWithName:(NSString*)name withTarget:(id)target bindData:(NSDictionary*)bindData
{
    ResourceManager* resourceManager = [ResourceManager defualtResourceManager];
    ResourceInfo* info = [resourceManager resourceInfo:name];
    NSData* jsonData = [NSData dataWithContentsOfFile:info.value];
    
    if (!jsonData)
    {
        NSLog(@"json %@ not found", name);
        return nil;
    }
    
    NSError *error = nil;
    
    NSDictionary* dict = nil;
    if(bindData)
    {
        NSInteger countBindData = bindData.count;
        NSMutableDictionary* mutableDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        [self replaceDataById:mutableDict replace:bindData count:&countBindData];
        dict = mutableDict;
    }
    else
    {
        dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    }
    
    if (error || !dict)
    {
        return nil;
    }
    
    AViewCreator* viewCreator = [self viewCreatorWithRawAttr:dict withTarget:target];
    viewCreator.layout = name;
#ifdef DEBUG
    viewCreator.attrReader.filepath = info.value;
#endif
    return viewCreator;
}

+ (AViewCreator*)viewCreatorWithRawAttr:(NSDictionary*)attr withTarget:(id)target
{
    ResourceManager* resourceManager = [ResourceManager defualtResourceManager];
    AttributeReader* attrReader = [[AttributeReader alloc] initWithDictionary:attr resMgr:resourceManager];
    AViewCreator* viewCreator = [[AViewCreator alloc] initWithAttr:attrReader];
    viewCreator.target = target;
    return viewCreator;
}

+ (void)replaceDataById:(NSMutableDictionary*)sourceDict replace:(NSDictionary*)replaceDict count:(NSInteger*)leftCount
{
    NSString* itemId = sourceDict[@"id"];
    NSMutableArray* children = sourceDict[@"children"];
    
    if(itemId)
    {
        NSDictionary* replaceItem = replaceDict[itemId];
        if(replaceItem)
        {
            [sourceDict addEntriesFromDictionary:replaceItem];
            -- *leftCount;
            if(*leftCount <= 0)
            {
                return;
            }
        }
    }
    
    for(NSMutableDictionary* childItem in children)
    {
        [self replaceDataById:childItem replace:replaceDict count:leftCount];
        if(*leftCount <= 0)
        {
            return;
        }
    }
}

@end


@implementation MergeHelperView
RegisterView(merge)
- (void)parseAttr:(AttributeReader *)attrReader{}
@end
