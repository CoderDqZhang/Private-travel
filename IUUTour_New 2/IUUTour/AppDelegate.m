//
//  Comment by Vincent (vincent@devdiv.com) on Nov 2 2015
//  Initialize a timer to locate user and check if this app is under review by appstore
//  Resume download if this app is killed by user.
//  

#import "AppDelegate.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"
#import "GuideViewController.h"
#import "UMSocialRenrenHandler.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"  
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySetting.h"
#import <AMapNaviKit/AMapNaviKit.h>
#import "UMessage.h"
#import "OfflineMapDownloader.h"

@interface AppDelegate ()
{
    BOOL  isCityDecodingRequied;
}


@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString          *lastCity;


@end

@implementation AppDelegate

#define UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define _IPHONE80_ 80000




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self setRootViewController];
    [MAMapServices sharedServices].apiKey = K_Gao_De_Server_Key;
    [AMapNaviServices sharedServices].apiKey = K_Gao_De_Server_Key;

    
    
    [self configIFlySpeech];
    //设置友盟社会化组件appkey
    [UMSocialData setAppKey:YOUMENG_APP_ID];
     
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:K_WX_APPID appSecret:K_WX_APPKEY url:@"http://www.imyuu.com"];
    
    //打开新浪微博的SSO开关
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"]; 
    
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:K_QQ_ID appKey:K_QQ_KEY url:@"http://www.imyuu.com"];
    //设置支持没有客户端情况下使用SSO授权
    
    [UMSocialQQHandler setSupportWebView:YES];
    
    //打开人人网SSO开关
    [UMSocialRenrenHandler openSSO];
    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ, UMShareToQzone, UMShareToWechatSession, UMShareToWechatTimeline]];
    
    //推送注册
    // IOS8 新系统需要使用新的代码咯
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                             settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                                             categories:nil]];
        
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        //这里还是原来的代码
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)
         ];
    }
    

    [self performSelector:@selector(resumeDownloadFromAccident) withObject:nil afterDelay:3];
    
    
    self.appPublished = NO;
    
    isCityDecodingRequied = YES;
    

    [self getCLLoactionLog];
    
    
    NSTimer *updaterTimer = [NSTimer timerWithTimeInterval:3.0f target:self selector:@selector(updaterTimerCallback:) userInfo:nil repeats:YES];
    
    
    [[NSRunLoop currentRunLoop] addTimer:updaterTimer
                                 forMode:NSDefaultRunLoopMode];
    return YES;
}

- (void)resumeDownloadFromAccident
{
    OfflineMapDownloader *downloader = [OfflineMapDownloader sharedInstance];
    [downloader restoreFromAccident];
}

- (void)updaterTimerCallback:(NSTimer *)paramTimer
{
    __weak __typeof(self)weakSelf = self;
    
    [Interface isPublishedInAppStor:^(AppstoreResponse *response, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
    
        strongSelf.appPublished = response && response.isAppStrore;
    }];
    

    
    [self decodeLocatedCityAndUpdateIfNeeded:nil];
}


#pragma mark - 获取当前所在位置

- (void)getCLLoactionLog
{
    self.locationManager = [[CLLocationManager alloc] init];//创建位置管理器
    self.locationManager.delegate        = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter  = 1000.0f;
    
    if (kDevice_Version_iOS8_Leater)
    {
        //使用期间
        [self.locationManager requestWhenInUseAuthorization];
        //始终
        //or [self.locationManage requestAlwaysAuthorization]
    }
    
    [self.locationManager startUpdatingLocation];
    
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSTimeInterval age = -[newLocation.timestamp timeIntervalSinceNow];
    
    if (age > 120)
    {
        return;    // ignore old (cached) updates
    }
    
    if (newLocation.horizontalAccuracy < 0)
    {
        return;   // ignore invalid udpates
    }

    
    self.userLat = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
    self.userLon = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];

    
    isCityDecodingRequied = YES;
    
    [self decodeLocatedCityAndUpdateIfNeeded:newLocation];
}




- (void)decodeLocatedCityAndUpdateIfNeeded:(CLLocation*)newLocation
{
    if (!isCityDecodingRequied)
    {
        return;
    }
    
    if (!newLocation)
    {
        NSUserDefaults * userDef = [NSUserDefaults standardUserDefaults];
        
        if (!userDef ||
            ![userDef objectForKey:@"userLat"] ||
            ![userDef objectForKey:@"userLon"])
        {
            return;
        }
        
        float latitude  = [[userDef objectForKey:@"userLat"] doubleValue];
        float longitude = [[userDef objectForKey:@"userLon"] doubleValue];
        
        newLocation = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    }
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    
    __weak __typeof(self) weakSelf = self;
    
    __block BOOL found = NO;
    

    [geoCoder reverseGeocodeLocation:newLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       __strong __typeof(weakSelf) strongSelf = weakSelf;
                       
                       if (!strongSelf)
                       {
                           return;
                       }
                       
                       for (CLPlacemark *placemark in placemarks)
                       {
                           NSString *city = [placemark locality];
                           if (!city)
                           {
                               city = [placemark administrativeArea];
                           }
                           
                           if (city)
                           {
                               found = YES;
                           }
                           
                           NSString *lat = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
                           NSString *lon = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
                           
                           [strongSelf handleCityChanged:city latitude:lat longitude:lon];
                       }
                   }];
}

- (void)handleCityChanged:(NSString*)cityName latitude:(NSString*)cityLat longitude:(NSString*)cityLon
{
    if (!isCityDecodingRequied)
    {
        return;
    }
    
    isCityDecodingRequied = NO;
    
    cityName = [cityName stringByReplacingOccurrencesOfString:@"市" withString:@""];
    cityName = [cityName stringByReplacingOccurrencesOfString:@"辖区" withString:@""];
    
    self.locatedCity = [NSString stringWithString:cityName];
}
/**
 *  增加代码
 */

-(void)setRootViewController
{
    MainViewController *mainVC = [[MainViewController alloc] init];
    BaseNavigationController *mainNav = [[BaseNavigationController alloc] initWithRootViewController:mainVC];
    LeftViewController *leftVC = [[LeftViewController alloc] init];
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController containerWithCenterViewController:mainNav leftMenuViewController:leftVC rightMenuViewController:nil];
    GuideViewController *GuideVC = [[GuideViewController alloc] init];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"GUIDE"])
    {
        [self.window setRootViewController:GuideVC];
        [self.window makeKeyAndVisible];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"GUIDE"];
    }
    else
    {
        [self.window setRootViewController:container];
        [self.window makeKeyAndVisible];
        
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, App_Frame_Height)];
        imageV.backgroundColor = [UIColor clearColor];
        imageV.image           = [UIImage imageNamed:@"guide5.png"];
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window addSubview:imageV];
        [self.window makeKeyAndVisible];
        imageV.alpha = 0;
        [UIView animateWithDuration:0.1 animations:^{
            imageV.alpha = 1;
        } completion:^(BOOL finished) {
            
            [self performSelector:@selector(hiddenImageView:) withObject:imageV afterDelay:1.0];
        }];
    }
}
/*
- (void)setRootViewController
{
    _homeController = [[TabBarViewController alloc] init];
    
    GuideViewController *GuideVC = [[GuideViewController alloc] init];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"GUIDE"])
    {
        [self.window setRootViewController:GuideVC];
        [self.window makeKeyAndVisible];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"GUIDE"];
    }
    else
    {
        [self.window setRootViewController:_homeController];
        [self.window makeKeyAndVisible];
        
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, App_Frame_Height)];
        imageV.backgroundColor = [UIColor clearColor];
        imageV.image           = [UIImage imageNamed:@"guide5.png"];
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window addSubview:imageV];
        [self.window makeKeyAndVisible];
        imageV.alpha = 0;
        [UIView animateWithDuration:0.1 animations:^{
            imageV.alpha = 1;
        } completion:^(BOOL finished) {
            
            [self performSelector:@selector(hiddenImageView:) withObject:imageV afterDelay:1.0];
                    }];
    }
}
 */

- (void)configIFlySpeech
{
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@,timeout=%@",@"53c35b10",@"20000"];
    
    [IFlySpeechUtility createUtility:initString];
    
    [IFlySetting setLogFile:LVL_NONE];
    [IFlySetting showLogcat:NO];
    
    // 设置语音合成的参数
    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"50" forKey:[IFlySpeechConstant SPEED]];//合成的语速,取值范围 0~100
    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"50" forKey:[IFlySpeechConstant VOLUME]];//合成的音量;取值范围 0~100
    
    // 发音人,默认为”xiaoyan”;可以设置的参数列表可参考个 性化发音人列表;
    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"xiaoyan" forKey:[IFlySpeechConstant VOICE_NAME]];
    
    // 音频采样率,目前支持的采样率有 16000 和 8000;
    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"8000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    // 当你再不需要保存音频时，请在必要的地方加上这行。
    [[IFlySpeechSynthesizer sharedInstance] setParameter:nil forKey:[IFlySpeechConstant TTS_AUDIO_PATH]];
}

- (void)hiddenImageView:(UIImageView *)imgV
{
    [UIView animateWithDuration:.6 animations:^{
        imgV.alpha = 0;
        imgV.transform = CGAffineTransformMakeScale(1.8, 1.8);
    } completion:^(BOOL finished) {
        [imgV removeFromSuperview];
        
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

+ (AppDelegate *)instance
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _dpapi = [[DPAPI alloc] init];
        _appKey = [[NSUserDefaults standardUserDefaults] valueForKey:@"appkey"];
        if (_appKey.length < 1)
        {
            _appKey = kDPAppKey;
        }
        _appSecret = [[NSUserDefaults standardUserDefaults] valueForKey:@"appsecret"];
        if (_appSecret.length < 1)
        {
            _appSecret = kDPAppSecret;
        }
    }
    return self;
}

- (void)setAppKey:(NSString *)appKey
{
    _appKey = appKey;
    [[NSUserDefaults standardUserDefaults] setValue:appKey forKey:@"appkey"];
}

- (void)setAppSecret:(NSString *)appSecret
{
    _appSecret = appSecret;
    [[NSUserDefaults standardUserDefaults] setValue:appSecret forKey:@"appsecret"];
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url];
}


-(NSString *)stringWithDeviceToken:(NSData *)deviceToken
{
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];
    
    for (int i = 0; i < [deviceToken length]; i++)
    {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    
    return [token copy];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *pushToken = [self stringWithDeviceToken:deviceToken];

    NSString *localPushToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"pushToken"];
    if(localPushToken==nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:pushToken forKey:@"pushToken"];
    }
    
    [Interface sendPushToken:pushToken recv_msg:@"1" result:^(CommonActionStatus *response, NSError *error) {
    }];
}


- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
}



- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
        NSString *msg = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:userInfo[@"title"] message:msg delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"立即查看",nil];
        [alert show];
 
}

@end
