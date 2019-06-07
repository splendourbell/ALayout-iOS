//
//  ViewRegister.m
//  ALayout
//
//  Created by splendourbell on 2017/4/25.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "ViewRegister.h"
#import "Button.h"
#import "TextLabel.h"
#import "ImageView.h"
#import "LinearLayout.h"
#import "RelativeLayout.h"
#import "FlowLayout.h"


@implementation ViewRegister

+ (void)load
{
    RegisterViewClass(@"View",              UIView.class);
    RegisterViewClass(@"Button",            Button.class);
    RegisterViewClass(@"TextView",          TextLabel.class);
    RegisterViewClass(@"ImageView",         ImageView.class);
    RegisterViewClass(@"LinearLayout",      LinearLayout.class);
    RegisterViewClass(@"RelativeLayout",    RelativeLayout.class);
    RegisterViewClass(@"FlowLayout",        FlowLayout.class);
}

@end
