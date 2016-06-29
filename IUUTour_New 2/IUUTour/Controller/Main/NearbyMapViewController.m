#import "NearbyMapViewController.h"
#import "CusAnnotationView.h"
#import "DetailViewController.h"
#import "SearchCityViewController.h"
#define kCalloutViewMargin          -8

@interface NearbyMapViewController ()<MAMapViewDelegate, UITextFieldDelegate>
{
    UILabel     * _cityLabel;
    UIImageView * _cityArrowImg;
}
@property (nonatomic, strong) MAMapView      *mapView;
@property (nonatomic, retain) NSMutableArray *resultArr;
@end

@implementation NearbyMapViewController

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.titleView.hidden = NO;

    [self initWithBackBtn];
    
    [self creatTitleBtn];
    
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapAct:) name:@"mapNaviAction" object:nil];
    
    [self initMapView];
    
    [self initSearchView];
    
    [self loadNearbyMapOverview];
 }

- (void)loadNearbyMapOverview
{
    self.resultArr = [[NSMutableArray alloc]init];
    
    NSString *transString =  (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)self.cityName, NULL, NULL,  kCFStringEncodingUTF8 ));
    
    __weak __typeof(self)weakSelf = self;
    [Interface searchHomeListWithKey:transString result:^(HomeListResponse *response, NSError *error)
     {
         __strong __typeof(weakSelf)strongSelf = weakSelf;
         
         if (!strongSelf)
         {
             return;
         }
         
         [strongSelf.resultArr addObjectsFromArray:response.homeList];
         [strongSelf AddPointAnnotationWithFocusKey:nil];
     }];
}

- (void)initSearchView
{
    UITextField *_searchField = [[UITextField alloc ]initWithFrame:CGRectMake(10, self.titleView.bottom + 4, App_Frame_Width - 20, 36)];
    _searchField.placeholder       = @"请输入景区名称";
    _searchField.backgroundColor   = [UIColor colorWithWhite:1 alpha:1];
    _searchField.clearButtonMode   = UITextFieldViewModeWhileEditing;
    
    _searchField.textAlignment     = NSTextAlignmentCenter;
    _searchField.returnKeyType     = UIReturnKeySearch;
    _searchField.layer.cornerRadius = 18;
    
    @weakify(self);
    [[self rac_signalForSelector:@selector(textFieldShouldClear:)] subscribeNext:^(RACTuple *sender) {
        UITextField *searchField = sender.first;
        
        if (searchField.text.length <= 0)
        {
            return;
        }
        
        
        searchField.text=@"";
        
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        
        [self loadNearbyMapOverview];
    }];
    
    
    [[self rac_signalForSelector:@selector(textFieldShouldReturn:) fromProtocol:@protocol(UITextFieldDelegate)] subscribeNext:^(RACTuple *sender) {
        UITextField *searchField = sender.first;
        
        @strongify(self);
        
        NSString *nonSpacingText = [searchField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([nonSpacingText length] <= 0)
        {
            [UWindowHud hudWithType:kToastType withContentString:@"请输入搜索内容！"];
            return;
        }
        
        [self.view endEditing:YES];
        
        if (![self AddPointAnnotationWithFocusKey:nonSpacingText])
        {
            [UWindowHud hudWithType:kToastType withContentString:@"景区未找到，请重新输入！"];
        }
        
        searchField.text=@"";
    }];
    
    
    _searchField.delegate = self;
    
    [_defaultView addSubview:_searchField];
}

- (void)mapAct:(NSNotification *)notif
{
    self.mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0, self.titleView.bottom, App_Frame_Width, _defaultView.height - self.titleView.bottom)];
    self.mapView.delegate          = self;
    self.mapView.showsCompass      = NO;
    self.mapView.showsScale        = NO;
    self.mapView.userTrackingMode  = MAUserTrackingModeFollow;
    self.mapView.showsUserLocation = YES;
    [_defaultView addSubview:self.mapView];
}

#pragma mark title btn
- (void)creatTitleBtn
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake((App_Frame_Width - 160)/2, 0, 160, 44)];
    titleView.backgroundColor = [UIColor clearColor];
    
    [self.titleView addSubview:titleView];
    
    CGSize s = [Tools returnSizeWithStr:self.cityName andBaseSize:CGSizeMake(140, 44) andBaseFont:16];
    _cityLabel = [[UILabel alloc] initWithFrame:CGRectMake((titleView.frame.size.width - s.width -20)/2, 0, s.width, 44)];
    _cityLabel.text            = self.cityName;
    _cityLabel.backgroundColor = [UIColor clearColor];
    _cityLabel.textAlignment   = NSTextAlignmentCenter;
    _cityLabel.font            = [UIFont systemFontOfSize:16];
    [titleView addSubview:_cityLabel];
    
    _cityArrowImg = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cityLabel.frame) + 6, 20, 6, 4)];
    _cityArrowImg.backgroundColor = [UIColor clearColor];
    _cityArrowImg.image           = [UIImage imageNamed:@"down_arrow.png"];
    
    [titleView addSubview:_cityArrowImg];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame           = titleView.bounds;
    btn.backgroundColor = [UIColor clearColor];
    [btn addTarget:self action:@selector(chooseCityAction) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:btn];
    
}

#pragma mark 弹出选择城市
- (void)chooseCityAction
{
    SearchCityViewController *vv = [[SearchCityViewController alloc] init];
    vv.selectCity = _cityLabel.text;
    [self.navigationController pushViewController:vv animated:YES];
    
    __weak __typeof(self)weakSelf = self;
    [vv selectCityAction:^(CityModel *cityModel) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }
        
        strongSelf->_cityLabel.text = cityModel.cityName;
        strongSelf.lat = cityModel.citylat;
        strongSelf.lon = cityModel.citylng;
        [strongSelf searchDataActionWithKeyWord:cityModel.cityName  Lat:cityModel.citylng];
        [strongSelf layoutTitleNewFrame];

    }];
}

- (void)searchDataActionWithKeyWord:(NSString *)keyWord Lat:(NSString *)lat
{
    [SVProgressHUD showWithOwner:@"NearbyMapViewController_searchDataActionWithKeyWord"];
    
    NSString *transString =  (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)keyWord, NULL, NULL,  kCFStringEncodingUTF8 ));
    
    __weak __typeof(self)weakSelf = self;
    
    [Interface searchHomeListWithKey:transString result:^(HomeListResponse *response, NSError *error)
     {
         __strong __typeof(weakSelf)strongSelf = weakSelf;
         
         if (!strongSelf)
         {
             return;
         }
         
         if (strongSelf.resultArr.count != 0)
         {
             [strongSelf.resultArr removeAllObjects];
         }
         
         
         [strongSelf.resultArr addObjectsFromArray:response.homeList];
         
         [strongSelf AddPointAnnotationWithFocusKey:nil];
         
         [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
         
         [SVProgressHUD dismissFromOwner:@"NearbyMapViewController_searchDataActionWithKeyWord"];

     }];
}

- (void)layoutTitleNewFrame
{
    CGSize s = [Tools returnSizeWithStr:_cityLabel.text andBaseSize:CGSizeMake(140, 44) andBaseFont:16];
    _cityLabel.frame = CGRectMake((160 - s.width - 20)/2, _cityLabel.frame.origin.y, s.width, _cityLabel.frame.size.height);
    _cityArrowImg.frame = CGRectMake(CGRectGetMaxX(_cityLabel.frame) + 6, _cityArrowImg.frame.origin.y, 6, 4);
}


- (void)initMapView
{
    self.mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0, self.titleView.bottom, App_Frame_Width, _defaultView.height - self.titleView.bottom)];
    self.mapView.delegate          = self;
    self.mapView.showsCompass      = NO;
    self.mapView.showsScale        = NO;
    self.mapView.userTrackingMode  = MAUserTrackingModeFollow;
    self.mapView.showsUserLocation = YES;
    self.mapView.zoomLevel         = 16;
    [_defaultView addSubview:self.mapView];

}

-(BOOL)AddPointAnnotationWithFocusKey:(NSString*)key
{
    BOOL keyFound = NO;
    
    BOOL isValidCoordinateFound = NO;
    BOOL isInvalidCoordinateFound = NO;
    
    MAPointAnnotation *focusItem = nil;
    
    [_mapView removeAnnotations:_mapView.annotations];
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (int i = 0 ; i<[self.resultArr count]; i++)
    {
        ScenicArea *tempDara = [self.resultArr objectAtIndex:i];
        MAPointAnnotation *item = [[MAPointAnnotation alloc] init];
        
        item.title = @"NonFocusScene";
        
        double lat = [tempDara.lat doubleValue];
        double lng = [tempDara.lng doubleValue];
        
        if (lat < 0.01f || lng < 0.01f)
        {
            isInvalidCoordinateFound = YES;
            continue;
        }
        
        isValidCoordinateFound = YES;
        
        
        if (key && [tempDara.scenicName containsString:key] && !keyFound)
        {
            keyFound = YES;
            
            focusItem = item;
            
            item.title = @"FocusScene";
            item.subtitle = tempDara.scenicName;
        }
        
        CLLocationCoordinate2D coor = {lat, lng};
        item.coordinate = coor;
        [self.mapView addAnnotation:item];
        [array addObject:item];
    }
    
    [_mapView showAnnotations:array animated:NO];
    
    
    if (keyFound)
    {
        self.mapView.centerCoordinate = focusItem.coordinate;
        self.mapView.zoomLevel += 3;
    }
    
    if (!isValidCoordinateFound)
    {
        [UWindowHud hudWithType:kToastType withContentString:@"所有景区经纬度均无效，无法切换视角！"];
    }
    
    if (isInvalidCoordinateFound && isValidCoordinateFound)
    {
        [UWindowHud hudWithType:kToastType withContentString:@"已过滤掉经纬度无效的景区！"];
    }
    
    return keyFound;
}


- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *customReuseIndetifier = @"customReuseIndetifier";
        
//        CusAnnotationView *annotationView = (CusAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
//        
//        if (annotationView == nil)
//        {
            CusAnnotationView *annotationView = [[CusAnnotationView alloc] initWithAnnotation:annotation
                                                           reuseIdentifier:customReuseIndetifier];
//        }
        
        annotationView.canShowCallout   = NO;
        annotationView.draggable        = NO;
        annotationView.enabled          = YES;

        

        for (int i = 0; i < self.resultArr.count; i++)
        {
            ScenicArea *tempDara = [self.resultArr objectAtIndex:i];
            
            if (annotation.coordinate.longitude == [tempDara.lng doubleValue])
            {
                int alarmLevel = [tempDara.warning intValue];
                switch (alarmLevel)
                {
                    case 1:
                        [annotationView.backgroundImage setImage:[UIImage imageNamed:@"pin_green.png"]];
                        break;
                        
                    case 2:
                        [annotationView.backgroundImage setImage:[UIImage imageNamed:@"pin_blue.png"]];
                        break;
                        
                    case 3:
                        [annotationView.backgroundImage setImage:[UIImage imageNamed:@"pin_orange.png"]];
                        break;
                        
                    case 4:
                        [annotationView.backgroundImage setImage:[UIImage imageNamed:@"pin_yellow.png"]];
                        break;
                        
                    case 5:
                        [annotationView.backgroundImage setImage:[UIImage imageNamed:@"pin_red.png"]];
                        break;
                        
                    default:
                        [annotationView.backgroundImage setImage:[UIImage imageNamed:@"pin_orange.png"]];
                        break;
                }
    

                [annotationView.userHeadImage setTag:i];
            
                
                [annotationView.userHeadImage setShowActivityIndicatorView:YES];
                [annotationView.userHeadImage setIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [annotationView.userHeadImage sd_setImageWithURL:[NSURL URLWithString:tempDara.smallImage] placeholderImage:[UIImage imageNamed:@"placeholder_common"]options:SDWebImageProgressiveDownload | SDWebImageRetryFailed];
            }
            
        }

        
        if ([annotationView.annotation.title isEqualToString:@"FocusScene"])
        {
            [annotationView setTitle4Focus:annotationView.annotation.subtitle];
        }
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    if ([view isKindOfClass:[CusAnnotationView class]])
    {
        CusAnnotationView *cusView = (CusAnnotationView *)view;
        
        DetailViewController *vc = [[DetailViewController alloc]init];
        vc.data = [self.resultArr objectAtIndex:cusView.userHeadImage.tag];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGSize)offsetToContainRect:(CGRect)innerRect inRect:(CGRect)outerRect
{
    CGFloat nudgeRight  = fmaxf(0, CGRectGetMinX(outerRect) - (CGRectGetMinX(innerRect)));
    CGFloat nudgeLeft   = fminf(0, CGRectGetMaxX(outerRect) - (CGRectGetMaxX(innerRect)));
    CGFloat nudgeTop    = fmaxf(0, CGRectGetMinY(outerRect) - (CGRectGetMinY(innerRect)));
    CGFloat nudgeBottom = fminf(0, CGRectGetMaxY(outerRect) - (CGRectGetMaxY(innerRect)));
    return CGSizeMake(nudgeLeft ?: nudgeRight, nudgeTop ?: nudgeBottom);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
