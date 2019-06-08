//
//  View.h
//  ALayout
//
//  Created by splendourbell on 2017/4/19.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeasureSpec.h"

typedef int ViewToken;

@interface ViewManager : NSObject

- (ViewToken)createView:(NSDictionary*) attribute;

- (void)removeView:(ViewToken)viewToken;

- (void)addViewFor:(ViewToken)parentToken subToken:(ViewToken)viewToken;

- (void)onMeasure:(ViewToken)viewToken widthSpec:(MeasureSpec)widthSpec heightSpec:(MeasureSpec)heightSpec;

@end
