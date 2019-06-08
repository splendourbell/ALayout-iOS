//
//  LayoutParams.h
//  ALayout
//
//  Created by splendourbell on 2017/4/19.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttributeReader.h"

@interface LayoutParams : NSObject

@property (nonatomic) CGFloat layout_width;
@property (nonatomic) CGFloat layout_height;

- (instancetype)initWithAttr:(AttributeReader*)attrReader;

- (instancetype)initWithWidth:(CGFloat)width height:(CGFloat)height;

- (void)parseAttr:(AttributeReader*)attrReader useDefault:(BOOL)useDefault;

@end

@interface UIView(LayoutParams)

@property (nonatomic) __kindof LayoutParams* layoutParams;

@end
