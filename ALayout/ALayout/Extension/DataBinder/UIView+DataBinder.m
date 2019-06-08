//
//  UIView+DataBinder.m
//  ALayout
//
//  Created by splendourbell on 2017/6/1.
//  Copyright © 2017年 com.aiospace.zone. All rights reserved.
//

#import "UIView+DataBinder.h"
#import "UIView+Params.h"
#import "AttributeKey.h"
#import "AViewCreator.h"
#import "LayoutParams.h"

@implementation UIView(AutoBindData)

- (void)autoBindDataForHeight:(NSDictionary*)data
{
    for(NSString* key in data)
    {
        if([key hasSuffix:@"_h"])
        {
            NSString* viewId = [key stringByReplacingOccurrencesOfString:@"_h" withString:@""];
            UIView* view = self[viewId];
            NSDictionary* properties = data[key];
            AttributeReader* attributeReader = [[AttributeReader alloc] initWithDictionary:properties resMgr:[ResourceManager defualtResourceManager]];
            [view parseAttr:attributeReader useDefault:NO];
        }
    }
}

- (void)autoBindData:(NSDictionary*)data
{
    for(NSString* key in data)
    {
        NSString* viewId = [key stringByReplacingOccurrencesOfString:@"_h" withString:@""];
        UIView* view = self[viewId];
        NSDictionary* properties = data[key];
        if(isNSString(properties))
        {
            NSString* mainKey = view.mainKey;
            if(mainKey)
            {
                properties = @{mainKey:properties};
            }
            else
            {
                continue;
            }
        }
        else if (isNSNumber(properties))
        {
            properties = @{ValueKey(A_visibility): ((NSNumber*)properties).boolValue?@"visible":@"invisible"};
        }
        AttributeReader* attributeReader = [[AttributeReader alloc] initWithDictionary:properties resMgr:[ResourceManager defualtResourceManager]];
        [view parseAttr:attributeReader useDefault:NO];
        [self resetChildren:view children:properties[ValueKey(A_children)]];
    }
}

- (UIView*)popReusedView:(NSMutableArray<UIView*>*)subViews reuse:(NSString*)reuse
{
    for(NSInteger i=0; i<subViews.count; i++)
    {
        UIView* subView = subViews[i];
        if([subView.viewParams.layout isEqualToString:reuse])
        {
            [subViews removeObjectAtIndex:i];
            return subView;
        }
    }
    return nil;
}

- (void)resetChildren:(UIView*)view children:(NSArray*)children
{
    if(children)
    {
        NSMutableArray<UIView*>* subViews = view.subviews.mutableCopy;
        
        if(children.count)
        {
            NSMutableDictionary* viewCreators = NSMutableDictionary.new;
            for(NSDictionary* dict in children)
            {
                UIView* subView = nil;
                id target = dict[@"target"];
                AViewCreator* viewCreator = nil;
                NSString* layout = dict[ValueKey(A_layout)];
                if([layout isKindOfClass:NSString.class])
                {
                    subView = [self popReusedView:subViews reuse:layout];
                    if(!subView)
                    {
                        viewCreator = viewCreators[layout];
                        if(!viewCreator)
                        {
                            viewCreator = [AViewCreator viewCreatorWithName:layout withTarget:target];
                            viewCreators[layout] = viewCreator;
                        }
                        subView = viewCreator.loadViewHierarchy;
                        ViewParams* subViewParams = subView.viewParams;
                        subViewParams.layout = viewCreator.layout;
                        subView.layoutParams = [view generateLayoutParams:viewCreator.attrReader];
                    }
                }
                else if([layout isKindOfClass:NSDictionary.class])
                {
                    viewCreator = [AViewCreator viewCreatorWithRawAttr:(NSDictionary*)layout withTarget:target];
                    subView = viewCreator.loadViewHierarchy;
                    ViewParams* subViewParams = subView.viewParams;
                    subViewParams.layout = viewCreator.layout;
                    subView.layoutParams = [view generateLayoutParams:viewCreator.attrReader];
                }
                
                if(subView)
                {
                    [view addSubview:subView];
                    [subView autoBindSelf:dict[@"bindData"]];
                    [subView autoBindData:dict[@"data"]];
                }
            }
        }
        [subViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
    }
}

- (void)autoBindSelf:(NSDictionary*)properties
{
    if(properties.count)
    {
        AttributeReader* attributeReader = [[AttributeReader alloc] initWithDictionary:properties resMgr:[ResourceManager defualtResourceManager]];
        [self parseAttr:attributeReader useDefault:NO];
        [self resetChildren:self children:properties[ValueKey(A_children)]];
    }
}

- (void)scriptBindData:(NSDictionary*)data binder:(id<DataBinderProtocol>)dataBinder
{
    [self scriptBindData:data binder:dataBinder forHeight:NO];
}

- (void)scriptBindData:(NSDictionary*)data binder:(id<DataBinderProtocol>)dataBinder forHeight:(BOOL)forHeight
{
    NSDictionary* bindedData = [dataBinder generateBindData:data dataBinder:self.viewParams.dataBinder forHeight:forHeight];
    [self autoBindData:bindedData];
}

@end

