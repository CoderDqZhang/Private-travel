#import "MapNaviViewController.h"
//#import <MAMapKit/MAMapKit.h>
#import <AMapNaviKit/AMapNaviKit.h>

#import "MapCusAnnotationView.h"
#import "TracingPoint.h"
#import "Util.h"
#define kCalloutViewMargin          -8
#import <AVFoundation/AVFoundation.h>
#import "DetailViewController.h"
#import "NavPointAnnotation.h"
#import "GridTileOverlay.h"
#import "DownResource.h"
#import "KMTileOverlay.h"
#import "AlarmViewController.h"

@interface MapNaviViewController ()<MAMapViewDelegate,AVAudioPlayerDelegate,AMapNaviViewControllerDelegate,UIScrollViewDelegate,AMapNaviManagerDelegate,IFlySpeechSynthesizerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    BOOL                 isShowingRouteTypeSelctionPopup;//是否显示线路
    
    MAPointAnnotation    * _destinationPoint;//插点
    MAPointAnnotation    * iuu_point;//行走的小人
    MAPointAnnotation    * servicePoint;//iuu助手服务点
    //    MAUserLocation * userLocation;//当前位置信息
    NSMutableArray       * tourArray;//畅游
    NSMutableArray       * classicArray;//经典
    NSMutableArray       * result;//获取数据结果
    NSMutableArray       * _tracking;
    NSMutableArray       * hotBtn;//按钮数组
    NSMutableArray       *connectingLines;
    
    UIScrollView         * routeLinePopup;//路线滚动选择

    UIView               *bottomBar;//底部工具栏
    UIView               *routeTypeSelectionPopup;//经典/畅游路线选择列表popup
    UIView               *iuuAssistPopup;//iuu助手 popup
    UIView               *iuuAssistSubPopup;//iuu助手二级popup
    MAPolyline           *commonPolyline;
    NSString             *lastVoice;//记录上一次点击的是哪个语音

    BOOL                 isTourOrClass;//判断是经典路线还是畅游路线
    
    UIView               *settingPopup;//用来设置定位、自动语音开关
    BOOL                 isShowingAssistPopup;//是否出现iuu助手
    
    BOOL                 isShowingSettingPopup;
    
    BOOL                 manuallyChangingMapRect;
    
    BOOL                 isFirstTimeUserLocated;
    
    MAUserLocation       *lastUserLocation;
    
    BOOL           isNetwork;//判断是从网络获取数据还是本地
    CGFloat        lat;
    CGFloat        lon;
    
    NSMutableArray *adImgs;
    NSMutableArray *adDatas;
    UIImageView    *adImgView;
    UIButton       *adBtn;
    UIButton       *adCloseBtn;
    NSTimer        *adTimer;
    NSInteger      adIndex;

    NSMutableArray *selectArr;
}

@property (nonatomic,strong) MAMapView              *mapView;
@property (nonatomic,strong) NSMutableArray         *annotations;
@property (nonatomic,retain) NSData                 * mydata;
@property (nonatomic,retain) AVAudioPlayer          * player;
@property (nonatomic,strong) AMapNaviViewController *naviViewController;
//@property(nonatomic,retain)GridTileOverlay * gridTile;
@property (nonatomic,strong) AMapNaviPoint          * startPoint;
@property (nonatomic,strong) AMapNaviPoint          * endPoint;
@property (nonatomic,strong) MACircle               *circle;

@property (nonatomic,strong) NSMutableArray         *overlayArray;//自定义图层
@end

@implementation MapNaviViewController


- (void)initIFlySpeech
{
    _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    _iFlySpeechSynthesizer.delegate = self;
}

- (void)mapBackPress
{
//    NSLog(@"%@",self.mapView.overlays);
    [self.mapView removeAnnotations:self.mapView.annotations];
//    [self.mapView removeAnnotation:iuu_point];
    [self.mapView removeOverlays:self.mapView.overlays];
    //[self.mapView removeFromSuperview];
    self.mapView.delegate = nil;
    //self.mapView = nil;
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"showRoutePopupAndDrawRouteLineOnMapAction" object:@"1"];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
}


- (void)initAlarmButton:(UIButton*)alarmButton onPosition:(CGRect)position withWarningType:(NSString*)warning
{
    [alarmButton setFrame:position];
    [alarmButton setBackgroundColor:[UIColor clearColor]];
    
    
    [alarmButton setContentMode:UIViewContentModeCenter];
    
    NSString *levelNumber = [[warning stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    int warningLevel = [levelNumber intValue];
    switch (warningLevel)
    {
        case 2:
            [alarmButton setImage:[UIImage imageNamed:@"type_blue"] forState:UIControlStateNormal];
            
            break;
            
        case 3:
            [alarmButton setImage:[UIImage imageNamed:@"type_orange"] forState:UIControlStateNormal];
            
            break;
            
        case 4:
            [alarmButton setImage:[UIImage imageNamed:@"type_yellow"] forState:UIControlStateNormal];
            
            break;
            
        case 5:
            [alarmButton setImage:[UIImage imageNamed:@"type_red"] forState:UIControlStateNormal];
            
            break;
            
        default:
            [alarmButton setImage:[UIImage imageNamed:@"type_green"] forState:UIControlStateNormal];
            
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isFirstTimeUserLocated = YES;
    
    lastUserLocation = nil;
    
    self.naviViewController = nil;
    
    // Do any additional setup after loading the view.
    self.annotations      = [NSMutableArray array];
    self.titleLabel.text  = self.data.scenicName;
    self.titleView.hidden = NO;
    isNetwork = YES;
//    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [backBtn setFrame:CGRectMake(0.0f, 2.0f, 50.0f, 40.0f)];
//    [backBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
//    [backBtn addTarget:self action:@selector(mapBackPress) forControlEvents:UIControlEventTouchUpInside];
//    [self.titleView addSubview:backBtn];
    
    [self initAdditional];
}

- (void)initAdditional
{
    [self initMap];
    
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    if ([[def objectForKey:self.data.scenicId] isEqualToString:@"有"])
    {
        [self showOfflineMap];
    }
    else
    {
        [self showOnlineMap];
    }
    

    float settingBtnSize = 30;
    UIButton *settingBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [settingBtn setFrame:CGRectMake(_defaultView.width - settingBtnSize - 10, self.titleView.bottom + 10, settingBtnSize, settingBtnSize)];
    [settingBtn setBackgroundColor:[UIColor clearColor]];
    [settingBtn setContentMode:UIViewContentModeCenter];
    [settingBtn setImage:[UIImage imageNamed:@"radar"] forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(settingAction) forControlEvents:(UIControlEventTouchUpInside)];
    [_defaultView addSubview:settingBtn];
    

    float alarmBtnSize = 30;
    UIButton *alarmBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [self initAlarmButton:alarmBtn onPosition:CGRectMake(_defaultView.width - alarmBtnSize - 10, settingBtn.bottom + 10, alarmBtnSize, alarmBtnSize) withWarningType:self.data.warning];
    [alarmBtn addTarget:self action:@selector(alarmAction) forControlEvents:(UIControlEventTouchUpInside)];
    
    [_defaultView addSubview:alarmBtn];
    
    isShowingRouteTypeSelctionPopup = NO;
    
    bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, _defaultView.height - 43, App_Frame_Width, 43)];
    bottomBar.backgroundColor = [UIColor whiteColor];
    [_defaultView addSubview:bottomBar];
    
    //底部工具栏上的按钮
    UILabel *lbl  = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 100, 24)];
    lbl.text      = @"路线规划";
    lbl.textColor = FontColorA;
    lbl.font      = [UIFont boldSystemFontOfSize:13];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.userInteractionEnabled = YES;
    [bottomBar addSubview:lbl];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(switchRouteTypeSelectionPopup)];
    [lbl addGestureRecognizer:tap];
    

    isShowingAssistPopup = NO;
    
    UIButton *favoriteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    favoriteBtn.frame           = CGRectMake(App_Frame_Width - 20 - 64, 0, 64, 42);
    favoriteBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [favoriteBtn setTitle:@"IUU助手" forState:(UIControlStateNormal)];
    favoriteBtn.backgroundColor = [UIColor clearColor];
    [favoriteBtn setTitleColor:FontColorA forState:(UIControlStateNormal)];
    [favoriteBtn addTarget:self action:@selector(switchAssistantPopup) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:favoriteBtn];
    
    [self showAdvertising];
    
    isShowingAssistPopup = NO;
}


- (void)initMap
{
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, self.titleView.bottom, _defaultView.width, _defaultView.height - 43)];
    self.mapView.delegate          = self;
    self.mapView.showsCompass      = YES;
    self.mapView.compassOrigin     = CGPointMake(10, 10);

    if ([self isAutoLocatingOn])
    {
        self.mapView.showsUserLocation = YES;
    }
    else
    {
        self.mapView.showsUserLocation = NO;
    }
    
    self.mapView.rotateEnabled     = NO;
    //self.mapView.scrollEnabled = NO;
    self.mapView.zoomLevel         = [self.data.mapZoom floatValue];
    self.mapView.showsScale        = NO;
    [self.mapView setShowsLabels:NO];
    
    
    //[self.mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES]; //地图跟着位置移动
    
    [self setMapCenter2ScenicSpotCenter];
    
    [_defaultView addSubview:self.mapView];
}



- (void)showAdvertising
{
    if (adImgs == nil)
    {
        adImgs         = [[NSMutableArray alloc] init];
        adDatas        = [[NSMutableArray alloc] init];
        adImgView      = [[UIImageView alloc] initWithFrame:CGRectMake((App_Frame_Width - 300) / 2 ,bottomBar.top - 46, 300, 36)];
        CALayer *layer = adImgView.layer;
        layer.borderColor   = [[UIColor yellowColor] CGColor];
        layer.borderWidth   = 1;
        layer.masksToBounds = YES;
        layer.cornerRadius  = 5;
        
        adBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        adBtn.frame = adImgView.frame;
        [adBtn addTarget:self action:@selector(adClick) forControlEvents:UIControlEventTouchUpInside];
        
        adCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        adCloseBtn.frame = CGRectMake((App_Frame_Width - 300) / 2 + 280, adImgView.top - 10, 20, 20);
        [adCloseBtn addTarget:self action:@selector(adCloseClick) forControlEvents:UIControlEventTouchUpInside];
        [adCloseBtn setBackgroundImage:[UIImage imageNamed:@"closeIcon.png"] forState:UIControlStateNormal];
    }
    else
    {
        [adImgs removeAllObjects];
    }
    
    
    __weak __typeof(self)weakSelf = self;
    [Interface mapAdvert:self.data.scenicId result:^(MapAdvertResponse *response, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }
        
        strongSelf->adDatas = response.advertArray;
        if (response.advertArray.count > 0)
        {
            for (int i = 0; i < response.advertArray.count; i++)
            {
                MapAdvertData * datetemp = [response.advertArray objectAtIndex:i];
                [strongSelf->adImgs addObject:datetemp.advertPic];
            }
            //启动轮播图片
            [strongSelf performSelectorOnMainThread:@selector(startAd) withObject:nil waitUntilDone:YES];
            
            [strongSelf->_defaultView addSubview:strongSelf->adImgView];
            [strongSelf->_defaultView addSubview:strongSelf->adBtn];
            [strongSelf->_defaultView addSubview:strongSelf->adCloseBtn];
        }
    }];
}


- (void)reAdvertFrame
{
    adImgView.frame = CGRectMake((App_Frame_Width - 300) / 2 ,bottomBar.top - 46, 300, 36);
    adBtn.frame = adImgView.frame;
    adCloseBtn.frame = CGRectMake((App_Frame_Width - 300) / 2 + 280, adImgView.top - 10, 20, 20);
    
}
- (void)startAd
{
    adIndex = 0;

    
    [adImgView setShowActivityIndicatorView:YES];
    [adImgView setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [adImgView sd_setImageWithURL:[NSURL URLWithString:[adImgs objectAtIndex:0]] placeholderImage:[UIImage imageNamed:@"placeholder_common"]options:SDWebImageProgressiveDownload | SDWebImageRetryFailed];


    
    adTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                               target:self
                                             selector:@selector(showNextAdPic)
                                             userInfo:nil
                                              repeats:YES];
    NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:adTimer forMode:NSDefaultRunLoopMode];
}

- (void)showNextAdPic
{
    if ([adImgs count] > 0)
    {
        adIndex ++;
        adIndex %= [adImgs count];
        
        
        [adImgView setShowActivityIndicatorView:YES];
        [adImgView setIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [adImgView sd_setImageWithURL:[NSURL URLWithString:[adImgs objectAtIndex:adIndex]] placeholderImage:[UIImage imageNamed:@"placeholder_common"]options:SDWebImageProgressiveDownload | SDWebImageRetryFailed];
    }
}

- (void)adClick
{
    //停止轮播
    [adTimer invalidate];
    
    MapAdvertData * datemp = [adDatas objectAtIndex:adIndex];
    //跳转到广告的景区
    NSString *idStr        = datemp.scenicId;
    NSString *sceName      = datemp.scenicName;

    ScenicArea *data       = [[ScenicArea alloc] init];
    data.scenicId          = idStr;
    data.scenicName        = sceName;
    DetailViewController  *mainController = [[DetailViewController alloc] init];
    mainController.data = data;
    [self.navigationController pushViewController:mainController animated:YES];
    [self adCloseClick];
}

- (void)adCloseClick
{
    //停止轮播
    [adTimer invalidate];
    
    //移除广告条
    [adImgView removeFromSuperview];
    [adBtn removeFromSuperview];
    [adCloseBtn removeFromSuperview];
}

- (void)showOnlineMap
{
    //获取全部数据
    __weak __typeof(self)weakSelf = self;
    [Interface scenicMap:self.data.scenicId result:^(ScenicMapResponse *response, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }

        strongSelf->result = response.mapList;
        
        // 添加标注
        if (strongSelf->_destinationPoint != nil)
        {
            // 清理
            [strongSelf.mapView removeAnnotation:strongSelf->_destinationPoint];
            strongSelf->_destinationPoint = nil;
        }

        for (int i =0; i < strongSelf->result.count; i++)
        {
            ScenicMap * datatemp = [strongSelf->result objectAtIndex:i];
            if ([datatemp.spotType intValue] ==1) {

                //添加标注
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([datatemp.lat doubleValue], [datatemp.lon doubleValue]);
                //            coords[i] = coordinate;

                strongSelf->_destinationPoint            = [[MAPointAnnotation alloc] init];
                strongSelf->_destinationPoint.coordinate = coordinate;
                strongSelf->_destinationPoint.title      = datatemp.name;
                strongSelf->_destinationPoint.subtitle   = [NSString stringWithFormat:@"%d",i];
                [strongSelf.annotations addObject:strongSelf->_destinationPoint];
                
                //判断沙河目录中 时候存在语音文件，存在则不下载
                NSString * strVoice = [datatemp.audio stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@document_library/scenicArea%@/",K_Image_URL,datatemp.scenicID] withString:@""];
                NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
                NSString * path = [paths  objectAtIndex:0];
                NSString * filePath = [path stringByAppendingPathComponent:strVoice];
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                }
                else
                {
                    //语音
                    [[DownResource DownResourceManger] getVoiceURL:datatemp.audio Voice:[datatemp.audio stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@document_library/scenicArea%@/",K_Image_URL,datatemp.scenicID] withString:@""]];
                }

            }


        }
        
        [strongSelf.mapView addOverlay:[strongSelf createOnlineTileTemplate]];
        [strongSelf.mapView addAnnotations:strongSelf.annotations];
    }];



    dispatch_queue_t globalQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //异步执行队列任务
    dispatch_async(globalQueue, ^{
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }

        strongSelf->tourArray = [[NSMutableArray alloc] init];
        strongSelf->classicArray = [[NSMutableArray alloc] init];
        
        //获取路线数据
        __weak __typeof(self)weakSelf2 = self;
        [Interface mapLines:strongSelf.data.scenicId result:^(MapLineResponse *response, NSError *error) {
            __strong __typeof(weakSelf2)strongSelf2 = weakSelf2;
            
            if (!strongSelf2)
            {
                return;
            }

            strongSelf2->tourArray = response.TourList;
            strongSelf2->classicArray = response.classicList;
        }];
    });


}



- (void)setMapCenter2ScenicSpotCenter
{
    double centerLat = ([self.data.lat doubleValue] + [self.data.rightLat doubleValue])/2;
    double centerLon = ([self.data.lng doubleValue] + [self.data.rightLon doubleValue])/2;

    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(centerLat, centerLon);
}

- (void)initTrackingWithCoords:(CLLocationCoordinate2D *)coords count:(NSUInteger)count
{
    _tracking = [[NSMutableArray alloc] init];
    for (int i = 0; i<count - 1; i++)
    {
        TracingPoint * tp = [[TracingPoint alloc] init];
        tp.coordinate = coords[i];
        tp.course = [Util calculateCourseFromCoordinate:coords[i] to:coords[i+1]];
        [_tracking addObject:tp];
        
    }
    
    TracingPoint * tp = [[TracingPoint alloc] init];
    tp.coordinate = coords[count - 1];
    tp.course = ((TracingPoint *)[_tracking lastObject]).course;
    [_tracking addObject:tp];
    
}


- (MATileOverlay *)createOnlineTileTemplate
{
    /* 构建tileOverlay的URL模版. */
    NSString *URLTemplate = [NSString stringWithFormat:@"%@%@/{z}/{x}/{y}.png",K_Tiles_URL,self.data.scenicId];
    
    //MATileOverlay *tileOverlay = [[MATileOverlay alloc] initWithURLTemplate:URLTemplate];
    GridTileOverlay *tileOverlay = [[GridTileOverlay alloc] initWithURLTemplate:URLTemplate];
    
    tileOverlay.minimumZ = 14; //设置可见最小Zoom值
    tileOverlay.maximumZ = 20; //设置可见最大Zoom值
    
    tileOverlay.boundingMapRect = MAMapRectWorld;
    
    return tileOverlay;
}

- (GridTileOverlay *)createOfflineTileTemplate
{
    NSString* path=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * URLTemplate = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/tiles/{z}/{x}/{y}.png",self.data.scenicId]];
    
    GridTileOverlay *gridTile = [[GridTileOverlay alloc] initWithURLTemplate:URLTemplate];
    
    
    gridTile.minimumZ = 14; //设置可见最小Zoom值
    gridTile.maximumZ = 20; //设置可见最大Zoom值
    
    gridTile.boundingMapRect = MAMapRectWorld;

    
    return gridTile;
}

#pragma mark - AMapViewDelegate

- (void)mapView:(MKMapView *)_mapView regionDidChangeAnimated:(BOOL)animated
{
    if (manuallyChangingMapRect) //prevents possible infinite recursion when we call setVisibleMapRect below
        return;
    
    if (self.mapView.zoomLevel < [self.data.mapZoom doubleValue])
    {
        manuallyChangingMapRect = YES;
        self.mapView.zoomLevel = [self.data.mapZoom doubleValue];
        manuallyChangingMapRect = NO;
    }
    else
    {
        [self adjustVisibleMapIfNeeded];
    }
}

    
-(void)adjustVisibleMapIfNeeded
{
    BOOL isAdjustRequired = NO;
    
    CLLocationCoordinate2D  northWestSketchPoint = CLLocationCoordinate2DMake([self.data.lat doubleValue], [self.data.lng doubleValue]);
    CLLocationCoordinate2D  southEastSketchPoint = CLLocationCoordinate2DMake([self.data.rightLat doubleValue], [self.data.rightLon doubleValue]);
    

    MAMapPoint upperLeftSketch  = MAMapPointForCoordinate(northWestSketchPoint);
    MAMapPoint lowerRightSketch = MAMapPointForCoordinate(southEastSketchPoint);
    

    MAMapRect mRect          = self.mapView.visibleMapRect;
    MAMapPoint westMapPoint  = MAMapPointMake(MAMapRectGetMinX(mRect), MAMapRectGetMidY(mRect));
    MAMapPoint eastMapPoint  = MAMapPointMake(MAMapRectGetMaxX(mRect), MAMapRectGetMidY(mRect));
    MAMapPoint northMapPoint = MAMapPointMake(MAMapRectGetMidX(mRect), MAMapRectGetMaxY(mRect));
    MAMapPoint southMapPoint = MAMapPointMake(MAMapRectGetMidX(mRect), MAMapRectGetMinY(mRect));
    
    
    double visibleMapWidth  = mRect.size.width;
    double visibleMapHeight = mRect.size.height;
    
    double xOrigin = mRect.origin.x;
    double yOrigin = mRect.origin.y;
    
    if (westMapPoint.x < upperLeftSketch.x)
    {
        isAdjustRequired = YES;
        xOrigin = upperLeftSketch.x;
    }
    else if (eastMapPoint.x > lowerRightSketch.x)
    {
        isAdjustRequired = YES;
        xOrigin -= (eastMapPoint.x - lowerRightSketch.x);
    }

    if (northMapPoint.y > upperLeftSketch.y)
    {
        isAdjustRequired = YES;
        yOrigin -= (northMapPoint.y - upperLeftSketch.y);
    }
    else if (southMapPoint.y < lowerRightSketch.y)
    {
        isAdjustRequired = YES;
        yOrigin = lowerRightSketch.y;
    }
    
    MAMapRect adjustedMapRect = MAMapRectMake(xOrigin, yOrigin, visibleMapWidth, visibleMapHeight);
    
    if (isAdjustRequired)
    {
        manuallyChangingMapRect = YES;
        [self.mapView setVisibleMapRect:adjustedMapRect animated:YES];
        manuallyChangingMapRect = NO;
    }
}


- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MapCusAnnotationView *annotationView = (MapCusAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MapCusAnnotationView alloc] initWithAnnotation:annotation
                                                              reuseIdentifier:pointReuseIndetifier];
        }
        

        if ([annotation.title isEqualToString:@"FocusIndicator"])
        {
            UIImage *imge  =  [UIImage imageNamed:@"focusIndicator"];
            annotationView.image =  imge;
            
            annotationView.name = @"";
            annotationView.nameText.hidden = YES;
            annotationView.voiceBtn.hidden = YES;
            
            annotationView.isCallOnAvailable = NO;
            
            [annotationView setCenterOffset:CGPointMake(0, 0)];
        }
        else
        {
            annotationView.isCallOnAvailable = YES;
            
            annotationView.image         = [UIImage imageNamed:@"hotviewport_nosel_map.png"];
            annotationView.name          = annotation.title;
            annotationView.nameText.text = annotation.title;
            annotationView.voiceBtn.tag  = [annotation.subtitle integerValue];
            [annotationView.voiceBtn addTarget:self
                                        action:@selector(VoiceAction:)
                              forControlEvents:(UIControlEventTouchUpInside)];
            annotationView.comeHereBtn.tag = [annotation.subtitle integerValue];
            [annotationView.comeHereBtn addTarget:self
                                           action:@selector(navigationAction:)
                                 forControlEvents:(UIControlEventTouchUpInside)];
            

            if([annotation.title isEqualToString:@"洗手间"])//_roaldSearchText
            {
                annotationView.nameText.hidden = YES;
                annotationView.image = [UIImage imageNamed:@"map_02.png"];
            }
            else if ([annotation.title isEqualToString:@"索道"])
            {
                annotationView.image = [UIImage imageNamed:@"map_07.png"];

                annotationView.nameText.hidden = YES;
            }
            else if ([annotation.title isEqualToString:@"码头"])
            {
                annotationView.image = [UIImage imageNamed:@"map_09.png"];

                annotationView.nameText.hidden = YES;
            }
            else if ([annotation.title isEqualToString:@"服务中心"])
            {
                annotationView.image = [UIImage imageNamed:@"map_10.png"];

                annotationView.nameText.hidden = YES;
            }
            else if ([annotation.title isEqualToString:@"停车场"])
            {
                annotationView.image = [UIImage imageNamed:@"map_03.png"];

                annotationView.nameText.hidden = YES;
            }
            else if ([annotation.title isEqualToString:@"换乘中心"])
            {
                annotationView.image = [UIImage imageNamed:@"map_08.png"];

                annotationView.nameText.hidden = YES;
            }
            else if ([annotation.title isEqualToString:@"售票处"])
            {
                annotationView.image = [UIImage imageNamed:@"map_04.png"];

                annotationView.nameText.hidden = YES;
            }
            else if ([annotation.title isEqualToString:@"出入口"])
            {
                annotationView.image = [UIImage imageNamed:@"map_05.png"];

                annotationView.nameText.hidden = YES;
            }
        }
        
        
        NavPointAnnotation *navAnnotation = (NavPointAnnotation *)annotation;
        if ([navAnnotation.title isEqualToString:@"起始点"]) {
            [annotationView setImage:[UIImage imageNamed:@"greenPin.png"]];

        }
        else if ([navAnnotation.title isEqualToString:@"终点"])
        {
            [annotationView setImage:[UIImage imageNamed:@"purplePin.png"]];

        }

        
        return annotationView;
    }
    
    return nil;
}

- (CGSize)offsetToContainRect:(CGRect)innerRect inRect:(CGRect)outerRect
{
    CGFloat nudgeRight  = fmaxf(0, CGRectGetMinX(outerRect) - (CGRectGetMinX(innerRect)));
    CGFloat nudgeLeft   = fminf(0, CGRectGetMaxX(outerRect) - (CGRectGetMaxX(innerRect)));
    CGFloat nudgeTop    = fmaxf(0, CGRectGetMinY(outerRect) - (CGRectGetMinY(innerRect)));
    CGFloat nudgeBottom = fminf(0, CGRectGetMaxY(outerRect) - (CGRectGetMaxY(innerRect)));
    return CGSizeMake(nudgeLeft ?: nudgeRight, nudgeTop ?: nudgeBottom);
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    /* Adjust the map center in order to show the callout view completely. */
    if ([view isKindOfClass:[MapCusAnnotationView class]])
    {
        MapCusAnnotationView *cusView = (MapCusAnnotationView *)view;
        
        CGRect frame = [cusView convertRect:cusView.calloutView.frame toView:self.mapView];
        
        frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(kCalloutViewMargin, kCalloutViewMargin, kCalloutViewMargin, kCalloutViewMargin));
        
        if (!CGRectContainsRect(self.mapView.frame, frame))
        {
            /* Calculate the offset to make the callout view show up. */
            CGSize offset = [self offsetToContainRect:frame inRect:self.mapView.frame];
            
            CGPoint theCenter = self.mapView.center;
            theCenter = CGPointMake(theCenter.x - offset.width, theCenter.y - offset.height);
            
            CLLocationCoordinate2D coordinate = [self.mapView convertPoint:theCenter toCoordinateFromView:self.mapView];
            
            [self.mapView setCenterCoordinate:coordinate animated:YES];
        }
    }
}

//tileOverlay 和  折线 绘制代理方法
- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MATileOverlay class]])
    {

        MATileOverlayView *tileOverlayView = [[MATileOverlayView alloc] initWithTileOverlay:overlay];

        return tileOverlayView;
    }
    
    if([overlay isKindOfClass:[GridTileOverlay class]]) {
        MATileOverlayView *tileOverlayView = [[MATileOverlayView alloc] initWithTileOverlay:overlay];
        return tileOverlayView;
    }
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineView *polylineView = [[MAPolylineView alloc] initWithPolyline:overlay];
        
        polylineView.lineWidth   = 4;
        polylineView.strokeColor = [UIColor magentaColor];
        
        return polylineView;
    }
    if ([overlay isKindOfClass:[MACircle class]])
    {
        MACircleView *circleView = [[MACircleView alloc] initWithCircle:overlay];
        
        circleView.lineWidth   = 6;
        circleView.strokeColor = [UIColor blueColor];
        circleView.fillColor   = [[UIColor greenColor] colorWithAlphaComponent:0.3];
        
        return circleView;
    }
    
    return nil;
}



- (void)updateMapCenter2UserLocation:(MAUserLocation *)userLocation
{
    float latitude  = userLocation.coordinate.latitude;
    float longitude = userLocation.coordinate.longitude;
    
    if (latitude > [self.data.lat doubleValue]         &&
        latitude < [self.data.rightLat doubleValue]     &&
        longitude > [self.data.lng doubleValue]         &&
        longitude < [self.data.rightLon doubleValue])
    {
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    }
}


-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if (![self isAutoLocatingOn])
    {
        return;
    }
    
    if(updatingLocation)
    {
        if (isFirstTimeUserLocated)
        {
            isFirstTimeUserLocated = NO;
            [self updateMapCenter2UserLocation:userLocation];
        }
        

        lat = userLocation.coordinate.latitude;
        lon = userLocation.coordinate.longitude;
        
        if (!lastUserLocation)
        {
            lastUserLocation = [[MAUserLocation alloc]init];
            lastUserLocation.coordinate = userLocation.coordinate;
        }
        else
        {
            //1.将两个经纬度点转成投影点
            MAMapPoint point1 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(lastUserLocation.coordinate.latitude,lastUserLocation.coordinate.longitude));
            MAMapPoint point2 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(userLocation.coordinate.latitude,userLocation.coordinate.longitude));
            
            //2.计算距离
            CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
            
            if (distance < 10)
            {
                return;
            }
        }
        

        NSMutableArray * array = [[NSMutableArray alloc] init];
        NSMutableArray * arrayI= [[NSMutableArray alloc] init];
        
        BOOL isAutoVoiceOn = [self isAutoLocatingOn];
        for (int i = 0; isAutoVoiceOn && i < result.count; i++)
        {
            ScenicMap * datatemp = [result objectAtIndex:i];
            if ([datatemp.spotType intValue] == 1)
            {
                //1.将两个经纬度点转成投影点
                MAMapPoint point1 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(userLocation.coordinate.latitude,userLocation.coordinate.longitude));
                MAMapPoint point2 = MAMapPointForCoordinate(CLLocationCoordinate2DMake([datatemp.lat doubleValue],[datatemp.lon doubleValue]));
                
                //2.计算距离
                CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);

                //  Near enough
                if (distance < [self.data.voiceDistance floatValue])
                {
                    [array addObject:[NSNumber numberWithFloat:distance]];
                    [arrayI addObject:[NSNumber numberWithInt:i]];
                }
            }
        }
        

        if (arrayI.count > 0 && isAutoVoiceOn)
        {
            float min = [[array valueForKeyPath:@"@min.floatValue"] floatValue];
            unsigned long index = [array indexOfObject:[NSNumber numberWithFloat:min]];
            
            
            UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];

            
            button.tag = [[arrayI objectAtIndex:index] intValue];

            if (self.player.playing)
            {
            }
            else
            {
                NSUserDefaults * stra = [NSUserDefaults standardUserDefaults];
                

                if ([[stra objectForKey:[NSString stringWithFormat:@"%@",[arrayI objectAtIndex:index]]] intValue] != 11)
                {
                    [stra setObject:@"11" forKey:[NSString stringWithFormat:@"%@",[arrayI objectAtIndex:index]]];
                    [stra synchronize];
                    [self VoiceAction:button];
                }
            }
        }
    }
}

#pragma mark - ACTION

- (void)switchRouteTypeSelectionPopup
{
    [self removeRouteLinePopup];
    
    [self removeIuuAssistPopup];
    [self removeAssistSubpopup];
    
    [self removeSettingPopup];
    
    if (!isShowingRouteTypeSelctionPopup)
    {
        isShowingRouteTypeSelctionPopup  = YES;
        
        routeTypeSelectionPopup = [[UIView alloc]initWithFrame:CGRectMake(10, bottomBar.top  - 10 - 70, 100, 70)];
        routeTypeSelectionPopup.backgroundColor = [UIColor clearColor];
        [_defaultView addSubview:routeTypeSelectionPopup];
        

        UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 60)];
        bgView.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.9];
        [routeTypeSelectionPopup addSubview:bgView];
        

        UIImageView * triangleImg = [[UIImageView alloc]initWithFrame:CGRectMake(20, 60, 10, 10)];
        triangleImg.backgroundColor = [UIColor whiteColor];
        [routeTypeSelectionPopup addSubview:triangleImg];
        
        UIButton * button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [button setFrame:CGRectMake(0, 0, 100, 30)];
        [button setTitleColor:FontColorA forState:(UIControlStateNormal)];
        [button setTitle:@"经典路线" forState:(UIControlStateNormal)];
        [button.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [button setTag:1];
        if (classicArray == nil || classicArray.count == 0) {
            [button setHidden:YES];
            routeTypeSelectionPopup.frame = CGRectMake(10, bottomBar.top - 20-30, 100, 40);
            bgView.size = CGSizeMake(bgView.width, 30);
        }
        
        [button addTarget:self action:@selector(showRoutePopupAndDrawRouteLineOnMapAction:) forControlEvents:(UIControlEventTouchUpInside)];
        
        CALayer *layer = [CALayer layer];
        [layer setFrame:CGRectMake(0, button.bottom, button.width, 1)];
        [layer setBackgroundColor:[UIColor groupTableViewBackgroundColor].CGColor];
        [button.layer addSublayer:layer];
        [routeTypeSelectionPopup addSubview:button];
        
        UIButton * button1 = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [button1 setFrame:CGRectMake(0,button.hidden ? 0 : 30, 100, 30)];
        [button1 setTitleColor:FontColorA forState:(UIControlStateNormal)];
        [button1 setTitle:@"畅游路线" forState:(UIControlStateNormal)];
        [button1.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [button1 setTag:2];
        if (tourArray.count == 0 || tourArray == nil) {
            [button1 setHidden:YES];
            routeTypeSelectionPopup.frame = CGRectMake(10, bottomBar.top - 20-30, 100, 40);
            bgView.size = CGSizeMake(bgView.width, 30);
        }
        
        [button1 addTarget:self action:@selector(showRoutePopupAndDrawRouteLineOnMapAction:) forControlEvents:(UIControlEventTouchUpInside)];
        
        [routeTypeSelectionPopup addSubview:button1];
    }
    else
    {
        [self removeRouteTypeSelectionPopup];
    }
}

- (void)removeRouteTypeSelectionPopup
{
    isShowingRouteTypeSelctionPopup = NO;
    
    [self removeRouteLinePopup];
    
    [routeTypeSelectionPopup removeFromSuperview];
}

- (void)removeRouteLinePopup
{
    [routeLinePopup removeFromSuperview];
    
    [self removeFocusIndicatorOnMap];
}


- (void)switchAssistantPopup
{
    [self removeRouteTypeSelectionPopup];
    [self removeRouteLinePopup];
    
    [self removeSettingPopup];
    
    if (!isShowingAssistPopup)
    {
        isShowingAssistPopup = YES;
        

        [self reAdvertFrame];

        
        float iuuAsistPopupWidth = App_Frame_Width - 20;
        
        iuuAssistPopup = [[UIView alloc] initWithFrame:CGRectMake(10, bottomBar.top - 190, iuuAsistPopupWidth, 170)];
        iuuAssistPopup.backgroundColor = [UIColor clearColor];
        iuuAssistPopup.userInteractionEnabled = YES;
        [_defaultView addSubview:iuuAssistPopup];
        

        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iuuAssistPopupBgTap:)];
        [iuuAssistPopup addGestureRecognizer:tap];
        
        UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, iuuAsistPopupWidth, 170)];
        scrollview.delegate = self;
        scrollview.backgroundColor = [UIColor whiteColor];
        [iuuAssistPopup addSubview:scrollview];

        NSArray *txtArray = @[@"洗手间",@"索道",@"码头",@"服务中心",@"停车场",@"换乘中心",@"售票处",@"出入口"];
        NSArray *imgArray = @[@"map_02",@"map_07",@"map_09",@"map_10",@"map_03",@"map_08",@"map_04",@"map_05"];
        
        float horizontalIndent = 20;
        float remainingWidth = iuuAsistPopupWidth - horizontalIndent;
        float width4Item = remainingWidth / 4.0f;// 4 items each line
        for (int i = 0; i < 8; i++)
        {
            UIButton * button = [UIButton buttonWithType:(UIButtonTypeCustom)];
            [button setTag:i+2];
            [button setFrame:CGRectMake(horizontalIndent+(i%4)*(width4Item), floor((i/4)* 75) +15 ,width4Item - 20,width4Item - 20)];
            [button setBackgroundColor:[UIColor clearColor]];
            [button setImage:[UIImage imageNamed:[imgArray objectAtIndex:i] ] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(selectFromIuuAssistant:) forControlEvents:(UIControlEventTouchUpInside)];
            [scrollview addSubview:button];
            
            UILabel * txt = [[UILabel alloc] initWithFrame:CGRectMake(button.left - 5, button.bottom, width4Item, 20)];
            CGPoint newCenter = txt.center;
            newCenter.x       = button.center.x;
            txt.center        = newCenter;
            txt.tag           = i+2;
            txt.text          = txtArray[i];
            txt.textAlignment = NSTextAlignmentCenter;
            txt.font          = [UIFont systemFontOfSize:12];
            txt.textColor     = [UIColor colorWithRed:0x40/255.0f green:0x40/255.0f blue:0x40/255.0f alpha:1];
            [scrollview addSubview:txt];
        }
    }
    else
    {
        [self removeIuuAssistPopup];
    }
}

- (void)removeIuuAssistPopup
{
    isShowingAssistPopup = NO;

    [self removeAssistSubpopup];
    
    [iuuAssistPopup removeFromSuperview];
    

    [self reAdvertFrame];
}


- (void)iuuAssistPopupBgTap:(UITapGestureRecognizer *)tap
{
    [self removeIuuAssistPopup];
}

- (void)selectFromIuuAssistant:(UIButton *)sender
{
    // 清理
    [self.mapView removeAnnotation:servicePoint];
    selectArr = [[NSMutableArray alloc] init];
    NSArray * array111 = [[NSArray alloc] initWithObjects:@"",@"",@"洗手间",@"索道",@"码头",@"服务中心",@"停车场",@"换乘中心",@"售票处",@"出入口", nil];
    for (int i =0; i < result.count; i++)
    {
         ScenicMap * datatemp = [result objectAtIndex:i];
        if (sender.tag == [datatemp.spotType intValue])
        {
            // 添加服务标注
            servicePoint = [[MAPointAnnotation alloc] init];
            servicePoint.coordinate = CLLocationCoordinate2DMake([datatemp.lat doubleValue], [datatemp.lon doubleValue]);
            servicePoint.title      = array111[[datatemp.spotType intValue]];
            
            [selectArr addObject:servicePoint];
        }
    }
    

    if (selectArr.count > 0)
    {
        iuuAssistSubPopup = [[UIView alloc] initWithFrame:CGRectMake(0, self.titleView.height, App_Frame_Width, App_Frame_Height - bottomBar.height - self.titleView.height)];
        

        iuuAssistSubPopup.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        [_defaultView addSubview:iuuAssistSubPopup];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(assistSubpopupBgTap:)];
        [iuuAssistSubPopup addGestureRecognizer:tap];
        
        
        UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(10, iuuAssistSubPopup.height/2 - 100, App_Frame_Width- 20, 200)];
        whiteView.backgroundColor = [UIColor whiteColor];
        [iuuAssistSubPopup addSubview:whiteView];
        
        
        UILabel * titlelbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, whiteView.width, 40)];
        titlelbl.font          = [UIFont systemFontOfSize:17];
        titlelbl.textAlignment = NSTextAlignmentCenter;
        titlelbl.textColor     = [UIColor blackColor];
        titlelbl.text          = @"请选择目标服务设备";
        [whiteView addSubview:titlelbl];
        
        
        UIScrollView * selectSrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, titlelbl.bottom, whiteView.width, whiteView.height - titlelbl.bottom)];
        [whiteView addSubview:selectSrollview];

        CGFloat contentHeight = 0;
        CGFloat buttonHeight = 30;
        for (int i = 0; i < selectArr.count; i++)
        {
            MAPointAnnotation * inPont = [selectArr objectAtIndex:i];
            //1.将两个经纬度点转成投影点
            MAMapPoint point1 = MAMapPointForCoordinate(inPont.coordinate);
            MAMapPoint point2 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(lat,lon));
            //2.计算距离
            CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
            

            UIButton * button = [UIButton buttonWithType:(UIButtonTypeCustom)];
            button.tag             = i;
            button.frame           = CGRectMake(0, contentHeight, selectSrollview.width, buttonHeight);
            button.titleLabel.font = [UIFont systemFontOfSize:13];
            [button setTitle:[NSString stringWithFormat:@"%@%d  距您当前位置：%.f米",[array111 objectAtIndex:[inPont.title intValue]] ,i,distance] forState:(UIControlStateNormal)];
            [button setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
            [button addTarget:self action:@selector(iuuAssistSubpopupAction:) forControlEvents:(UIControlEventTouchUpInside)];
            [selectSrollview addSubview:button];
            
            
            CALayer * layer = [CALayer layer];
            layer.frame           = CGRectMake(0, button.height, button.width, 1);
            layer.backgroundColor = [UIColor grayColor].CGColor;
            
            [button.layer addSublayer:layer];
            
            contentHeight += buttonHeight;
        }
        
        selectSrollview.contentSize = CGSizeMake(selectSrollview.width, contentHeight);
    }
}


- (void)assistSubpopupBgTap:(UITapGestureRecognizer *)tap
{
    [self removeAssistSubpopup];
}

- (void)removeAssistSubpopup
{
    [iuuAssistSubPopup removeFromSuperview];
}


- (void)iuuAssistSubpopupAction:(UIButton *)sender
{
    [self removeAssistSubpopup];
    
    [self removeIuuAssistPopup];
    
    
    MAPointAnnotation * inPont = [selectArr objectAtIndex:sender.tag];


    self.mapView.centerCoordinate = inPont.coordinate;
    [self.mapView addAnnotation:inPont];
}


- (void)showRoutePopupAndDrawRouteLineOnMapAction:(UIButton *)sender
{
    [self removeRouteTypeSelectionPopup];

    
    [self.mapView removeOverlay:commonPolyline];
    
    
    commonPolyline = nil;

    if (sender.tag == 1)
    {
        isTourOrClass = YES;
        MapLine * datatemp = [classicArray objectAtIndex:0];
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake([datatemp.lat doubleValue], [datatemp.lng doubleValue]);
        
        
        //折线经纬度
        CLLocationCoordinate2D commonPolylineCoords[classicArray.count];
        for (int i=0;i<classicArray.count;i++) {
            MapLine * datatemp = [classicArray objectAtIndex:i];
            //折线
            commonPolylineCoords[i].latitude = [datatemp.lat doubleValue];
            commonPolylineCoords[i].longitude = [datatemp.lng doubleValue];
        }
       
        //构造折线对象
        commonPolyline = [MAPolyline polylineWithCoordinates:commonPolylineCoords count:classicArray.count];
        
        //在地图上添加折线对象
        [self.mapView addOverlay: commonPolyline];
        
        [self showClickableRoutePopup:classicArray];
    }
    else
    {
        isTourOrClass = NO;
        
        
        MapLine * datatemp = [tourArray objectAtIndex:0];
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake([datatemp.lat doubleValue], [datatemp.lng doubleValue]);

        
        //折线经纬度
        CLLocationCoordinate2D commonPolylineCoords[tourArray.count];
        for (int i=0;i<tourArray.count;i++) {
            MapLine * datatemp = [tourArray objectAtIndex:i];
            //折线
            commonPolylineCoords[i].latitude = [datatemp.lat doubleValue];
            commonPolylineCoords[i].longitude = [datatemp.lng doubleValue];
        }
        
        //构造折线对象
        commonPolyline = [MAPolyline polylineWithCoordinates:commonPolylineCoords count:tourArray.count];
        
        //在地图上添加折线对象
        [self.mapView addOverlay: commonPolyline];
        [self showClickableRoutePopup:tourArray];
    }
}


- (void)showClickableRoutePopup:(NSMutableArray *)array
{
    //可点击的路线图
    routeLinePopup = [[UIScrollView alloc] initWithFrame:CGRectMake(0,bottomBar.top - 100, App_Frame_Width , 100)];
    routeLinePopup.delegate                       = self;
    routeLinePopup.backgroundColor                = [UIColor whiteColor];
    routeLinePopup.showsVerticalScrollIndicator   = NO;
    routeLinePopup.showsHorizontalScrollIndicator = NO;
    [_defaultView addSubview:routeLinePopup];
    
    
    CGFloat xIndent = 20.0f;
    
    CGFloat yIndent = 20.0f;
    
    MapLine * temp = [array objectAtIndex:0];
    
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake([temp.lat doubleValue], [temp.lng doubleValue]);
    
    location.latitude += 0.00012;
    location.longitude -= 0.00012;
    

    [self showFocusIndicatorOnLocation:location];
    

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame               = CGRectMake(xIndent, yIndent, 35, 35);
    [btn setBackgroundImage:[[UIColor colorWithRed:228/255.0f green:68/255.0f blue:87/255.0f alpha:1.0] image] forState:UIControlStateNormal];
    btn.tag                 = 100;
    btn.layer.cornerRadius  = btn.height /2;
    btn.layer.masksToBounds = YES;
    [btn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btn setTitle:@"1" forState:(UIControlStateNormal)];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [btn addTarget:self action:@selector(spotRouteItemClick:) forControlEvents:UIControlEventTouchUpInside];
    [routeLinePopup addSubview:btn];

    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(xIndent - 8, btn.bottom, 52, routeLinePopup.height - btn.bottom)];
    lbl.font          = [UIFont systemFontOfSize:11];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.text          = temp.spotName;
    lbl.textColor     = [UIColor blackColor];
    [routeLinePopup addSubview:lbl];
    UIButton * button ;
    hotBtn = [[NSMutableArray alloc] init];
    connectingLines = [[NSMutableArray alloc]init];
    for (int i = 1; i < array.count; i++)
    {
        MapLine * temp = [array objectAtIndex:i];

        // 景点间的连接线
        xIndent += 35;
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(xIndent, yIndent + 20, 27, 2)];
        line.image = [[UIColor greenColor] image];
        line.tag   = i;
        [connectingLines addObject:line];
        [routeLinePopup addSubview:line];

        xIndent += 27;
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame               = CGRectMake(xIndent, yIndent, 35, 35);
        [button setBackgroundImage:[[UIColor colorWithRed:53/255.0f green:201/255.0f blue:106/255.0f alpha:1.0] image] forState:UIControlStateNormal];
        button.tag                 = 100+i;
        button.layer.cornerRadius  = btn.height /2;
        button.layer.masksToBounds = YES;

        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button setTitle:[NSString stringWithFormat:@"%d", i + 1] forState:(UIControlStateNormal)];
        
        button.titleLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
        [button addTarget:self action:@selector(spotRouteItemClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [routeLinePopup addSubview:button];
        
        [hotBtn addObject:button];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(xIndent - 8, button.bottom, 52, routeLinePopup.height - button.bottom)];
        lbl.font          = [UIFont systemFontOfSize:11];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text          = temp.spotName;
        lbl.textColor     = [UIColor blackColor];
        [routeLinePopup addSubview:lbl];
    }
    
    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, routeLinePopup.height - 1, button.right+20, 1)];
    bottomLine.backgroundColor = [UIColor colorWithRed:0xe0/255.0f green:0xe0/255.0f blue:0xe0/255.0f alpha:0xe0/255.0f];
    
    [routeLinePopup addSubview:bottomLine];
 
    routeLinePopup.contentSize = CGSizeMake(button.right+20, routeLinePopup.height);
}


- (void)spotRouteItemClick:(UIButton *)sender
{
    int countNum = (int)sender.tag-100;
    
    NSMutableArray * rutoArray = isTourOrClass ? classicArray : tourArray;

    for (UIButton * button in hotBtn)
    {
        if (button.tag <=  sender.tag)
        {
            [button setBackgroundImage:[[UIColor colorWithRed:228/255.0f green:68/255.0f blue:87/255.0f alpha:1.0] image] forState:(UIControlStateNormal)];
        }
        else
        {
            [button setBackgroundImage:[[UIColor colorWithRed:53/255.0f green:201/255.0f blue:106/255.0f alpha:1.0] image] forState:UIControlStateNormal];
        }
    }
    
    for (UIImageView *line in connectingLines)
    {
        if (line.tag <= sender.tag - 100)
        {
            line.image = [[UIColor redColor] image];
        }
        else
        {
            line.image = [[UIColor greenColor] image];
        }
    }
    
    
    MapLine *currentItem = [rutoArray objectAtIndex:countNum];
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake([currentItem.lat doubleValue], [currentItem.lng doubleValue]);
    
    self.mapView.centerCoordinate = location;
    
    
    location.latitude += 0.00012;
    location.longitude -= 0.00012;
    
    [self showFocusIndicatorOnLocation:location];
}

- (void)removeFocusIndicatorOnMap
{
    NSIndexSet *index2Remove = [self.annotations indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        MAPointAnnotation *annotation = (MAPointAnnotation*)obj;
        if ([annotation.title isEqualToString:@"FocusIndicator"])
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }];
    
    
    NSArray *annotation2Remove = [self.annotations objectsAtIndexes:index2Remove];
    [self.mapView removeAnnotations:annotation2Remove];
    
    [self.annotations removeObjectsAtIndexes:index2Remove];
}

- (void)showFocusIndicatorOnLocation:(CLLocationCoordinate2D)location
{
    NSIndexSet *index2Remove = [self.annotations indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        MAPointAnnotation *annotation = (MAPointAnnotation*)obj;
        if ([annotation.title isEqualToString:@"FocusIndicator"])
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }];
    
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    
    if (index2Remove.count <= 0)
    {
        _destinationPoint = [[MAPointAnnotation alloc] init];
        _destinationPoint.coordinate = coordinate;
        _destinationPoint.title = @"FocusIndicator";
        _destinationPoint.subtitle = [NSString stringWithFormat:@"%d",-1];
        
        [self.annotations addObject:_destinationPoint];
        
        [self.mapView addAnnotation:_destinationPoint];
    }
    else
    {
        {
            NSArray *annotation2Remove = [self.annotations objectsAtIndexes:index2Remove];
           
            
            _destinationPoint = [[MAPointAnnotation alloc] init];
            _destinationPoint.coordinate = coordinate;
            _destinationPoint.title = @"FocusIndicator";
            _destinationPoint.subtitle = [NSString stringWithFormat:@"%d",-1];
            
            [self.mapView removeAnnotations:annotation2Remove];
            [self.mapView addAnnotation:_destinationPoint];
            
            
            [self.annotations removeObjectsAtIndexes:index2Remove];
            [self.annotations addObject:_destinationPoint];
        
            
            return;
        }
    }
}



- (void)initNaviManager
{
    if (self.naviManager == nil)
    {
        _naviManager = [[AMapNaviManager alloc] init];
        [_naviManager setDelegate:self];
    }
}


#pragma mark - Button action
- (void)VoiceAction:(UIButton *)sender
{
    if (!result)
    {
        return;
    }
    
    if (sender.tag < 0 || sender.tag >= result.count)
    {
        return;
    }
    
    ScenicMap * datatemp = [result objectAtIndex:sender.tag];
    
    if (self.mydata != nil)
    {
        self.mydata = nil;
    }
    if (self.player != nil)
    {
        if ([lastVoice isEqualToString:datatemp.mapID])
        {
            if (self.player.playing)
            {
                [self.player pause];
                [sender setImage:[UIImage imageNamed:@"img_map_voice.png"] forState:(UIControlStateNormal)];
            }
            else
            {
                [sender setImage:[UIImage imageNamed:@"img_map_voice_playing.png"] forState:(UIControlStateNormal)];
                [self.player play];
            }
        }
        else
        {
            [self.player stop];
            self.player = nil;
        }
    }
    else
    {
        dispatch_queue_t globalQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //异步执行队列任务
        __weak __typeof(self)weakSelf = self;
        dispatch_async(globalQueue, ^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (!strongSelf)
            {
                return;
            }
            
            NSError * error;
            if (strongSelf->isNetwork)
            {
                //判断沙河目录中 时候存在语音文件，存在则不下载
                NSString * strVoice = [datatemp.audio stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@document_library/scenicArea%@/",K_Image_URL,datatemp.scenicID] withString:@""];
                NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
                NSString * path = [paths  objectAtIndex:0];
                NSString * filePath = [path stringByAppendingPathComponent:strVoice];
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    
                    strongSelf.player = [[AVAudioPlayer alloc]initWithContentsOfURL:[[NSURL alloc]initFileURLWithPath:filePath] error:nil];
                    strongSelf.player.volume = 1;
                }
                else
                {
                    strongSelf.mydata=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:datatemp.audio]];
                    strongSelf.player=[[AVAudioPlayer alloc]initWithData:strongSelf.mydata error:&error];
                    [strongSelf.player prepareToPlay];
                }
                
            }
            else
            {
                strongSelf.player = [[AVAudioPlayer alloc]initWithContentsOfURL:[[NSURL alloc]initFileURLWithPath:datatemp.audio] error:nil];
                strongSelf.player.volume = 1;
            }
            strongSelf.player.delegate = strongSelf;
            [strongSelf.player play];
        });
    }
    lastVoice = datatemp.mapID;
}


- (void)navigationAction:(UIButton *)sender
{
    if (!result)
    {
        return;
    }
    
    if (sender.tag < 0 || sender.tag >= result.count)
    {
        return;
    }
    
    [self initNaviManager];
    ScenicMap * datatemp = [result objectAtIndex:sender.tag];



    _startPoint = [AMapNaviPoint locationWithLatitude:lat longitude:lon];
    _endPoint   = [AMapNaviPoint locationWithLatitude:[datatemp.lat doubleValue] longitude:[datatemp.lon doubleValue]];
    

    NSArray *startPoints = @[_startPoint];
    NSArray *endPoints   = @[_endPoint];
    [self.naviManager calculateWalkRouteWithStartPoints:startPoints endPoints:endPoints];
    

    NSUInteger coordianteCount = [self.naviManager.naviRoute.routeCoordinates count];
    CLLocationCoordinate2D coordinates[coordianteCount];
    for (int i = 0; i < coordianteCount; i++)
    {
        AMapNaviPoint *aCoordinate = [self.naviManager.naviRoute.routeCoordinates objectAtIndex:i];
        coordinates[i] = CLLocationCoordinate2DMake(aCoordinate.latitude, aCoordinate.longitude);
    }
    
    _polyline = [MAPolyline polylineWithCoordinates:coordinates count:coordianteCount];
    [self.mapView addOverlay:_polyline];
    
 
    if (!self.naviViewController)
    {
        self.naviViewController = [[AMapNaviViewController alloc]
                                                  initWithMapView:self.mapView delegate:self];
        

    }
    
//            [self.mapView addAnnotations:self.annotations];
    
    [self.naviManager presentNaviViewController:self.naviViewController animated:YES];

}

- (void)mapCloseAction:(UIButton*)sender
{
    int i = 0;
    i = 1;
}


#pragma mark - audioplay delegate
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    NSLog(@"begin === %@",player);
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"finis = %@,fully = %d",player,flag);
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"error = %@",player);
}


#pragma mark - AMapNaviManager Delegate
- (void)AMapNaviManager:(AMapNaviManager *)naviManager onCalculateRouteFailure:(NSError *)error
{
//    [super AMapNaviManager:naviManager onCalculateRouteFailure:error];
//    [self.view makeToast:@"算路失败"
//                duration:2.0
//                position:[NSValue valueWithCGPoint:CGPointMake(160, 240)]];
}


- (void)AMapNaviManagerOnCalculateRouteSuccess:(AMapNaviManager *)naviManager
{
    [self showRouteWithNaviRoute:[[naviManager naviRoute] copy]];
    
    _calRouteSuccess = YES;
}


- (void)AMapNaviManager:(AMapNaviManager *)naviManager didPresentNaviViewController:(UIViewController *)mapNaviViewController
{
    // 初始化语音引擎
    [self initIFlySpeech];
    
//    if (self.naviType == NavigationTypeGPS)
//    {
        [self.naviManager startGPSNavi];
//    }
//    else if (self.naviType == NavigationTypeSimulator)
//    {
//        [self.naviManager startEmulatorNavi];
//    }
}

- (void)AMapNaviManager:(AMapNaviManager *)naviManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{
    NSLog(@"playNaviSoundString:{%ld:%@}", (long)soundStringType, soundString);
    
    if (soundStringType == AMapNaviSoundTypePassedReminder)
    {
        //用系统自带的声音做简单例子，播放其他提示音需要另外配置
        AudioServicesPlaySystemSound(1009);
    }
    else
    {
        __weak __typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (!strongSelf)
            {
                return;
            }
            
            [strongSelf->_iFlySpeechSynthesizer startSpeaking:soundString];
            NSLog(@"start speak");
        });
    }
}

#pragma mark - AManNaviViewController Delegate
- (void)naviViewControllerCloseButtonClicked:(AMapNaviViewController *)mapNaviViewController
{
    [self.iFlySpeechSynthesizer stopSpeaking];
    
    self.iFlySpeechSynthesizer.delegate = nil;
    self.iFlySpeechSynthesizer          = nil;
    
    [self.naviManager stopNavi];
    
    [self.naviManager dismissNaviViewControllerAnimated:YES];
    
    // 退出导航界面后恢复地图的状态
    [self refreshMapView];
    [self setMapCenter2ScenicSpotCenter];
}


- (void)refreshMapView
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeAnnotation:iuu_point];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeFromSuperview];
    
    iuu_point = nil;
    
    [self.mapView setDelegate:self];
    [self.mapView setFrame:CGRectMake(0, self.titleView.bottom,
                                      self.view.bounds.size.width,
                                      self.view.bounds.size.height - self.titleView.bottom)];
    [_defaultView insertSubview:self.mapView atIndex:0];
    
//    KMTileOverlay * iet = [[KMTileOverlay alloc] initWithURLTemplate:nil];
//    [self.mapView addOverlay:iet];

    for (int i =0; i < self.annotations.count; i++)
    {
        _destinationPoint  = [self.annotations objectAtIndex:i];
    }
    
    [self.mapView addOverlay:[self createOnlineTileTemplate]];
    [self.mapView addAnnotations:self.annotations];

    self.mapView.zoomLevel = [self.data.mapZoom floatValue];;
}


- (void)naviViewControllerMoreButtonClicked:(AMapNaviViewController *)mapNaviViewController
{
    if (mapNaviViewController.viewShowMode == AMapNaviViewShowModeCarNorthDirection)
    {
        mapNaviViewController.viewShowMode = AMapNaviViewShowModeMapNorthDirection;
    }
    else
    {
        mapNaviViewController.viewShowMode = AMapNaviViewShowModeCarNorthDirection;
    }

}


- (void)naviViewControllerTurnIndicatorViewTapped:(AMapNaviViewController *)mapNaviViewController
{
    [self.naviManager readNaviInfoManual];
}

- (void)showRouteWithNaviRoute:(AMapNaviRoute *)naviRoute
{
//    if (naviRoute == nil) return;
    
    // 清除旧的overlays
    if (_polyline)
    {
        [self.mapView removeOverlay:_polyline];
        self.polyline = nil;
    }
    
    NSUInteger coordianteCount = [naviRoute.routeCoordinates count];
    CLLocationCoordinate2D coordinates[coordianteCount];
    for (int i = 0; i < coordianteCount; i++)
    {
        AMapNaviPoint *aCoordinate = [naviRoute.routeCoordinates objectAtIndex:i];
        coordinates[i] = CLLocationCoordinate2DMake(aCoordinate.latitude, aCoordinate.longitude);
    }
    

    _polyline = [MAPolyline polylineWithCoordinates:coordinates count:coordianteCount];
    [self.mapView addOverlay:_polyline];
}


#pragma mark - iFlySpeechDelegate
- (void)onCompleted:(IFlySpeechError*) error
{
    NSLog(@"Speak Error:{%d:%@}", error.errorCode, error.errorDesc);
}


#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 36)];
    headV.backgroundColor = [UIColor colorWithRed:0xf0/255.0 green:0xf1/255.0 blue:0xf3/255.0 alpha:1];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 36)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:18];
    label.text = @"功能";
    [headV addSubview:label];
    

    float closeBtnSize = 20;
    UIButton *closeBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [closeBtn setFrame:CGRectMake(headV.width - closeBtnSize - 28, 8, closeBtnSize, closeBtnSize)];
    [closeBtn setBackgroundColor:[UIColor clearColor]];
    [closeBtn setContentMode:UIViewContentModeCenter];
    [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(settingCloseTap) forControlEvents:(UIControlEventTouchUpInside)];
    [headV addSubview:closeBtn];
    
    [headV setContentMode:UIViewContentModeCenter];
    
    return headV;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * pString = @"SetView";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:pString];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:pString];;
    }
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"定位";
    }
    else
    {
        cell.textLabel.text = @"自动讲解";
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    UISwitch * pSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(App_Frame_Width - 80, 5, 30, 30)];
    pSwitch.tag = indexPath.row;
    if (indexPath.row == 0)
    {
        if ([self isAutoLocatingOn])
        {
            pSwitch.on  = YES;
        }
        else
        {
            pSwitch.on  = NO;
        }
    }
    else
    {
        if ([self isAutoVoiceOn])
        {
            pSwitch.on  = YES;
        }
        else
        {
            pSwitch.on  = NO;
        }
    }
    [pSwitch addTarget:self action:@selector(switchAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [cell addSubview:pSwitch];
    
    return cell;
}

#pragma mark - Button action
- (void)settingAction
{
    [self removeRouteTypeSelectionPopup];
    [self removeRouteLinePopup];
    [self removeIuuAssistPopup];
    [self removeAssistSubpopup];
    
    if (!isShowingAssistPopup)
    {
        isShowingAssistPopup = YES;
        

        settingPopup = [[UIView alloc] initWithFrame:CGRectMake(0, self.titleView.bottom, App_Frame_Width, App_Frame_Height - bottomBar.height - self.titleView.height)];
        

        settingPopup.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        [_defaultView addSubview:settingPopup];
        
        
        UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(10, 100, App_Frame_Width - 20, 120)];
        whiteView.backgroundColor = [UIColor whiteColor];
        [settingPopup addSubview:whiteView];
        
        UITableView *tableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, App_Frame_Width - 20, 120) style:(UITableViewStyleGrouped)];
        tableView.delegate        = self;
        tableView.dataSource      = self;
        tableView.backgroundColor = [UIColor clearColor];

        [whiteView addSubview:tableView];
    }
    else
    {
        [self removeSettingPopup];
    }
}




- (void)switchAction:(UISwitch *)switcher
{
    NSInteger index = switcher.tag;
    switch (index)
    {
        case 0:
        {
            if (switcher.on)
            {
                NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
                
                [userDef setObject:@"ON" forKey:@"AutoLocating"];
                
                [userDef synchronize];
                
                self.mapView.showsUserLocation = YES;
                
                [UWindowHud hudWithType:kToastType withContentString:@"定位已打开！"];
            }
            else
            {
                NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
                
                [userDef setObject:@"OFF" forKey:@"AutoLocating"];
                
                [userDef synchronize];
                
                self.mapView.showsUserLocation = NO;
                
                [UWindowHud hudWithType:kToastType withContentString:@"定位已关闭！"];
            }
        }
            break;
        case 1:
        {
            if (switcher.on)
            {
                NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
                
                [userDef setObject:@"ON" forKey:@"AutoVoice"];
                
                [userDef synchronize];
                
                [UWindowHud hudWithType:kToastType withContentString:@"自动讲解已打开！"];
            }
            else
            {
                NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
                
                [userDef setObject:@"OFF" forKey:@"AutoVoice"];
                
                [userDef synchronize];
                
                [UWindowHud hudWithType:kToastType withContentString:@"自动讲解已关闭！"];
            }
        }
            
        default:
            break;
    }
}

- (BOOL)isAutoLocatingOn
{
    NSUserDefaults * userDef = [NSUserDefaults standardUserDefaults];
    
    
    if ([userDef objectForKey:@"AutoLocating"] && [[userDef objectForKey:@"AutoLocating"] isEqualToString:@"OFF"])
    {
        return NO;
    }
    
    return YES;
}


- (BOOL)isAutoVoiceOn
{
    NSUserDefaults * userDef = [NSUserDefaults standardUserDefaults];
    
    
    if ([userDef objectForKey:@"AutoVoice"] && [[userDef objectForKey:@"AutoVoice"] isEqualToString:@"OFF"])
    {
        return NO;
    }
    
    return YES;
}


- (void)settingCloseTap
{
    [self removeSettingPopup];
}

- (void)removeSettingPopup
{
    isShowingAssistPopup = NO;
    
    [settingPopup removeFromSuperview];
}

//  景区预警
- (void)alarmAction
{
    AlarmViewController * vc = [[AlarmViewController alloc]init];
    vc.data = self.data;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - get json
- (void)showOfflineMap
{
    isNetwork = NO;
    NSString *scenicId = self.data.scenicId;
    
    FileTools *fileTools = [FileTools defaultTools];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *adFilePath = [fileTools GetFullFilePathInDocuments:[NSString stringWithFormat:@"%@/%@.json", scenicId, scenicId]];
    NSTimeInterval lastModified = 0;
    if ([fileManager fileExistsAtPath:adFilePath]) {
        NSDictionary *fileAttrs = [fileManager attributesOfItemAtPath:adFilePath error:nil];
        NSDate *date = [fileAttrs objectForKey:NSFileModificationDate];
        lastModified = [date timeIntervalSinceReferenceDate];
    }

    NSDictionary * dataDic = [fileTools GetJSONObjectFromFile:adFilePath];
    result = [[NSMutableArray alloc] init];

    for (NSDictionary * json in [dataDic objectForKey:@"scenicMap"]) {

        ScenicMap *datatemp = [[ScenicMap alloc] init];
        datatemp.lat      = [json objectForKey:@"lat"];
        datatemp.lon      = [json objectForKey:@"lng"];
        datatemp.name     = [json objectForKey:@"scenicPointName"];
        datatemp.mapID    = [json objectForKey:@"id"];
        datatemp.spotType = [json objectForKey:@"spotType"];
        datatemp.audio    = [NSString stringWithFormat:@"%@%@",[self getPath],[json objectForKey:@"audioUrl"]];
        
        [result addObject:datatemp];
    }
    
    tourArray = [[NSMutableArray alloc] init];
    classicArray = [[NSMutableArray alloc] init];
    //获取路线数据
    for(NSDictionary *json in [dataDic objectForKey:@"scenicRecommendLine"])
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        for (NSDictionary * dataIn in [json objectForKey:@"lineSectionList"]) {
            MapLine * datetamp = [[MapLine alloc] init];
            datetamp.lineId   = [dataIn objectForKey:@"lineId"];
            datetamp.lat      = [dataIn objectForKey:@"lat"];
            datetamp.lng      = [dataIn objectForKey:@"lng"];
            datetamp.order    = [dataIn objectForKey:@"order"];
            datetamp.spotid   = [dataIn objectForKey:@"spotid"];
            datetamp.spotType = [dataIn objectForKey:@"spotType"];
            datetamp.spotName = [dataIn objectForKey:@"spotName"];
            [array addObject:datetamp];
        }
        
        if ([[json objectForKey:@"lineName"] isEqualToString:@"畅游路线"]) {
             tourArray = array;
        }
        else
        {
             classicArray = array;
        }
    }
    // 添加标注
    if (_destinationPoint != nil)
    {
        // 清理
        [self.mapView removeAnnotation:_destinationPoint];
        _destinationPoint = nil;
    }

    for (int i = 0; i < result.count; i++)
    {
         ScenicMap * datatemp = [result objectAtIndex:i];
        if ([datatemp.spotType intValue] ==1)
        {
            //添加标注
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([datatemp.lat doubleValue], [datatemp.lon doubleValue]);
            //            coords[i] = coordinate;
            
            _destinationPoint = [[MAPointAnnotation alloc] init];
            _destinationPoint.coordinate = coordinate;
            _destinationPoint.title      = datatemp.name;
            _destinationPoint.subtitle   = [NSString stringWithFormat:@"%d",i];
            [self.annotations addObject:_destinationPoint];
        }
    }
    
    //  Add tiles and annotations over map
    [self.mapView addOverlay:[self createOfflineTileTemplate]];
    [self.mapView addAnnotations:self.annotations];
}


- (NSString *)getPath
{
    FileTools *fileTools = [FileTools defaultTools];
    return [NSString stringWithFormat:@"%@/%@/",[fileTools GetDocumentsPath],self.data.scenicId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
