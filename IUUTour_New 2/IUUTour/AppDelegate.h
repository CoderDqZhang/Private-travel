#import <UIKit/UIKit.h>
#import "TabBarViewController.h"
#import <AMapNaviKit/>
#import "DPAPI.h"
#import "WXApi.h"

/**
 *  增加代码
 */
#import "MainViewController.h"
#import "LeftViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "BaseNavigationController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate,UINavigationControllerDelegate,WXApiDelegate,CLLocationManagerDelegate>
{
   
}

@property (strong, nonatomic  ) UIWindow       *window;
@property (strong, nonatomic  ) MAMapView      *mapView;
@property (strong, nonatomic  ) TabBarViewController *homeController;
@property (readonly, nonatomic) DPAPI          *dpapi;
@property (strong, nonatomic  ) NSString       *appKey;
@property (strong, nonatomic  ) NSString       *appSecret;

@property (strong, nonatomic  ) NSString       *wxaccess_token;
@property (strong, nonatomic  ) NSString       *wxopenid;


@property (nonatomic) BOOL                      appPublished;
@property (nonatomic, copy) NSString            *locatedCity;
@property (nonatomic, copy) NSString            *userLat;
@property (nonatomic, copy) NSString            *userLon;


+ (AppDelegate *)instance;
- (void)setRootViewController;


@end

