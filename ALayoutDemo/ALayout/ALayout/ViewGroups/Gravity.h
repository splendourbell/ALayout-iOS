//
//  Gravity.h
//  RMLayout
//
//  Created by splendourbell on 2017/4/7.
//  Copyright © 2017年 ajja.sdjkf.sd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayoutDirection.h"

typedef UIEdgeInsets UIEdgeBounds;

typedef NS_ENUM(int, GravityMode)
{
    /** Constant indicating that no gravity has been set **/
    Gravity_NO_GRAVITY = 0x0000,
    
    /** Raw bit indicating the gravity for an axis has been specified. */
    Gravity_AXIS_SPECIFIED = 0x0001,
    
    /** Raw bit controlling how the left/top edge is placed. */
    Gravity_AXIS_PULL_BEFORE = 0x0002,
    /** Raw bit controlling how the right/bottom edge is placed. */
    Gravity_AXIS_PULL_AFTER = 0x0004,
    /** Raw bit controlling whether the right/bottom edge is clipped to its
     * container, based on the gravity direction being applied. */
    Gravity_AXIS_CLIP = 0x0008,

    /** Bits defining the horizontal axis. */
    Gravity_AXIS_X_SHIFT = 0,
    /** Bits defining the vertical axis. */
    Gravity_AXIS_Y_SHIFT = 4,
    
    /** Push object to the top of its container, not changing its size. */
    Gravity_TOP = (Gravity_AXIS_PULL_BEFORE|Gravity_AXIS_SPECIFIED)<<Gravity_AXIS_Y_SHIFT,
    /** Push object to the bottom of its container, not changing its size. */
    Gravity_BOTTOM = (Gravity_AXIS_PULL_AFTER|Gravity_AXIS_SPECIFIED)<<Gravity_AXIS_Y_SHIFT,
    /** Push object to the left of its container, not changing its size. */
    Gravity_LEFT = (Gravity_AXIS_PULL_BEFORE|Gravity_AXIS_SPECIFIED)<<Gravity_AXIS_X_SHIFT,
    /** Push object to the right of its container, not changing its size. */
    Gravity_RIGHT = (Gravity_AXIS_PULL_AFTER|Gravity_AXIS_SPECIFIED)<<Gravity_AXIS_X_SHIFT,
    
    /** Place object in the vertical center of its container, not changing its
     *  size. */
    Gravity_CENTER_VERTICAL = Gravity_AXIS_SPECIFIED<<Gravity_AXIS_Y_SHIFT,
    /** Grow the vertical size of the object if needed so it completely fills
     *  its container. */
    Gravity_FILL_VERTICAL = Gravity_TOP|Gravity_BOTTOM,
    
    /** Place object in the horizontal center of its container, not changing its
     *  size. */
    Gravity_CENTER_HORIZONTAL = Gravity_AXIS_SPECIFIED<<Gravity_AXIS_X_SHIFT,
    /** Grow the horizontal size of the object if needed so it completely fills
     *  its container. */
    Gravity_FILL_HORIZONTAL = Gravity_LEFT|Gravity_RIGHT,
    
    /** Place the object in the center of its container in both the vertical
     *  and horizontal axis, not changing its size. */
    Gravity_CENTER = Gravity_CENTER_VERTICAL|Gravity_CENTER_HORIZONTAL,
    
    /** Grow the horizontal and vertical size of the object if needed so it
     *  completely fills its container. */
    Gravity_FILL = Gravity_FILL_VERTICAL|Gravity_FILL_HORIZONTAL,
    
    /** Flag to clip the edges of the object to its container along the
     *  vertical axis. */
    Gravity_CLIP_VERTICAL = Gravity_AXIS_CLIP<<Gravity_AXIS_Y_SHIFT,
    
    /** Flag to clip the edges of the object to its container along the
     *  horizontal axis. */
    Gravity_CLIP_HORIZONTAL = Gravity_AXIS_CLIP<<Gravity_AXIS_X_SHIFT,
    
    /** Raw bit controlling whether the layout direction is relative or not (START/END instead of
     * absolute LEFT/RIGHT).
     */
    Gravity_RELATIVE_LAYOUT_DIRECTION = 0x00800000,
    
    /**
     * Binary mask to get the absolute horizontal gravity of a gravity.
     */
    Gravity_HORIZONTAL_GRAVITY_MASK = (Gravity_AXIS_SPECIFIED |
                                                       Gravity_AXIS_PULL_BEFORE | Gravity_AXIS_PULL_AFTER) << Gravity_AXIS_X_SHIFT,
    /**
     * Binary mask to get the vertical gravity of a gravity.
     */
    Gravity_VERTICAL_GRAVITY_MASK = (Gravity_AXIS_SPECIFIED |
                                                     Gravity_AXIS_PULL_BEFORE | Gravity_AXIS_PULL_AFTER) << Gravity_AXIS_Y_SHIFT,
    
    /** Special constant to enable clipping to an overall display along the
     *  vertical dimension.  This is not applied by default by
     *  {@link #apply(int, int, int, Rect, int, int, Rect)}; you must do so
     *  yourself by calling {@link #applyDisplay}.
     */
    Gravity_DISPLAY_CLIP_VERTICAL = 0x10000000,
    
    /** Special constant to enable clipping to an overall display along the
     *  horizontal dimension.  This is not applied by default by
     *  {@link #apply(int, int, int, Rect, int, int, Rect)}; you must do so
     *  yourself by calling {@link #applyDisplay}.
     */
    Gravity_DISPLAY_CLIP_HORIZONTAL = 0x01000000,
    
    /** Push object to x-axis position at the start of its container, not changing its size. */
    Gravity_START = Gravity_RELATIVE_LAYOUT_DIRECTION | Gravity_LEFT,
    
    /** Push object to x-axis position at the end of its container, not changing its size. */
    Gravity_END = Gravity_RELATIVE_LAYOUT_DIRECTION | Gravity_RIGHT,
    
    /**
     * Binary mask for the horizontal gravity and script specific direction bit.
     */
    Gravity_RELATIVE_HORIZONTAL_GRAVITY_MASK = Gravity_START | Gravity_END
    
};

@interface Gravity : NSObject

+ (UIEdgeBounds)apply:(GravityMode)gravity w:(CGFloat)w h:(CGFloat)h container:(const UIEdgeBounds)container layoutDirection:(LayoutDirectionMode)layoutDirection;

+ (GravityMode)absoluteGravity:(GravityMode)gravity layoutDirection:(LayoutDirectionMode)layoutDirection;

@end



