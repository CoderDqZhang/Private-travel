//
//  CommonTools.h
//  eclaireMD Diet
//
//  Created by 杨 建峰 on 12-7-13.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
//#import "Params.h"
#import "FileTools.h"
#import "NetTools.h"
//#import "ConfigTools.h"
//#import "UIToast.h"

#define RGB(a, b, c) [UIColor colorWithRed:(a / 255.0f) green:(b / 255.0f) blue:(c / 255.0f) alpha:1.0f]
#define RGBA(a, b, c, d) [UIColor colorWithRed:(a / 255.0f) green:(b / 255.0f) blue:(c / 255.0f) alpha:d]

#define Text_Dark_Blue_Color RGB(5, 105, 200)
#define Text_Dark_Gray_Color RGB(89, 87, 87)

#define ANIMATE_DURATION_TIME 0.3f

#define Default_Keyboard_Height 216

#define TimeInterval_365Days 31536000//365天的秒数
#define TimeInterval_90Days 7776000//90天的秒数
#define TimeInterval_21Days 1814400//21天的秒数
#define TimeInterval_14Days 1209600//21天的秒数
#define TimeInterval_7Days 604800//21天的秒数
#define TimeInterval_1Day 86400//1天的秒数

#define TimeInterval_1Hour 3600//1天的秒数

#define CACHE_TIME_INTERVAL 86400

#define Icon_Columns 3
#define Icon_Label_Height 28

//int screenWidth;
//int screenHeight;

//BOOL appStoreVersion;

//float Check_Update_Duration;
//
//float Icon_Width;
//float Icon_Height;
//float Column_Space;

@interface CommonTools : NSObject {
}

+ (NSString *)md5:(NSString*)string;
+ (NSString *) base64StringFromData: (NSData *)data length:(NSUInteger)length;

+ (void)clearView:(UIView*)view;

//+ (void)viewFadeIn:(UIView*)view;
+ (void)viewFadeOut:(UIView*)view;

+ (void)viewFlyinFromRight:(UIView*)view superview:(UIView*)superview;
+ (void)viewFlyinFromLeft:(UIView*)view superview:(UIView*)superview;

+ (void)viewFlyinToRight:(UIView*)view superview:(UIView*)superview;
+ (void)viewFlyinToLeft:(UIView*)view superview:(UIView*)superview;

+ (void)downloadAllScenicsData;
+ (void)downloadScenicData:(NSString*)scenicId;

+ (UIImage*)compressImage:(UIImage*)image;
+ (UIImage*)loadLocalImage:(NSString*)fileName;

+ (NSDateFormatter*)dateSaveFormatter;

+ (BOOL)isValidateString:(NSString *)matchStr pattern:(NSString*)pattern;

+ (NSString *)currentAppId;
+ (NSString *)currentVersion;
@end
