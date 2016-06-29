//
//  CommonTools.m
//  eclaireMD Diet
//
//  Created by 杨 建峰 on 12-7-13.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CommonTools.h"
#import <CommonCrypto/CommonDigest.h>
#import "ZipArchive.h"
//#import "ViewControllerManager.h"

static char base64EncodingTable[64] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};

static NSObject *_dateSaveFormatterLock;

@implementation CommonTools

+ (NSString *)md5:(NSString*)string {
	
	unsigned char digest[16], i;
	CC_MD5([string UTF8String], (CC_LONG)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
	NSMutableString *ms = [[NSMutableString alloc] init];
	for (i=0; i<16; i++) {
		NSMutableString *x = [[NSMutableString alloc] init];
		[x appendFormat:@"%x", (int)(digest[i])];
		if ([x length] == 2) {
			[ms appendString:x];
		}
		else {
			[ms appendString:@"0"];
			[ms appendString:x];
		}
	}
	return [ms copy];
}

+ (NSString *) base64StringFromData: (NSData *)data length: (NSUInteger)length {
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    
    lentext = [data length];
    if (lentext < 1)
        return @"";
    result = [NSMutableString stringWithCapacity: lentext];
    raw = [data bytes];
    ixtext = 0;
    
    while (true) {
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0)
            break;
        for (i = 0; i < 3; i++) {
            unsigned long ix = ixtext + i;
            if (ix < lentext)
                input[i] = raw[ix];
            else
                input[i] = 0;
        }
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        ctcopy = 4;
        switch (ctremaining) {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for (i = 0; i < ctcopy; i++)
            [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
        
        for (i = ctcopy; i < 4; i++)
            [result appendString: @"="];
        
        ixtext += 3;
        charsonline += 4;
        
        if ((length > 0) && (charsonline >= length))
            charsonline = 0;
    }
    return result;
}

+ (void)clearView:(UIView*)view {
    NSArray *subViews = [view subviews];
    for (UIView *subView in subViews) {
        [subView removeFromSuperview];
    }
}

//+ (void)viewFadeIn:(UIView*)view {
//    @try {
//        if(view != nil && [view isKindOfClass:[UIView class]]) {
//            if (view == [ViewControllerManager scenicDetailViewController].view) {
//                view.alpha = 0;
//                if (view.superview == nil) {
//                    [[ViewControllerManager mainViewController].view addSubview:view];
//                }
//            }
//            [view.superview bringSubviewToFront:view];
//            [UIView beginAnimations:view.description context:nil];
//            [UIView setAnimationDuration:ANIMATE_DURATION_TIME];
//            view.alpha = 1;
//            [UIView commitAnimations];
//        }
//    }
//    @catch (NSException *exception) {
//        
//    }
//    @finally {
//        
//    }
//}

+ (void)viewFadeOut:(UIView*)view {
    @try {
        if(view != nil && [view isKindOfClass:[UIView class]]) {
            [UIView beginAnimations:view.description context:nil];
            [UIView setAnimationDuration:ANIMATE_DURATION_TIME];
            view.alpha = 0;
            [UIView commitAnimations];
        }
        else {
            
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

+ (void)viewFlyinFromRight:(UIView*)view superview:(UIView*)superview {
    @try {
//        NSLog(@"viewFlyinFromRight");
//        view.frame = CGRectMake(screenWidth, 0, screenWidth, screenHeight);
        [superview addSubview:view];
        
        [UIView beginAnimations:view.description context:nil];
        [UIView setAnimationDuration:ANIMATE_DURATION_TIME];
        view.frame = superview.frame;
        [UIView commitAnimations];
    }
    @catch (NSException *exception) {
//        NSLog(@"viewFlyinFromRight exception:%@", exception);
    }
    @finally {
        
    }
}

+ (void)viewFlyinFromLeft:(UIView*)view superview:(UIView*)superview {
    @try {
//        view.frame = CGRectMake(-screenWidth, 0, screenWidth, screenHeight);
        view.alpha = 1;
        [superview addSubview:view];
        
        [UIView beginAnimations:view.description context:nil];
        [UIView setAnimationDuration:ANIMATE_DURATION_TIME];
        view.frame = superview.frame;
        [UIView commitAnimations];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

+ (void)viewFlyinToRight:(UIView*)view superview:(UIView*)superview {
    @try {
        
        [UIView beginAnimations:view.description context:nil];
        [UIView setAnimationDuration:ANIMATE_DURATION_TIME];
//        view.frame = CGRectMake(screenWidth, 0, screenWidth, screenHeight);
        [UIView commitAnimations];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

+ (void)viewFlyinToLeft:(UIView*)view superview:(UIView*)superview {
    @try {
        
        [UIView beginAnimations:view.description context:nil];
        [UIView setAnimationDuration:ANIMATE_DURATION_TIME];
//        view.frame = CGRectMake(-screenWidth, 0, screenWidth, screenHeight);
        [UIView commitAnimations];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

+ (void)downloadAllScenicsData {
    @try {
//        FileTools *fileTools = [FileTools defaultTools];
//        NSString *zipFilePath = [fileTools GetFullFilePathInDocuments:@"scenics.zip"];
        //1. 下载
//        [NetTools download:All_Scenics_URL andSaveTo:zipFilePath];
//        
//        //2. 解压
//        ZipArchive *zip = [[ZipArchive alloc] init];
//        [zip UnzipOpenFile:zipFilePath];
//        [zip UnzipFileTo:[fileTools GetDocumentsPath] overWrite:YES];
//        [zip UnzipCloseFile];
//        
//        //3. 更新时间戳
//        [[ConfigTools defaultTools] putValue:[NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]] forKey:All_Scenics_Time];
//        
//        //4. 删除zip文件
//        [fileTools deleteDir:zipFilePath];
//        
//        [[ViewControllerManager mainViewController] hideLoadingView];        
    }
    @catch (NSException *exception) {
//        NSLog(@"%@", exception);
    }
    @finally {
        
    }
}

+ (void)downloadScenicData:(NSString*)scenicId {
//    FileTools *fileTools = [FileTools defaultTools];
//    NSString *zipFilePath = [fileTools GetFullFilePathInDocuments:[NSString stringWithFormat:@"scenic%@.zip", scenicId]];

//    //1. 下载
//    [NetTools download:[NSString stringWithFormat:One_Scenic_URL, scenicId] andSaveTo:zipFilePath];
//    
//    //2. 解压
//    ZipArchive *zip = [[ZipArchive alloc] init];
//    [zip UnzipOpenFile:zipFilePath];
//    [zip UnzipFileTo:[fileTools GetDocumentsPath] overWrite:YES];
//    [zip UnzipCloseFile];
//    
//    //3. 删除zip文件
//    [fileTools deleteDir:zipFilePath];
}

+ (UIImage*)compressImage:(UIImage*)image {
    int width = image.size.width;
    float scale = 1;
    if (width > 640) {
        scale = 640.0 / width;
        width = 640;
    }
    int height = (int)(image.size.height * scale);
    image = [CommonTools imageWithImage:image scaledToSize:CGSizeMake(width, height)];
    return image;
}

//对图片尺寸进行压缩--
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

+ (UIImage *)loadLocalImage:(NSString *)fileName {
    NSString *path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], fileName];
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    return img;
}

+ (NSDateFormatter*)dateSaveFormatter {
    if (_dateSaveFormatterLock == nil) {
        _dateSaveFormatterLock = [[NSObject alloc] init];
    }
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *dateFormatter = threadDictionary[@"dateSaveFormatter"];
    if(dateFormatter == nil){
        @synchronized(_dateSaveFormatterLock){
            if(!dateFormatter){
                dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                threadDictionary[@"dateSaveFormatter"] = dateFormatter;
            }
        }
    }
    return dateFormatter;
}

+ (BOOL)isValidateString:(NSString *)matchStr pattern:(NSString*)pattern
{
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",pattern];
    return [emailTest evaluateWithObject:matchStr];
}

+ (NSString *)currentAppId {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appId = [infoDictionary objectForKey:@"CFBundleIdentifier"];
    return appId;
}

+ (NSString *)currentVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appBuild = [infoDictionary objectForKey:@"CFBundleVersion"];
    return appBuild;
}
@end
