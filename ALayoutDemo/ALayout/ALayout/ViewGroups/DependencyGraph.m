//
//  DependencyGraph.m
//  ALayout
//
//  Created by splendourbell on 2017/4/11.
//  Copyright © 2017年 ajja.sdjkf.sd. All rights reserved.
//

#import "UIView+Params.h"
#import "DependencyGraph.h"
#import "RelativeLayoutParams.h"

@implementation DependencyGraph_Node

- (instancetype)initWithView:(UIView*)view
{
    if(self = [super init])
    {
        _view = view;
        _dependents   = [NSMutableArray new];
        _dependencies = [NSMutableDictionary dictionary];
    }
    return self;
}

@end


@implementation DependencyGraph

- (instancetype)init
{
    if(self = [super init])
    {
        _nodes = [NSMutableArray new];
        _keyNodes = [NSMutableDictionary new];
        _roots = [NSMutableArray new];
    }
    return self;
}

- (void)clear
{
    NSMutableArray<DependencyGraph_Node*>* nodes = _nodes;
    int count = (int)nodes.count;
    
    for(int i = 0; i < count; i++)
    {
        // [nodes[i] release];
    }
    [nodes removeAllObjects];
    [_keyNodes removeAllObjects];
    [_roots removeAllObjects];
}

- (void)add:(UIView*)view
{
    NSString* strTag = view.viewId;
    DependencyGraph_Node* node = [[DependencyGraph_Node alloc] initWithView:view];
    if(strTag)
    {
        _keyNodes[strTag] = node;
    }
    [_nodes addObject:node];
}

- (void)sortedViews:(NSMutableArray<UIView*>*)sorted rules:(NSArray<NSNumber*>*) rules
{
    NSMutableArray<DependencyGraph_Node*>* roots = [self findRoots:rules];
    
    DependencyGraph_Node* node;
    while ((node = roots.lastObject))
    {
        [roots removeLastObject];
        
        UIView* view = node.view;
        NSString* key = view.viewId;
        
        [sorted addObject:view];
        
        NSMutableArray<DependencyGraph_Node*>* dependents = node.dependents;
        int count = (int)dependents.count;
        for (int i = 0; i < count; i++)
        {
            DependencyGraph_Node* dependent = dependents[i];
            NSMutableDictionary<NSString*, DependencyGraph_Node*>* dependencies = dependent.dependencies;
            
            [dependencies removeObjectForKey:key];
            if (0 == dependencies.count)
            {
                [roots addObject:dependent];
            }
        }
    }
}

- (NSMutableArray<DependencyGraph_Node*>*)findRoots:(NSArray<NSNumber*>*)rulesFilter
{
    NSMutableDictionary<NSString*, DependencyGraph_Node*>* keyNodes = _keyNodes;
    NSMutableArray<DependencyGraph_Node*>* nodes = _nodes;
    
    const int count = (int)nodes.count;
    
    for (int i = 0; i < count; i++)
    {
        DependencyGraph_Node* node = nodes[i];
        [node.dependents removeAllObjects];
        [node.dependencies removeAllObjects];
    }
    
    const int filterCount = (int)rulesFilter.count;
    
    for (int i = 0; i < count; i++)
    {
        DependencyGraph_Node* node = nodes[i];
        RelativeLayoutParams* layoutParams = (RelativeLayoutParams*)node.view.layoutParams;
        RelativeRule* rules = layoutParams.rules;
        
        for (int j = 0; j < filterCount && rules.count > 0; j++)
        {
            NSString* rule = rules[rulesFilter[j]];
            if (rule)
            {
                DependencyGraph_Node* dependency = keyNodes[rule];
                if (dependency && dependency != node)
                {
                    [dependency.dependents addObject:node];
                    node.dependencies[rule] = dependency;
                }
            }
        }
    }
    
    NSMutableArray<DependencyGraph_Node*>* roots = _roots;
    [roots removeAllObjects];
    
    for (int i = 0; i < count; i++)
    {
        DependencyGraph_Node* node = nodes[i];
        if (0 == node.dependencies.count)
        {
            [roots addObject:node];
        }
    }
    return roots;
}


@end
