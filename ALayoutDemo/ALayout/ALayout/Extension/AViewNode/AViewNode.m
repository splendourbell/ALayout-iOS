//
//  AViewNode.m
//  lite
//
//  Created by bell on 2019/4/17.
//  Copyright © 2019 chelaile. All rights reserved.
//

#import "AViewNode.h"
#import <ALayout/ALayout.h>

#define JoinStr(...) [@[__VA_ARGS__] componentsJoinedByString:@""]
#define JoinFmt(format, ...) [NSString stringWithFormat:format, __VA_ARGS__]

static inline NSString* _Nullable layoutToIdentifier(NSString* _Nullable layout)
{
    return [layout stringByReplacingOccurrencesOfString:@"@" withString:@""];
}

#define kChildren ValueKey(A_children)
@interface AViewNode()
{
    __weak id _actionTarget;
}
@property (nonatomic, weak) AViewNode* parent;
@property (nonatomic) NSDictionary* viewAttr;
@property (nonatomic) NSString* viewId;

@property (nonatomic) NSMutableDictionary<NSString*, AViewNode*>* dataNodes;

@property (nonatomic) NSMutableDictionary<NSString*, id>* property;

@end

@implementation AViewNode

- (instancetype)initWithLayout:(NSString*)layout
{
    if(self = [super init])
    {
        _layout = layout;
    }
    return self;
}

- (instancetype)initWithView:(LoadViewBlock)loadViewBlock height:(ViewHeightBlock)viewHieghtBlock reuseIdentifier:(NSString*)reuseIdentifier
{
    if(self = [super init])
    {
        _loadViewBlock = loadViewBlock;
        _viewHieghtBlock = viewHieghtBlock;
        _reuseIdentifier = reuseIdentifier;
    }
    return self;
}

- (NSString*)reuseIdentifier
{
    if(!_reuseIdentifier)
    {
        _reuseIdentifier = layoutToIdentifier(_layout);
    }
    return _reuseIdentifier;
}

- (instancetype)initWithAttr:(NSDictionary*)viewAttr
{
    if(self = [super init])
    {
        _viewAttr = viewAttr;
    }
    return self;
}

- (AViewNode*)objectForKeyedSubscript:(NSString*)viewId
{
    if(self.parent)
    {
        return self.parent[JoinStr(self.viewId, @".", viewId)];
    }
    
    AViewNode* viewNode = self.dataNodes[viewId];
    if(!viewNode)
    {
        viewNode = [[AViewNode alloc] init];
        viewNode.viewId = viewId;
        viewNode.parent = self;
        self.dataNodes[viewId] = viewNode;
    }
    return viewNode;
}

- (void)updateToView:(UIView*)view
{
    for(NSString* viewId in _dataNodes)
    {
        AViewNode* viewNode = _dataNodes[viewId];
        id extData = viewNode.extData;
        if(extData)
        {
            UIView* subView = view[viewId];
            subView.viewParams.extData = viewNode.extData;
        }
        [view autoBindData:@{viewId:viewNode.property}];
    }
    [view autoBindSelf:_property];
    view.viewParams.extData = self.extData;
}

- (void)updateToViewForHeight:(UIView*)view
{
    for(NSString* viewId in _dataNodes)
    {
        AViewNode* viewNode = _dataNodes[viewId];
        if(viewNode.forHeight)
        {
            [view autoBindData:@{viewId:viewNode.property}];
        }
    }
    if(self.forHeight)
    {
        [view autoBindSelf:_property];
    }
}

- (UIView*)attachToView:(UIView*)view
{
    UIView* subView = nil;
    if(self.loadViewBlock)
    {
        subView = self.loadViewBlock(self);
        [view addLayoutContentView:subView];
    }
    else
    {
        AViewCreator* viewCreator = nil;
        if(_layout)
        {
            viewCreator = [AViewCreator viewCreatorWithName:_layout withTarget:self.actionTarget];
        }
        subView = [viewCreator loadViewHierarchy];
        [view addLayoutContentView:subView];
    }
    if(self.createdViewBlock)
    {
        self.createdViewBlock(subView, self);
    }
    return subView;
}

- (void)setActionTarget:(id)actionTarget
{
    _actionTarget = actionTarget;
}

- (id)actionTarget
{
    if(_actionTarget)
    {
        return _actionTarget;
    }
    return self.parent.actionTarget;
}

- (CGFloat)layout_height
{
    return [self.property[ValueKey(A_layout_height)] floatValue];
}

- (void)setLayout_height:(CGFloat)layout_height
{
    self.property[ValueKey(A_layout_height)] = JoinFmt(@"%@dp", @(layout_height));
}

- (CGFloat)layout_width
{
    return [self.property[ValueKey(A_layout_width)] floatValue];
}

- (void)setLayout_width:(CGFloat)layout_width
{
    self.property[ValueKey(A_layout_width)] = JoinFmt(@"%@dp", @(layout_width));
}

- (CGFloat)aspectRatio
{
    return [self.property[ValueKey(A_aspectRatio)] floatValue];
}

- (void)setAspectRatio:(CGFloat)aspectRatio
{
    self.property[ValueKey(A_aspectRatio)] = JoinFmt(@"%@", @(aspectRatio));
}

- (CGFloat)maxWidth
{
    return [self.property[ValueKey(A_maxWidth)] floatValue];
}

- (void)setMaxWidth:(CGFloat)maxWidth
{
    self.property[ValueKey(A_maxWidth)] = JoinFmt(@"%@dp", @(maxWidth));
}

- (CGFloat)layout_marginTop
{
    return [self.property[ValueKey(A_layout_marginTop)] floatValue];
}

- (void)setLayout_marginTop:(CGFloat)layout_marginTop
{
    self.property[ValueKey(A_layout_marginTop)] = JoinFmt(@"%@dp", @(layout_marginTop));
}

- (CGFloat)layout_marginBottom
{
    return [self.property[ValueKey(A_layout_marginBottom)] floatValue];
}

- (void)setLayout_marginBottom:(CGFloat)layout_marginBottom
{
    self.property[ValueKey(A_layout_marginBottom)] = JoinFmt(@"%@dp", @(layout_marginBottom));
}

- (CGFloat)layout_marginLeft
{
    return [self.property[ValueKey(A_layout_marginLeft)] floatValue];
}

- (void)setLayout_marginLeft:(CGFloat)layout_marginLeft
{
    self.property[ValueKey(A_layout_marginLeft)] = JoinFmt(@"%@dp", @(layout_marginLeft));
}

- (CGFloat)layout_marginRight
{
    return [self.property[ValueKey(A_layout_marginRight)] floatValue];
}

- (void)setLayout_marginRight:(CGFloat)layout_marginRight
{
    self.property[ValueKey(A_layout_marginRight)] = JoinFmt(@"%@dp", @(layout_marginRight));
}

- (void)setText:(NSString*)text
{
    self.property[ValueKey(A_text)] = text;
}

- (NSString*)text
{
    return self.property[ValueKey(A_text)];
}

- (void)setExtData:(id)extData
{
    self.property[@"extData"] = extData;
}

- (id)extData
{
    return self.property[@"extData"];
}

- (void)setTag:(NSInteger)tag
{
    self.property[ValueKey(A_tag)] = @(tag).stringValue ;
}

-(NSInteger)tag
{
    return [self.property[ValueKey(A_tag)] integerValue];
}

- (void)setUrl:(NSString *)url
{
    self.property[ValueKey(A_url)] = url;
}

- (NSString*)url
{
    return self.property[ValueKey(A_url)];
}

- (CGFloat)textSize
{
    return [self.property[ValueKey(A_textSize)] floatValue];
}

-(void)setTextSize:(CGFloat)textSize
{
    self.property[ValueKey(A_textSize)] = JoinFmt(@"%@dp", @(textSize));
}


-(void)setTextStyle:(NSString *)textStyle
{
    self.property[ValueKey(A_textStyle)] = textStyle;
}

-(NSString *)textStyle
{
    return self.property[ValueKey(A_textStyle)];
}

- (void)setVisible:(BOOL)visible
{
    self.property[ValueKey(A_visibility)] = visible?@"visible":@"invisible";
}

- (BOOL)visible
{
    return [self.property[ValueKey(A_visibility)] isEqual:@"visible"];
}

- (void)setGone:(BOOL)gone
{
    self.property[ValueKey(A_visibility)] = gone?@"gone":@"visible";
}

- (BOOL)gone
{
    return [self.property[ValueKey(A_visibility)] isEqual:@"gone"];
}

- (void)setClickable:(BOOL)clickable
{
    self.property[ValueKey(A_clickable)] = clickable?@"true":@"false";
}

- (BOOL)clickable
{
    return [self.property[ValueKey(A_clickable)] isEqual:@"true"];
}

- (void)setSelected:(BOOL)selected
{
    self.property[ValueKey(A_selected)] = selected?@"true":@"false";
}

- (BOOL)selected
{
    return [self.property[ValueKey(A_selected)] isEqual:@"true"];
}

- (BOOL)on
{
    return [self.property[ValueKey(A_on)] isEqual:@"true"];
}

-(void)setOn:(BOOL)on
{
    self.property[ValueKey(A_on)] = on?@"true":@"false";
}

- (void)setForHeight:(BOOL)forHeight
{
    self.property[ValueKey(A_forHeight)] = forHeight?@"true":@"false";
}

- (BOOL)forHeight
{
    return [self.property[ValueKey(A_forHeight)] isEqual:@"true"];
}

- (void)setChildren:(NSArray<AViewNode*>*)children
{
    _children = children;
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:children.count];
    for(NSInteger i=0; i<children.count; i++)
    {
        AViewNode* viewNode = children[i];
        viewNode.parent = self;
        id layout = viewNode.layout ?: viewNode.viewAttr;
        NSMutableDictionary* data = [[NSMutableDictionary alloc] initWithCapacity:children[i].dataNodes.count];
        NSDictionary<NSString*, AViewNode*>* dataNodes = children[i].dataNodes;
        for(NSString* viewId in dataNodes)
        {
            data[viewId] = dataNodes[viewId].property;
        }
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        params[ValueKey(A_layout)] = ((layout)?:@"");
        params[@"data"] = data;
        params[@"target"] = viewNode.actionTarget;
        params[@"bindData"] = viewNode.property;
        [array addObject:params];
    }
    self.property[ValueKey(A_children)] = array;
}

- (NSMutableDictionary<NSString*, AViewNode*>*) dataNodes
{
    if(!_dataNodes)
    {
        _dataNodes = NSMutableDictionary.new;
    }
    return _dataNodes;
}

- (NSMutableDictionary<NSString*, id>*) property
{
    if(!_property)
    {
        _property = NSMutableDictionary.new;
    }
    return _property;
}

@end
