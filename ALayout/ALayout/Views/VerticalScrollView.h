//
//  VerticalScrollView.h
//  ALayout
//
//  Created by Peak.Liu on 2017/6/21.
//  Copyright © 2017年 com.aiospace.zone. All rights reserved.
//

#import <ALayout/ALayout.h>

@interface VerticalScrollView : FlowLayout

@property(nonatomic)         UIEdgeInsets                 contentInset;
@property(nonatomic,getter=isDirectionalLockEnabled) BOOL directionalLockEnabled;
@property(nonatomic)         BOOL                         bounces;
@property(nonatomic)         BOOL                         alwaysBounceVertical;
@property(nonatomic,getter=isPagingEnabled) BOOL          pagingEnabled __TVOS_PROHIBITED;
@property(nonatomic,getter=isScrollEnabled) BOOL          scrollEnabled;
@property(nonatomic)         BOOL                         showsVerticalScrollIndicator;

@end
