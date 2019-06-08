//
//  Drawable.h
//  ALayout
//
//  Created by splendourbell on 2017/5/3.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttributeReader.h"

@interface Drawable : NSObject

@property (nonatomic) CGRect bounds;

@property (nonatomic) CGFloat alpha;

@property (nonatomic) BOOL visible;

@property (nonatomic) CGFloat intrinsicWidth;

@property (nonatomic) CGFloat intrinsicHeight;

@property (nonatomic) CGFloat minimumWidth;

@property (nonatomic) CGFloat minimumHeight;

- (void)parseAttr:(nonnull AttributeReader*)attrReader;

- (void)attachBackground:(nonnull CALayer*)layer stateView:(nullable UIView*)control;

- (void)attachUIColor:(nonnull id)view forKey:(nonnull NSString*)colorKey stateView:(nullable UIView*)control;

- (void)detach:(nullable UIView*)stateView;

- (void)reset:(nullable UIView*)stateView;

/**
 * Returns the minimum height suggested by this Drawable. If a View uses this
 * Drawable as a background, it is suggested that the View use at least this
 * value for its height. (There will be some scenarios where this will not be
 * possible.) This value should INCLUDE any padding.
 *
 * @return The minimum height suggested by this Drawable. If this Drawable
 *         doesn't have a suggested minimum height, 0 is returned.
 */

//public boolean setState(@NonNull final int[] stateSet) {
//    if (!Arrays.equals(mStateSet, stateSet)) {
//        mStateSet = stateSet;
//        return onStateChange(stateSet);
//    }
//    return false;
//}

@end
