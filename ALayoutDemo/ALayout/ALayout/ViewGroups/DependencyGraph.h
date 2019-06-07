//
//  DependencyGraph.h
//  ALayout
//
//  Created by splendourbell on 2017/4/11.
//  Copyright © 2017年 ajja.sdjkf.sd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DependencyGraph_Node : NSObject

@property (nonatomic) UIView* view;
@property (nonatomic) NSMutableArray<DependencyGraph_Node*>* dependents;
@property (nonatomic) NSMutableDictionary<NSString*, DependencyGraph_Node*>* dependencies;

@end

@interface DependencyGraph : NSObject

@property (nonatomic) NSMutableArray<DependencyGraph_Node*>* nodes;
@property (nonatomic) NSMutableDictionary<NSString*, DependencyGraph_Node*>* keyNodes;
@property (nonatomic) NSMutableArray<DependencyGraph_Node*>* roots;

- (void)clear;

- (void)add:(UIView*)view;

- (void)sortedViews:(NSMutableArray<UIView*>*)sorted rules:(NSArray<NSNumber*>*) rules;

@end
