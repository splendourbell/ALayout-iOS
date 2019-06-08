//
//  AViewCreator.h
//  ALayout
//
//  Created by splendourbell on 2017/4/24.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttributeReader.h"
#import "UIView+ALayout.h"

void RegisterViewClass(NSString* viewName, Class cls);

#define RegisterView(viewName) \
+ (void)load \
{\
    RegisterViewClass(@#viewName, self);\
}

@interface AViewCreator : NSObject

@property (nonatomic, strong) UIView* cacheView;

@property (nonatomic, readonly) AttributeReader* attrReader;

@property (nonatomic, weak) id target;

@property (nonatomic) NSString* layout;

+ (AViewCreator*)viewCreatorWithName:(NSString*)name withTarget:(id)target;

+ (AViewCreator*)viewCreatorWithName:(NSString*)name withTarget:(id)target bindData:(NSDictionary*)bindData;

+ (AViewCreator*)viewCreatorWithRawAttr:(NSDictionary*)attr withTarget:(id)target;

- (instancetype)initWithAttr:(AttributeReader*)attrReader;

- (__kindof UIView*)loadViewHierarchy;

- (__kindof UIView*)loadViewHierarchy:(BOOL)cached;

- (__kindof UIView*)loadViewAutoBounds:(BOOL)needLayout;

- (__kindof UIView*)loadViewAutoBounds:(BOOL)needLayout inBounds:(CGRect)bounds;

@end
