//
//  ViewController.m
//  ALayoutDemo
//
//  Created by bell on 2019/6/6.
//  Copyright © 2019 Splendour Bell. All rights reserved.
//

#import "ViewController.h"
#import <ALayout/ALayout.h>

@interface ViewController ()

@property (nonatomic) UITableView* tableView;

@property (nonatomic) TableViewNodeAdapter* tableViewAdapter;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AViewCreator* viewCreator = [AViewCreator viewCreatorWithName:@"@layout/MyViewController" withTarget:self];
    UIView* view = [viewCreator loadViewHierarchy];
    [self.view addLayoutContentView:view];
    
    self.tableView = view[@"tableView"];
    
    self.tableViewAdapter = [[TableViewNodeAdapter alloc] initWithTableView:self.tableView];
    [self fillData];
}

- (void)fillData
{
    NSMutableArray<AViewNode*>* viewNodes = [[NSMutableArray alloc] init];
    
    NSArray* dataArray = [self getTestData];
    
    for(NSInteger i=0; i<5; i++)
    {
        AViewNode* sectionViewNode = [[TableViewSectionHeader alloc] initWithLayout:@"@layout/SectionView"];
        sectionViewNode[@"sectionTitle"].text = [NSString stringWithFormat:@"Section %@", @(i+1)];
        sectionViewNode[@"sectionTitle"].forHeight = YES;//此结点绑定的数据会影响高度，设置为YES。主要是优化作用。
        [viewNodes addObject:sectionViewNode];
        
        for(NSInteger j=0; j<20; j++)
        {
            NSInteger randIndex = rand() % dataArray.count;
            NSDictionary* theData = dataArray[randIndex];
            NSString* type = theData[@"type"];
            
            AViewNode* viewNode = nil;
            if([type isEqualToString:@"NoImage"])
            {
                viewNode = [[AViewNode alloc] initWithLayout:@"@layout/NewsNoImageCell"];
            }
            else if([type isEqualToString:@"OneImage"])
            {
                viewNode = [[AViewNode alloc] initWithLayout:@"@layout/NewsOneImageCell"];
            }
            else if([type isEqualToString:@"BigImage"])
            {
                viewNode = [[AViewNode alloc] initWithLayout:@"@layout/NewsBigImageCell"];
            }
            else
            {
                continue;
            }
            
            viewNode.actionTarget = self;
            viewNode.extData = theData;
            
            viewNode[@"image"].url = theData[@"image"];
            viewNode[@"title"].text = theData[@"title"];
            viewNode[@"top"].gone = (rand()%2 == 0);
            NSInteger hotCount = rand() % 20000;
            NSString* hotString = nil;
            if(hotCount >= 10000)
            {
                hotString = [NSString stringWithFormat:@"%0.1f万跟帖", hotCount / 10000.0];
                viewNode[@"highlightComments"].text = hotString;
                viewNode[@"highlightComments"].gone = NO;
                viewNode[@"normalComments"].gone = YES;
            }
            else
            {
                hotString = [NSString stringWithFormat:@"%@跟帖", @(hotCount)];
                viewNode[@"normalComments"].text = hotString;
                viewNode[@"normalComments"].gone = NO;
                viewNode[@"highlightComments"].gone = YES;
            }
            
            [viewNodes addObject:viewNode];
        }
    }
    self.tableViewAdapter.viewNodes = viewNodes;
}

#pragma mark actions
- (void)cellClickAction:(UIControl*)control
{
    NSDictionary* dict = control.viewParams.extData;
    UIAlertController* vc = [UIAlertController alertControllerWithTitle:dict[@"type"] message:dict[@"title"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [vc addAction:action];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)cellImageClickAction:(UIControl*)control
{
    NSDictionary* dict = control.viewParams.extData;
    UIAlertController* vc = [UIAlertController alertControllerWithTitle:dict[@"type"] message:dict[@"title"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"确定(图片)" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [vc addAction:action];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (NSArray*)getTestData
{
    return @[
      @{
          @"title":@"这个布局核心逻辑是从Android 系统源码移植过来的，与Android几乎保持了一致，因为是为了两端共用，我们同时支持了Android和iOS，Android暂时还在准备开源中...",
          @"author":@"央视新闻移动网",
          @"hotCount":@(500),
          @"isTop":@(true),
          @"type":@"NoImage"
      },
      @{
          @"title":@"这个布局核心逻辑是从Android 系统源码移植过来的，与Android几乎保持了一致，因为是为了两端共用，我们同时支持了Android和iOS，Android暂时还在准备开源中...",
          @"image":@"http://file.6clue.com/jiyuspace/20190523/642/972/3c3bf86049715cf5d6abfa887b277a81.jpg",
          @"author":@"央视新闻移动网",
          @"hotCount":@(10500),
          @"isTop":@(true),
          @"type":@"OneImage"
          },
      @{
          @"title":@"这个布局核心逻辑是从Android 系统源码移植过来的，与Android几乎保持了一致，因为是为了两端共用，我们同时支持了Android和iOS，Android暂时还在准备开源中...",
          @"image":@"http://file.6clue.com/jiyuspace/20190602/1080/811/47e94d154b69acaaa91acd03eaec7531.jpg?x-oss-process=image/quality,q_85",
          @"author":@"央视新闻移动网",
          @"hotCount":@(83200),
          @"isTop":@(false),
          @"type":@"BigImage"
          }
      ];
}

@end
