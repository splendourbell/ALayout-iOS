//
//  NormalViewController.m
//  ALayoutDemo
//
//  Created by bell on 2019/6/9.
//  Copyright © 2019 Splendour Bell. All rights reserved.
//

#import "NormalViewController.h"
#import <ALayout/ALayout.h>

@interface NormalViewController ()

@property (nonatomic) UIView* contentView;

@end

@implementation NormalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AViewCreator* viewCreator = [AViewCreator viewCreatorWithName:@"@layout/NewsOneImageCell" withTarget:self];
    UIView* view = [viewCreator loadViewHierarchy];
    
    //修改状态数据
    AViewNode* viewNode = AViewNode.new;
    viewNode.layout_marginTop = 200;
    viewNode.extData = @"这是一段文件，extData可以是任意对象";
    [viewNode updateToView:view];
    
    [self.view addLayoutContentView:view];
    self.view.backgroundColor = UIColor.whiteColor;
    self.contentView = view;
}

#pragma mark actions
- (void)cellClickAction:(UIControl*)control
{
    AViewNode* viewNode = AViewNode.new;
    viewNode[@"title"].text = [NSString stringWithFormat:@"修改一个title,随时数%@", @(rand())];
    [viewNode updateToView:self.contentView];
}

- (void)cellImageClickAction:(UIControl*)control
{
    NSString* message = control.viewParams.extData;
    NSString* title = ((TextLabel*)self.contentView[@"title"]).text;
    UIAlertController* vc = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"确定(图片)" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [vc addAction:action];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

@end
