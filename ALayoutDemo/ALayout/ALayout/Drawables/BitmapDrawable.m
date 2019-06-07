//
//  BitmapDrawable.m
//  ALayout
//
//  Created by splendourbell on 2017/5/3.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "BitmapDrawable.h"

@implementation BitmapDrawable
{
    CGSize _imageSize;
    ResourceManager* _resourceManager;
}

- (void)parseAttr:(AttributeReader *)attrReader
{
    [super parseAttr:attrReader];
    _resourceManager = attrReader.resourceManager;
    _antialias = ATTR_ReadAttr(A_antialias, BOOL, NO);
    
    [self setSrc:ATTR_ReadAttr(A_src, NSString, nil)];
    NSString* tileMode = ATTR_ReadAttr(A_tileMode, NSString, nil);
    if(StrEq(@"clamp", tileMode))
    {
        _tileMode = TILE_MODE_CLAMP;
    }
    else if(StrEq(@"mirror", tileMode))
    {
        _tileMode = TILE_MODE_MIRROR;
    }
    else if(StrEq(@"repeat", tileMode))
    {
        _tileMode = TILE_MODE_REPEAT;
    }
    else //if(StrEq(@"disabled", tileMode))
    {
        _tileMode = TILE_MODE_DISABLED;
    }
    
//    _resourceManager = attrReader.resourceManager;
//    
//    ATTR_ReadAttrEq(_antialias, A_antialias, BOOL, NO);
//    ATTR_ReadAttrEq(self.src, A_src, NSString, nil);
//    
//    if (ATTR_CanRead(A_tileMode))
//    {
//        NSString* tileMode = ATTR_ReadAttr(A_tileMode, NSString, nil);
//        if(StrEq(@"clamp", tileMode))
//        {
//            _tileMode = TILE_MODE_CLAMP;
//        }
//        else if(StrEq(@"mirror", tileMode))
//        {
//            _tileMode = TILE_MODE_MIRROR;
//        }
//        else if(StrEq(@"repeat", tileMode))
//        {
//            _tileMode = TILE_MODE_REPEAT;
//        }
//        else //if(StrEq(@"disabled", tileMode))
//        {
//            _tileMode = TILE_MODE_DISABLED;
//        }
//    }
    
}

- (ResourceManager*)resourceManager
{
    return _resourceManager ?: [ResourceManager defualtResourceManager];
}

- (void)setSrc:(NSString*)src
{
    ResourceInfo* info = [self.resourceManager resourceInfo:src];
    if(ResourceValueImage == info.resourceType)
    {
        self.image = [UIImage imageWithContentsOfFile:info.value];
    }
    else
    {
        self.image = nil;
    }
}

- (void)computeImageSize
{
    if (_image)
    {
        _imageSize = _image.size;
    }
    else
    {
        _imageSize = CGSizeZero;
    }
}

- (void)setImage:(UIImage *)image
{
    if(image != _image)
    {
        _image = image;
        [self computeImageSize];
    }
}

- (void)attachBackground:(CALayer*)layer stateView:(UIView*)stateView
{
    if(layer.allowsEdgeAntialiasing != _antialias)
    {
        layer.allowsEdgeAntialiasing = _antialias;
    }
    
    if(_image)
    {
        switch (_tileMode)
        {
            case TILE_MODE_REPEAT:
            {
                UIImage *imgTmp = [UIImage imageWithCGImage:[_image CGImage] scale:[_image scale] orientation:UIImageOrientationDown];
                layer.backgroundColor = [UIColor colorWithPatternImage:imgTmp].CGColor;
            }
                break;
            
            
            case TILE_MODE_DISABLED:
            {
                layer.contents = (id)_image.CGImage;
            }
            break;
            
            case TILE_MODE_MIRROR:
            case TILE_MODE_CLAMP:
                //TODO:
                NSLog(@"TILE_MODE_MIRROR or TILE_MODE_CLAMP not supported");
            
            case TILE_MODE_UNDEFINED:
            {
                layer.contents = (id)_image.CGImage;
            }
            break;

          default:
            break;
        }
    }
    else
    {
        layer.backgroundColor = nil;
    }
}

- (void)attachUIColor:(id)hostView forKey:(NSString*)colorKey stateView:(UIView*)stateView
{
    if(_image)
    {
        UIColor* color = [UIColor colorWithPatternImage:_image];
        [hostView setValue:color forKey:colorKey];
    }
    else
    {
        [hostView setValue:nil forKey:colorKey];
    }
}

//android:dither	Enables or disables dithering of the bitmap if the bitmap does not have the same pixel configuration as the screen (for instance: a ARGB 8888 bitmap with an RGB 565 screen).
//android:filter	Enables or disables bitmap filtering.
//android:gravity	Defines the gravity for the bitmap.
//android:mipMap	Enables or disables the mipmap hint.


//android:tileModeX	Defines the horizontal tile mode.
//android:tileModeY	Defines the vertical tile mode.

@end
