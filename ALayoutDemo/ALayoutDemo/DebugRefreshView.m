//
//  DebugRefreshView.m
//
//  Copyright © 2017年 splendourbell. All rights reserved.
//

#ifdef DEBUG

#import <UIKit/UIKit.h>
#import <ALayout/ALayout.h>
#import <objc/runtime.h>

@interface DebugRefreshView : UIWindow

@end

@implementation DebugRefreshView

static DebugRefreshView* win = nil;
static void* _AttrForView = &_AttrForView;

+ (void)load {

#if TARGET_OS_SIMULATOR
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self ShowTest];
    });
#endif
}

+ (void)ShowTest {

    AViewCreator* viewCreator = [AViewCreator viewCreatorWithName:@"@layout/Test.json" withTarget:self];
    if(viewCreator){
        win = [[DebugRefreshView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        win.hidden = NO;
        win.windowLevel = 2000;
        [win TestJson];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self ShowTest];
        });
    }
}

- (void)TestJson {
    [self[@"view"] removeFromSuperview];
    AViewCreator* viewCreator = [AViewCreator viewCreatorWithName:@"@layout/Test.json" withTarget:self];
    if(viewCreator){
        UIView* contentView = [viewCreator loadViewHierarchy];
        contentView.viewId = @"view";
        [self addLayoutContentView:contentView];
        int sec = 1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self TestJson];
        });
    } else {
        self.hidden = YES;
        [self.class ShowTest];
    }
}
    
@end

#endif

