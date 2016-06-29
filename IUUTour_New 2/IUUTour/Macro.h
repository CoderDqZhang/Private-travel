#ifndef IUUTour_Macro_h
#define IUUTour_Macro_h




#define kDevice_Version_iOS8_Leater [[[UIDevice currentDevice] systemVersion] floatValue]>=8.0

//  Comment by Vincent
//  The developer of App_Frame_Height's definition does NOT realize the difference between applicationFrame and mainScreen's bounds.
//  If you'd like to fill the whole screen, do not use App_Frame_Height.
//  This app uses it heavily, so it's dangerous to change it and I add APP_Screen_Height
#define App_Frame_Height [[UIScreen mainScreen] bounds].size.height
//#define App_Frame_Height        [[UIScreen mainScreen] applicationFrame].size.height
#define App_Frame_Width         [[UIScreen mainScreen] applicationFrame].size.width

#define APP_Screen_Height       [[UIScreen mainScreen] bounds].size.height

#define  AnimationDurationTime .46f //动画的迟续 时间


#if __IPHONE_7_0 && __IPHONE_OS_VERSION_MAX_ALLOWED >=  __IPHONE_7_0
#define IS_RUNNING_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#else
#define IS_RUNNING_IOS7 NO
#endif

#import "NSString+UIColor.h"

#define LeftBackColor           @"#2b3539".color
#define NavigationColor         @"#202023".color
#define CollectionCellFont      @"#E8AB1C".color
#define CollectionCellFont1     @"#ADADAD".color
#define PerSonBgColor           @"#28282c".color



#define FontColorA              @"#178CC7".color
#define FontColorB              @"#8E8C90".color

#define ButtonColorA            @"#40CE6A".color  //绿色
#define ButtonColorB            @"#1C8CC9".color
#define ButtonColorC            @"#29C450".color
#define ButtonColorD            @"#178CC7".color
#define ButtonColorE            @"#178CC7".color

#define appKey1 @"9699551594"
#define appSecret1 @"f2acc603b7d248b7b0521023496a0a1a"
// IOS7
__attribute__((unused)) static BOOL IsOSVersionAtLeastiOS7()
{
    return (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1);
}

// iPhone5
__attribute__((unused)) static BOOL IsOSiPhone5()
{
    return (floor(App_Frame_Height)) == 568.f;
}
//b5a86bb44abea9352e9a38c922412585
//#define K_Gao_De_Server_Key @"f1537a88bad4e09ac09b51bd83de37d1"   //正式服务器
//#define K_Gao_De_Server_Key @"a1f41028339c4ddfa0a058b5b5b16c3d"     //测试包
#define K_Gao_De_Server_Key @"06fcd188511c5c262dc858b4ae731c01" 



//友盟分享＋登录
#define YOUMENG_APP_ID                  @"55068164fd98c54b0f0005db"             //友盟统计
#define K_SINA_APP_KEY                  @"2019934407"                           // 新浪AppKey
#define K_SINA_APP_SECRE                @"6860a451a1a2b4f7731b955e9273c93f"     // 新浪Secret

#define K_QQ_ID                         @"1104261190"                           // QQ ID
#define K_QQ_KEY                        @"zR27KSvTwEjQp6jZ"                     // QQ key

#define K_WX_APPID                      @"wx7039733184c8596f"
#define K_WX_APPKEY                     @"e966541c3fe2f59864918573e6c87a2d"
#define K_DESCRIPTION                   @"0628"

#import "Tools.h"

#define Relative_Longitude           @"relativeLongitude"
#define Relative_Latitude            @"relativeLatitude"
#define Relative_Width               @"relativeWidth"
#define Relative_Height              @"relativeHeight"
#define Recommend_Line_Section_Guide @"recommendLinesectionguide"
#define Scenic_Advertise_URL         @"http://www.imyuu.com/trip/oneScenicAdvertScenicAreaAction.action?scenicId=%@"
#define AD_Pic                       @"advertPic"
#define AD_Scenic_Id                 @"advertscenicId"
//景区信息用到的字段
#define ID                           @"id"
#define Scenic_Id                    @"scenicId"
#define Scenic_Name                  @"scenicName"
#define Scenic_Note                  @"scenicNote"
#define Scenic_Small_Pic             @"scenicSmallpic"
#define Scenic_Search_Small_Pic      @"scenicSearchsmallpic"
#define Scenic_Map_Max_X             @"scenicmapMaxx"
#define Scenic_Map_Max_Y             @"scenicmapMaxy"
#define Scenic_Package_Size          @"scenicPackagesize"
#define Is_Test                      @"isTest"

#define Scenic_Map                   @"scenicMap"
#define Scenic_Map_Url               @"scenicMapurl"

#define Scenic_Recommend_Line        @"scenicRecommendLine"
#define Recommend_Route_Name         @"recommendRoutename"
#define Route_Total_Time             @"routeTotaltime"
#define A_Spot_Id                    @"aspotId"
#define B_Spot_Id                    @"bspotId"

#define Scenic_Spot_Name             @"scenicspotName"
#define Scenic_Spot_Voice            @"scenicspotVoice"
#endif
