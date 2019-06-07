//
//  TableViewNodeAdapter.m
//  lite
//
//  Created by bell on 2019/4/21.
//  Copyright © 2019 chelaile. All rights reserved.
//

#import "TableViewNodeAdapter.h"

@implementation TableViewSectionHeader
@end

@implementation TableViewSectionFooter
@end

@interface TableViewSection : NSObject
@property (nonatomic) TableViewSectionHeader* header;
@property (nonatomic) TableViewSectionFooter* footer;
@property (nonatomic) NSMutableArray<AViewNode*>* viewNodes;
@end

@implementation TableViewSection
- (instancetype)init { self = super.init; _viewNodes = NSMutableArray.new; return self;}
@end

@interface TableViewNodeAdapter()

@property (nonatomic) NSMutableArray<TableViewSection*>* sections;

@property (nonatomic) NSMutableDictionary<NSString*, AViewCreator*>* viewCreatorCaches;

@end

@implementation TableViewNodeAdapter

- (instancetype)initWithTableView:(UITableView*)tableView
{
    if(self = [super init])
    {
        _canScroll = YES;
        _tableView = tableView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return self;
}

- (void)setViewNodes:(NSMutableArray *)viewNodes
{
    _viewNodes = viewNodes;
    [self reloadData];
}

- (void)reloadData
{
    _sections = [NSMutableArray new];
    TableViewSection* sectionItem = TableViewSection.new;
    [_sections addObject:sectionItem];
    
    for(AViewNode* viewNode in _viewNodes)
    {
        if([viewNode isKindOfClass:TableViewSectionHeader.class])
        {
            if(sectionItem.viewNodes.count == 0 && !sectionItem.header)
            {
                sectionItem.header = (TableViewSectionHeader*)viewNode;
            }
            else
            {
                sectionItem = TableViewSection.new;
                [_sections addObject:sectionItem];
                sectionItem.header = (TableViewSectionHeader*)viewNode;
            }
        }
        else if([viewNode isKindOfClass:TableViewSectionFooter.class])
        {
            sectionItem.footer = (TableViewSectionFooter*)viewNode;
            sectionItem = TableViewSection.new;
            [_sections addObject:sectionItem];
        }
        else
        {
            [sectionItem.viewNodes addObject:viewNode];
        }
    }
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _sections[section].viewNodes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AViewNode* viewNode = [self viewNode:indexPath];
    NSString* identifier = viewNode.reuseIdentifier;
    
    UITableViewCell* cell = nil;
    if(identifier.length > 0) 
    {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    }
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = UIColor.clearColor;
        [viewNode attachToView:cell.contentView];
    }
    [viewNode updateToView:cell.contentView.layoutContentView];
    if(viewNode.updateViewBlock)
    {
        viewNode.updateViewBlock(cell.contentView.layoutContentView, viewNode);
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AViewNode* viewNode = [self viewNode:indexPath];
    CGFloat height = [self heightForViewNode:viewNode tableView:tableView];
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    AViewNode* viewNode = _sections[section].header;
    if(viewNode)
    {
        AViewCreator* viewCreator = [self getViewCreator:viewNode.layout cacheKey:viewNode.layout];
        UIView* view = [viewCreator loadViewHierarchy];
        [viewNode updateToView:view];
        [view measureAndLayoutWithWidth:tableView.frame.size.width];
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    AViewNode* viewNode = _sections[section].header;
    CGFloat height = [self heightForViewNode:viewNode tableView:tableView];
    return height;
}

- (CGFloat)heightForViewNode:(AViewNode*)viewNode tableView:(UITableView*)tableView
{
    CGFloat height = 0.f;
    if(viewNode.viewHieghtBlock)
    {
        height = viewNode.viewHieghtBlock(viewNode);
    }
    else if(viewNode.loadViewBlock)
    {
        height = viewNode.loadViewBlock(viewNode).frame.size.height;
    }
    else if(viewNode.layout)
    {
        NSString* cacheKey = [NSString stringWithFormat:@"%@_forHeight", viewNode.layout];
        AViewCreator* viewCreator = [self getViewCreator:viewNode.layout cacheKey:cacheKey];
        UIView* cacheView = [viewCreator loadViewHierarchy:true];
        cacheView.viewParams.requestLayout = NO;
        [viewNode updateToViewForHeight:cacheView];
        height = [cacheView measureWithWidth:tableView.frame.size.width].height;
    }
    return height;
}

- (AViewCreator*)getViewCreator:(NSString*)name cacheKey:(NSString*)cacheKey
{
    AViewCreator* viewCreator = self.viewCreatorCaches[cacheKey];
    if(!viewCreator)
    {
        viewCreator = [AViewCreator viewCreatorWithName:name withTarget:nil];
        self.viewCreatorCaches[cacheKey] = viewCreator;
    }
    return viewCreator;
}

- (NSMutableDictionary<NSString*, AViewCreator*>*)viewCreatorCaches
{
    if(!_viewCreatorCaches)
    {
        _viewCreatorCaches = [NSMutableDictionary new];
    }
    return _viewCreatorCaches;
}

- (AViewNode*)viewNode:(NSIndexPath*)indexPath
{
    return _sections[indexPath.section].viewNodes[indexPath.row];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_canScroll) {
        scrollView.contentOffset = CGPointMake(0, _lastOffset);
    }
    _lastOffset = scrollView.contentOffset.y;
}

@end
