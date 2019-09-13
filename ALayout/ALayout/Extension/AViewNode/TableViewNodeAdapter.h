//
//  TableViewNodeAdapter.h
//  lite
//
//  Created by splendourbell on 2019/4/13.
//  Copyright © 2019年 chelaile. All rights reserved.
//

#import <ALayout/ALayout.h>
#import "AViewNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface TableViewSectionHeader : AViewNode
@end

@interface TableViewSectionFooter : AViewNode
@end

@interface TableViewNodeAdapter : NSObject<UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL canScroll;
@property (nonatomic, assign) CGFloat lastOffset;

@property (nonatomic, weak) UITableView* tableView;

@property (nonatomic) NSMutableArray<AViewNode*>* viewNodes;

- (instancetype)initWithTableView:(UITableView*)tableView;

@end

NS_ASSUME_NONNULL_END
