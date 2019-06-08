//
//  AViewNode.h
//  lite
//
//  Created by bell on 2019/4/17.
//  Copyright © 2019 chelaile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+Params.h"
#import "UIView+ALayout.h"
#import "AViewCreator.h"

@class AViewNode;

typedef UIView* (^LoadViewBlock)(AViewNode* viewNode);

typedef void (^UpdateViewBlock)(UIView* view, AViewNode* viewNode);

typedef CGFloat (^ViewHeightBlock)(AViewNode* viewNode);

@interface AViewNode : NSObject

@property (nonatomic, readonly) NSString* layout;

@property (nonatomic, readonly) LoadViewBlock loadViewBlock;

@property (nonatomic) UpdateViewBlock updateViewBlock;

@property (nonatomic) UpdateViewBlock createdViewBlock;

@property (nonatomic, readonly) ViewHeightBlock viewHieghtBlock;

@property (nonatomic) id extData;

@property (nonatomic) NSString* reuseIdentifier;

@property (nonatomic) NSString *textStyle;
@property (nonatomic) CGFloat textSize;
@property (nonatomic) CGFloat layout_width;
@property (nonatomic) CGFloat layout_height;
@property (nonatomic) CGFloat layout_marginTop;
@property (nonatomic) CGFloat layout_marginBottom;
@property (nonatomic) CGFloat layout_marginLeft;
@property (nonatomic) CGFloat layout_marginRight;
@property (nonatomic) CGFloat maxWidth;
@property (nonatomic) CGFloat aspectRatio;
@property (nonatomic) NSString* text;
@property (nonatomic) NSString* url;
@property (nonatomic) BOOL visible;
@property (nonatomic) BOOL gone;
@property (nonatomic) BOOL clickable;
@property (nonatomic) BOOL selected;
@property (nonatomic) BOOL on;
@property (nonatomic) NSInteger tag;
@property (nonatomic) NSArray<AViewNode*>* children;
@property (nonatomic) BOOL forHeight;
@property (nonatomic, weak) id actionTarget;

- (instancetype)initWithLayout:(NSString*)layout;

- (instancetype)initWithView:(LoadViewBlock)loadView height:(ViewHeightBlock)viewNodeHeight reuseIdentifier:(NSString*)reuseIdentifier;

- (instancetype)initWithAttr:(NSDictionary*)viewAttr;

- (AViewNode*)objectForKeyedSubscript:(NSString*)viewId;

- (UIView*)attachToView:(UIView*)view;

- (void)updateToView:(UIView*)view;

- (void)updateToViewForHeight:(UIView*)view;

@end
