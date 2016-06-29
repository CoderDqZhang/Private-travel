//
//  OfflineTileOverlay.m
//  CustomMap
//
//  Created by Carlo Vigiani on 19/Jan/14.
//  Copyright (c) 2014 viggiosoft. All rights reserved.
//

#import "GridTileOverlay.h"

@interface SDImageCache (PrivateMethods)
- (NSString *)defaultCachePathForKey:(NSString *)key;
- (NSString *)cachedFileNameForKey:(NSString *)key;

@end

@interface GridTileOverlay ()
@property NSCache *cache;

@end

@implementation GridTileOverlay

//  Query for each GridTileOverlay
- (void)loadTileAtPath:(MATileOverlayPath)path result:(void (^)(NSData *tileData, NSError *error))result
{
    NSString * pathImage = [self.URLTemplate stringByReplacingOccurrencesOfString:@"{z}/{x}/{y}" withString:[NSString stringWithFormat:@"%ld/%ld/%ld",(long)path.z,(long)path.x,(long)path.y]];
  
    
    NSData *tileData = nil;
    
//    //  Check if it's asking images from server
    if (pathImage && [pathImage rangeOfString:@"http" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        NSURL *url = [NSURL URLWithString:pathImage];
        BOOL exist = [[SDWebImageManager sharedManager] diskImageExistsForURL:url];
        
        if (!exist)
        {
            [[SDWebImageManager sharedManager]downloadImageWithURL:url options:SDWebImageProgressiveDownload | SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                
            }];
//           [[SDWebImageManager sharedManager]downloadWithURL:url
//        options:SDWebImageProgressiveDownload | SDWebImageRetryFailed progress:^(NSUInteger receivedSize, long long expectedSize) {
//        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
//        }];
            
            //  remote image
            tileData = [NSData dataWithContentsOfURL:url];
        }
        else
        {
            SDImageCache *imageCache = [SDImageCache sharedImageCache];
            //UIImage *image = [imageCache imageFromMemoryCacheForKey:pathImage];
            NSString *localPath = [imageCache defaultCachePathForKey:pathImage];
            
            //  local image
            //tileData = UIImagePNGRepresentation(image);
            tileData = [NSData dataWithContentsOfFile:localPath];
        }
    }
    else//on disk
    {
        //  local image
        tileData = [NSData dataWithContentsOfFile:pathImage];
    }
    
    NSError *error = nil;

    if (tileData == nil)
    {
        error = [NSError errorWithDomain:@"MATileLoadErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"load tile data error"}];
    }
    
    
    result(tileData,error);
}

@end
