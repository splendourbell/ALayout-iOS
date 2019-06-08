//
//  UIView+DataBinder.h
//  ALayout
//
//  Created by splendourbell on 2017/6/1.
//  Copyright © 2017年 com.aiospace.zone. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DataBinderProtocol <NSObject>

- (NSDictionary*)generateBindData:(NSDictionary*)data dataBinder:(NSString*)dataBinder forHeight:(BOOL)forHeight;

@end

@interface UIView(AutoBindData)

- (void)autoBindDataForHeight:(NSDictionary*)data;

- (void)autoBindData:(NSDictionary*)data;

- (void)autoBindSelf:(NSDictionary*)properties;

- (void)scriptBindData:(NSDictionary*)data binder:(id<DataBinderProtocol>)dataBinder;

- (void)scriptBindData:(NSDictionary*)data binder:(id<DataBinderProtocol>)dataBinder forHeight:(BOOL)forHeight;

@end
