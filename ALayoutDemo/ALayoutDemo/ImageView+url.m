//
//  ImageView+url.m
//  ALayoutDemo
//
//  Created by bell on 2019/6/7.
//  Copyright © 2019 Splendour Bell. All rights reserved.
//

#import "ImageView+url.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonCrypto.h>

static const void* _DownLoadKey = &_DownLoadKey;

#warning 此文件为测试文件
#warning 通常是通过扩展 SDWebImage 来实现图片请求

static dispatch_queue_t _ImageFileReadQueue;
@implementation ImageView(url)

+ (void)load
{
    RegisterViewParsePropertyByClass(self, ^(ImageView *view, AttributeReader *attrReader, BOOL useDefault) {
        [view extParseAttr:attrReader useDefault:useDefault];
    });
    _ImageFileReadQueue = dispatch_queue_create("ALayout.ImageFileReadQueue", DISPATCH_QUEUE_SERIAL);
}

- (void)extParseAttr:(AttributeReader*)attrReader useDefault:(BOOL)useDefault
{
    if(!attrReader[@"src"] && (attrReader[@"url"] || !useDefault))
    {
        if(0 == [attrReader[@"url"] length])
        {
            self.image = nil;
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setUrl:attrReader[@"url"]];
            });
        }
    }
}

- (void)autoBindSelf:(NSDictionary*)properties
{
    if(properties[@"src"])
    {
        [self cancelCurrentImageLoad];
    }
    [super autoBindSelf:properties];
}

- (void)setUrl:(NSString*)urlString
{
    NSURL* url = [NSURL URLWithString:urlString];
    [self downloadImage:url imageFetched:^(UIImage *image) {
        self.image = image;
    }];
}

- (void)downloadImage:(NSURL*)url imageFetched:(void (^)(UIImage* image))imageFetched
{
    [self cancelCurrentImageLoad];
    NSString* urlString = url.absoluteString;
    if(!urlString.length)
    {
        self.image = nil;
        return;
    }
    
    dispatch_async(_ImageFileReadQueue, ^{
        
        NSString * cachePath = [self saveImageFileUrl];
        NSString* pathName = [self md5:urlString];
        pathName = [cachePath stringByAppendingPathComponent:pathName];
        UIImage* image = [UIImage imageWithContentsOfFile:pathName];
        if(image)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                imageFetched(image);
            });
        }
        else
        {
            NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
            NSURLSession * session = [NSURLSession sharedSession];
            NSURLSessionDownloadTask * downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSString * locationPath = [location.absoluteString substringFromIndex:7];
                if (!error)
                {
                    NSString * savePath = pathName;
                    NSURL * saveUrl = [NSURL fileURLWithPath:savePath];
                    UIImage* image = [UIImage imageWithContentsOfFile:locationPath];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageFetched(image);
                    });
                    [[NSFileManager defaultManager] moveItemAtURL:location toURL:saveUrl error:nil];
                }
            }];
            [downloadTask resume];
        }
    });
}

-(NSString *)saveImageFileUrl
{
    NSString * imageUrl = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/images"];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageUrl])
    {
        [fileManager createDirectoryAtPath:imageUrl withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return imageUrl;
}

- (void)setDownloadTask:(NSURLSessionDownloadTask*)downloadTask
{
    [self cancelCurrentImageLoad];
    objc_setAssociatedObject(self, _DownLoadKey, downloadTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cancelCurrentImageLoad
{
    NSURLSessionDownloadTask * downloadTask = objc_getAssociatedObject(self, _DownLoadKey);
    [downloadTask cancel];
    objc_setAssociatedObject(self, _DownLoadKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable NSString *)md5:(nullable NSString *)str
{
    if (!str) return nil;
    const char *cStr = str.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    NSMutableString *md5Str = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [md5Str appendFormat:@"%02x", result[i]];
    }
    return md5Str;
}


@end
