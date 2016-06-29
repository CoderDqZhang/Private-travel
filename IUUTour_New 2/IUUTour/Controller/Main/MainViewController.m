#import "MainViewController.h"
#import "DetailViewController.h"
#import "LoginViewController.h"
#import "MoreViewController.h"
#import "NearbyMapViewController.h"
#import "SearchCityViewController.h"
#import "AboutViewController.h"
#import "FeedBackViewController.h"
#import "WebViewController.h"
#import "QuestionViewController.h"
#import "EventConsumingBgView.h"
#import "AlarmViewController.h"

//增加代码，
#import "MFSideMenu.h"
#import "UIImage+UIColor.h"
#import "MainTableView.h"
#import "TourModel.h"
#import "BottomView.h"

#define ViewTag 8888

#define CityLabelDefaultValue   @"请选择"

//增加代码，KVO
void *CusomHeaderInsetObserver = &CusomHeaderInsetObserver;

@interface MainViewController() <UITextFieldDelegate,CHTCollectionViewDelegateWaterfallLayout,UICollectionViewDataSource,MainViewDelegate>
{
    //增加代码
    UIButton             *locationBt;
    UIButton             *bottomBtn;
    UIImageView          *bgImage;
    UIButton             *hideBtn;
    
    UILabel              * _cityLabel;
    UIImageView          * _cityArrowImg;
//    MJRefreshFooterView  * _footer;//底部刷新请求更多数据
    int                  currentPage;
    NSMutableArray       * cityLatLon;//城市经纬度
    UITextField          * search;

    
    
    NSString             *lastLocatedOrSelectedCity;
    
    UITextField          *_searchField;
    
    
    BOOL                 isColumnCountEqual2One;//判断是一列还是双列
    NSMutableArray       * resultArr;
    BOOL                 isCitySelectedFromList;
    UIView               * bgView;
    
    BOOL                 isCitySwitchingPrompted;
    
}


@property (nonatomic, strong) NSString         *lastCity;
@property (nonatomic, retain) NSString         *lat;
@property (nonatomic, retain) NSString         *lon;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic        ) BOOL             isCityLocated4Startup;
@property (nonatomic        ) BOOL             isInForground;

@property (nonatomic, copy  ) NSString         *autoLocatedCity;

@property (nonatomic, retain) CHTCollectionViewWaterfallLayout *layout;

@property (nonatomic, strong) MainTableView *mainView;
@property (strong, nonatomic) NSArray *imagesData;

@end

@implementation MainViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = NavigationColor;
    self.autoLocatedCity = nil;
    self.isCityLocated4Startup = NO;
//
//    self.titleView.hidden = NO;
//    
//
//    [self creatTitleBtn];
//    
    isColumnCountEqual2One = YES;
//
//
//    UIImageView *moreIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 22, 4)];
//    moreIcon.image = [UIImage imageNamed:@"more.png"];
//    [self.titleView addSubview:moreIcon];
//    
//   
//    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    leftBtn.imageView.image = [UIImage imageNamed:@"leftMenu"];
//    [leftBtn setFrame:CGRectMake(0, 0, 60.0f, 40.0f)];
//    [leftBtn setBackgroundColor:[UIColor clearColor]];
//    
//    @weakify(self);
//    leftBtn.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
//        @strongify(self);
//        [self selectCityImplictly];
//        
////        MoreViewController *vc = [[MoreViewController alloc]init];
////        [self.navigationController pushViewController:vc animated:YES];
//        
//        return [RACSignal empty];
//    }];
//    [self.titleView addSubview:leftBtn];
//    
//    
//    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightBtn setFrame:CGRectMake(self.titleView.width - 80, 5.0f, 40.0f, 40.0f)];
//    [rightBtn setImage:[UIImage imageNamed:@"column"] forState:UIControlStateNormal];
//    [rightBtn setBackgroundColor:[UIColor clearColor]];
//    [rightBtn setContentMode:UIViewContentModeCenter];
//    rightBtn.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
//        @strongify(self);
//        if (self->isColumnCountEqual2One)
//        {
//            self->isColumnCountEqual2One = NO;
//            self.layout.columnCount = 2;
//        }
//        else
//        {
//            self->isColumnCountEqual2One = YES;
//            self.layout.columnCount = 1;
//        }
//        [self.collectionView reloadData];
//        
//        return [RACSignal empty];
//    }];
//    [self.titleView addSubview:rightBtn];
//    
//
//    UIButton *nearbyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//
//    [nearbyBtn setFrame:CGRectMake(self.titleView.width - 40, 5.0f, 40.0f, 40.0f)];
//    [nearbyBtn setImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
//    [nearbyBtn setBackgroundColor:[UIColor clearColor]];
//    [nearbyBtn setContentMode:UIViewContentModeCenter];
//    nearbyBtn.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
//         @strongify(self);
//        [self selectCityImplictly];
//        
//        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
//        
//        
//        NearbyMapViewController * vc = [[NearbyMapViewController alloc]init];
//        vc.cityName = self->_cityLabel.text;
//        vc.lat = self.lat;
//        vc.lon = self.lon;
//        [self.navigationController pushViewController:vc animated:YES];
//        return [RACSignal empty];
//    }];
    
//    [self.titleView addSubview:nearbyBtn];
//    
//    UIView *searchBgView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleView.frame), App_Frame_Width, 44)];
//    searchBgView.backgroundColor = [UIColor colorWithRed:0xf0/255.0f green:0xf1/255.0f blue:0xf3/255.0f alpha:1];
//    [self.view addSubview:searchBgView];
//    
//    _searchField = [[UITextField alloc ]initWithFrame:CGRectMake(10, 4, App_Frame_Width - 20, 36)];
//    _searchField.placeholder       = @"请输入景区名称/城市/省份";
//    _searchField.backgroundColor   = [UIColor colorWithWhite:1 alpha:1];
//    _searchField.clearButtonMode   = UITextFieldViewModeWhileEditing;
//
//    _searchField.textAlignment     = NSTextAlignmentCenter;
//    _searchField.returnKeyType     = UIReturnKeySearch;
//    _searchField.layer.cornerRadius = 18;
//
//    
//    [[self rac_signalForSelector:@selector(textFieldShouldClear:)] subscribeNext:^(RACTuple *sender) {
//        UITextField *searchField = sender.first;
//        
//        if (searchField.text.length <= 0)
//        {
//            return;
//        }
//        
//
//        searchField.text=@"";
//        
//        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
//    }];
//    
//
//    [[self rac_signalForSelector:@selector(textFieldShouldReturn:) fromProtocol:@protocol(UITextFieldDelegate)] subscribeNext:^(RACTuple *sender) {
//        UITextField *searchField = sender.first;
//        @strongify(self);
// 
//        NSString *nonSpacingText1 = [searchField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
//        if ([nonSpacingText1 length] <= 0)
//        {
//            [UWindowHud hudWithType:kToastType withContentString:@"请输入搜索内容！"];
//            return;
//        }
//        
//        [self.view endEditing:YES];
//        
//        NSString *nonSpacingText = [self->_cityLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""];
//        
//        self->lastLocatedOrSelectedCity = [NSString stringWithString:nonSpacingText];
//        
//        [self loadSearchResult:searchField.text];
//        
//        searchField.text=@"";
//    }];
//
//    
//    _searchField.delegate = self;
//    
//    [searchBgView addSubview:_searchField];
    
    
    resultArr   = [[NSMutableArray alloc] init];

    cityLatLon  = [[NSMutableArray alloc] init];

    currentPage = 0;

    self.lastCity = nil;
    
    isCitySelectedFromList  = NO;
    
    // table view
//    [self initCollectionView];
//    
//
    [RACObserve(APP_DELEGATE, locatedCity) subscribeNext:^(NSString *locatedCity) {
        if (locatedCity)
        {
            [self userCityAutoLocatedAction:locatedCity];
        }
    }];
    

    [[RACSignal combineLatest:@[RACObserve(APP_DELEGATE, userLat), RACObserve(APP_DELEGATE, userLon)]
            reduce:^id(NSString *lat, NSString *lon){
                
                NSUserDefaults * userDef = [NSUserDefaults standardUserDefaults];
                
                //  Store latitude and longitude
                //  Serialize for future usage (next startup)
                [userDef setValue:lat forKey:@"userLat"];
                [userDef setValue:lon forKey:@"userLon"];
                
                
                [userDef synchronize];
                
                return [RACSignal empty];
            }]subscribeNext:^(id x) {
                [self userLocationChangedAction];
            }];
    
    isCitySwitchingPrompted = NO;

    [self PromptSwtichingCityWhenPossible];
    
    
    [self setupMenuBarButtonItems];
    [self setupMainTable];
    
    [self setupBottonView];
    
//    [self relodData];
    
//    [RACObserve(self.model,dateAdded) map:^(NSDate*date){
//        return [[ViewModel dateFormatter] stringFromDate:date];
//    }];
}


-(void)setupBottonView
{
    UIImage *image = [UIImage imageNamed:@"btn"];
    bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottomBtn setBackgroundColor:[UIColor clearColor]];
    [bottomBtn setBackgroundImage:image forState:UIControlStateNormal];
    [bottomBtn setFrame:CGRectMake((App_Frame_Width - image.size.width)/2, App_Frame_Height - image.size.height, image.size.width, image.size.height)];
    [[bottomBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x){
        [self showBtn];
    }];
    [self.view addSubview:bottomBtn];
    [self initBottomView];
}


-(void)initBottomView{
    NSArray *iconArray = @[@"ic_jiudian",@"ic_meishi",@"ic_menpiao",@"ic_shangcheng"];
    CGFloat wid = (App_Frame_Width-150)/4;
    CGFloat heig = wid;
    CGFloat imgHeight = 90+heig;
    
    bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, App_Frame_Height -imgHeight, App_Frame_Width, imgHeight)];
    bgImage.hidden = YES;
    [bgImage setImage:[UIImage imageNamed:@"bg"]];
    bgImage.alpha = 0.7;
    [self.view addSubview:bgImage];
    
    for (int i = 0; i < 4; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(30+i*(wid+30), App_Frame_Height - 20 - heig+340, wid, heig);
        button.tag = ViewTag+i;
        [button setBackgroundImage:[UIImage imageNamed:iconArray[i]] forState:UIControlStateNormal];
        [self.view addSubview:button];
    }
    
    hideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    hideBtn.frame = CGRectMake((App_Frame_Width - 30)/2, App_Frame_Height + 360, 30, 30);
    [hideBtn setBackgroundImage:[UIImage imageNamed:@"hide"] forState:UIControlStateNormal];
    [hideBtn addTarget:self action:@selector(hideBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hideBtn];
    
}


-(void)showBtn{
    
    bottomBtn.hidden = YES;
    bgImage.hidden = NO;
    
    for (UIView *view in self.view.subviews) {
        UIButton *button = (UIButton*)view;
        switch (button.tag - ViewTag) {
            case 0:
            case 1:
            case 2:
            case 3:{
                [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.4f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveLinear animations:^{
                    
                    button.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y - 400, view.frame.size.width, view.frame.size.height);
                } completion:^(BOOL finished) {
                    
                }];
            }
                break;
        }
    }
    hideBtn.frame = CGRectMake(hideBtn.frame.origin.x, hideBtn.frame.origin.y - 400, 30, 30);
}

-(void)hideBtn {
    bottomBtn.hidden = NO;
    bgImage.hidden = YES;
    
    for (UIView *view in self.view.subviews) {
        UIButton *button = (UIButton*)view;
        switch (button.tag - ViewTag) {
            case 0:
            case 1:
            case 2:
            case 3:{
                [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.4f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveLinear animations:^{
                    
                    button.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + 400, view.frame.size.width, view.frame.size.height);
                } completion:^(BOOL finished) {
                    
                }];
            }
                break;
        }
    }
    hideBtn.frame = CGRectMake(hideBtn.frame.origin.x, hideBtn.frame.origin.y + 400, 30, 30);
}


-(void)relodData
{
//    _mainView.imagesData = [NSMutableArray arrayWithObjects:@"image1.jpg", @"image2.jpg", @"image3.jpg", @"image4.jpg", @"image5.jpg", @"image6.jpg", nil];
//    TourModel *model = [[TourModel alloc] init];
//    model.sceneryImage = @"image1.jpg";
//    model.sceneryName = @"台湾清水崖门票";
//    model.scenryDetail = @"静溢之最的灵通之地";
//    model.muchOld = @"288元/人";
//    model.muchNow = @"198元/人";
//    model.isActive = YES;
//    model.distances = @"1.9km";
//    model.grade = @"8.9分";
//    
//    for (int i = 0; i < 8; i++) {
//        [_mainView.tourModelArray addObject:model];
//    }

    _mainView.tourModelArray = resultArr;
    _mainView.cityLatLon = cityLatLon;
    [_mainView reloadData];
}

-(void)setupMainTable
{
    _mainView = [[MainTableView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, App_Frame_Height)];
    _mainView.delegate = self;
    
    [self.view addSubview:_mainView];
}

#pragma mark - MainViewDelegate
-(void)mjReloadData
{
    [self loadData:NO];
}
/**
 *  详情界面数据
 *
 *  @param model 
 */
-(void)pushViewAndModel:(ScenicArea *)model
{
    DetailViewController *vc = [[DetailViewController alloc]init];
    vc.data = model;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)searchText:(NSString *)city
{
    [self loadSearchResult:city];
}

-(void)selectCity
{
    [self chooseCityAction];
}

/**
 *  增加代码
 */
#pragma mark -
#pragma mark - UIBarButtonItems

- (void)setupMenuBarButtonItems {
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage createImageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage createImageWithColor:[UIColor clearColor]]];
    
    self.navigationItem.rightBarButtonItems = @[[self rightMenuBarButtonItem],[self rightMenuBarButtonItem1]];
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed &&
       ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
        self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    } else {
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"leftMenu.png"] style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)rightMenuBarButtonItem {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sweep"] style:UIBarButtonItemStyleDone target:self action:@selector(rightSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)rightMenuBarButtonItem1 {
    locationBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [locationBt addTarget:self action:@selector(locationBtPress:) forControlEvents:UIControlEventTouchUpInside];
    [locationBt setTitle:@"青岛" forState:UIControlStateNormal];
    UIImage *image = [UIImage imageNamed:@"locationtop"];
    [locationBt setTitleEdgeInsets:UIEdgeInsetsMake(0, -image.size.width+20, 0, image.size.width-10)];
    [locationBt setImageEdgeInsets:UIEdgeInsetsMake(0, locationBt.titleLabel.bounds.size.width, 0, -locationBt.titleLabel.bounds.size.width)];
    [locationBt setFrame:CGRectMake(0, 0, 70, 30)];
//    [button setBackgroundColor:[UIColor redColor]];
    [locationBt setImage:image forState:UIControlStateNormal];
    return [[UIBarButtonItem alloc] initWithCustomView:locationBt];
}


- (UIBarButtonItem *)backBarButtonItem {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow"]
                                            style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(backButtonPressed:)];
}


#pragma mark -
#pragma mark - UIBarButtonItem Callbacks

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

- (void)rightSideMenuButtonPressed:(id)sender

{
}

-(void)locationBtPress:(UIButton *)sender
{
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    if (context == CusomHeaderInsetObserver) {
        CGFloat inset = [change[NSKeyValueChangeNewKey] floatValue];
        if (inset <= 64) {
            self.title = @"首页";
            [self.navigationController.navigationBar setBackgroundImage:[UIImage createImageWithColor:NavigationColor] forBarMetrics:UIBarMetricsDefault];
        }else{
            self.title = nil;
            [self.navigationController.navigationBar setBackgroundImage:[UIImage createImageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
        }
        
    }
}

- (void)userLocationChangedAction
{
    [self updateAssociatedLatLonArray:resultArr];
    /**
     *  修改代码
     */
//    [_collectionView reloadData];
    [_mainView reloadData];
}

- (void)userCityAutoLocatedAction:(NSString*)locatedCity
{
    BOOL containsString = ([self->locationBt.titleLabel.text rangeOfString:CityLabelDefaultValue options:NSCaseInsensitiveSearch].location != NSNotFound);
    

    if (self->locationBt.titleLabel.text && !containsString && self.isCityLocated4Startup)
    {
        [self selectCityImplictly];
        
        return;
    }
    
    if ([locationBt.titleLabel.text isEqualToString:locatedCity])
    {
        [self selectCityImplictly];
        
        return;
    }

    self.autoLocatedCity = locatedCity;
    
    self.isCityLocated4Startup = YES;
}


- (void)PromptUser2Switch
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已经定位到您所在城市，是否切换？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    @weakify(self);
    [[alert rac_buttonClickedSignal] subscribeNext:^(id x) {
        @strongify(self);
        if ([x integerValue] == 1)
        {
            NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
            [userDef setObject:self.autoLocatedCity forKey:@"LastSelectedOrLocatedCity"];
            
            [userDef synchronize];
            
            
            self->_cityLabel.text = self.autoLocatedCity;
            CGSize s = [Tools returnSizeWithStr:self->_cityLabel.text andBaseSize:CGSizeMake(140, 44) andBaseFont:16];
            self->_cityLabel.frame = CGRectMake((160- s.width -20)/2, 0, s.width, 44);
            
            self->_cityArrowImg.frame = CGRectMake(CGRectGetMaxX(self->_cityLabel.frame) + 6, 20, 6, 4);
            
            [self selectCityImplictly];
            
            [self searchAndUpdateListWithKeyWord:self->_cityLabel.text secretly:NO];
        }
    }];
    
    [alert show];
}

- (void)PromptSwtichingCityWhenPossible
{
    @weakify(self);
    
    RACSignal *popupEnableSignal = [RACSignal combineLatest:@[RACObserve(self, isInForground), RACObserve(self, isCityLocated4Startup)]
                                                      reduce:^id(NSNumber *forground, NSNumber *located4Startup) {
                                                          return @([forground boolValue] && [located4Startup boolValue]);
                                                      }];
    

    [popupEnableSignal subscribeNext:^(NSNumber *active) {
        @strongify(self);
        if ([active boolValue])
        {
            if (self->isCitySwitchingPrompted)
            {
                return;
            }
            
            self->isCitySwitchingPrompted = YES;
            
            [self PromptUser2Switch];
        }
    }];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadData:YES];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self selectCityImplictly];
    
    self.isInForground   = false;
    
    [SVProgressHUD dismiss];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _searchField.text = @"";
}


- (void)willMove2Forground
{
   self.isInForground   = true;
}

- (void)willMove2Background
{
    [self selectCityImplictly];
    
    self.isInForground   = false;
    
    [SVProgressHUD dismiss];
}



- (void)processCollectionViewDataSource:(NSArray *)basicSource withOption:(bool) clearContent
{
    if (!cityLatLon || !resultArr || !basicSource)
    {
        return;
    }
    
    if (clearContent)
    {
        [cityLatLon removeAllObjects];
        [resultArr removeAllObjects];
    }
    
    [resultArr addObjectsFromArray:basicSource];
    
    [self updateAssociatedLatLonArray:resultArr];
 }

- (void)updateAssociatedLatLonArray:(NSArray*)basicArray
{
    if (!basicArray)
    {
        return;
    }
    
    NSUserDefaults * userDef = [NSUserDefaults standardUserDefaults];
    
  
    if (![userDef objectForKey:@"userLat"] ||
        ![userDef objectForKey:@"userLon"])
    {
        for (int i = 0; i < basicArray.count; i++)
        {
            [cityLatLon addObject:@"未知"];
        }
    }
    else
    {
        float latitude = [[userDef objectForKey:@"userLat"] doubleValue];
        float longitude = [[userDef objectForKey:@"userLon"] doubleValue];
        
        for (int i = 0; i < basicArray.count; i++)
        {
            ScenicArea *tempDara = [basicArray objectAtIndex:i];
        
            MAMapPoint point1 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(latitude, longitude));
            
            MAMapPoint point2 = MAMapPointForCoordinate(CLLocationCoordinate2DMake([tempDara.lat doubleValue],[tempDara.lng doubleValue]));
            
            CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
        
            [cityLatLon addObject:[NSString stringWithFormat:@"%f",distance]];
        }
    }
}

- (void)updateCollectionViewAt:(NSInteger)index withData:(ScenicArea*)data
{
    if (index < 0 || index >= resultArr.count || !data)
    {
        return;
    }
    
    [resultArr replaceObjectAtIndex:index withObject:data];
}



-(void)loadData:(bool)loadLastLocatedCity
{
    NSString *cityName = nil;

    if (loadLastLocatedCity)
    {
        NSUserDefaults * userDef = [NSUserDefaults standardUserDefaults];
        NSString *lastLocatedCity = [userDef objectForKey:@"LastSelectedOrLocatedCity"];
        self.lat = [userDef objectForKey:@"LastSelectedOrLocatedCityLat"];
        self.lon = [userDef objectForKey:@"LastSelectedOrLocatedCityLon"];

    

        if (lastLocatedCity)
        {
            [locationBt setTitle:lastLocatedCity forState:UIControlStateNormal];
            //修改代码
//            locationBt.titleLabel.text = lastLocatedCity;
            CGSize s = [Tools returnSizeWithStr:_cityLabel.text andBaseSize:CGSizeMake(140, 44) andBaseFont:16];
            _cityLabel.frame = CGRectMake((160- s.width -20)/2, 0, s.width, 44);
    
            _cityArrowImg.frame = CGRectMake(CGRectGetMaxX(_cityLabel.frame) + 6, 20, 6, 4);
        }
        
        cityName = lastLocatedCity;
    }
    else
    {
        cityName = locationBt.titleLabel.text;
        //修改代码
//        cityName = _cityLabel.text;
    }
    
 
    if (cityName)
    {
        self.lastCity = [NSString stringWithString:cityName];
    }
    
    
    if (!cityName || [cityName isEqualToString:CityLabelDefaultValue])
    {
//        [SVProgressHUD showWithOwner:@"MainViewController_getDefaultList"];
        
        __weak __typeof(self)weakSelf = self;
        [Interface getDefaultScenicListWithLimit:100 fromOffset:0 result:^(HomeListResponse *response, NSError *error){
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            
            if (!strongSelf)
            {
                return;
            }
            
//            [SVProgressHUD dismissFromOwner:@"MainViewController_getDefaultList"];
            
            if (response.status)
            {
                [strongSelf processCollectionViewDataSource:response.homeList withOption:YES];
                
                [self relodData];
                /**
                 *  修改代码
                 */
//                [strongSelf.collectionView reloadData];
                
                if (strongSelf.isInForground && strongSelf->resultArr.count <= 0)
                {
                    [UWindowHud hudWithType:kToastType withContentString:@"未能查找到景区！"];
                }
            }
            else
            {
                if (strongSelf.isInForground)
                {
                    [UWindowHud hudWithType:kToastType withContentString:@"网络不佳，请稍候重试！"];
                }
            }
        }];
    }
    else
    {
        [self searchAndUpdateListWithKeyWord:cityName secretly:NO];
    }
}


- (void)initCollectionView
{
    if (!_collectionView)
    {
        self.layout = [[CHTCollectionViewWaterfallLayout alloc] init];
        self.layout.headerHeight            = 0;
        self.layout.footerHeight            = 0;
        self.layout.minimumColumnSpacing    = 0;// 最小列间距
        self.layout.minimumInteritemSpacing = 0;
        self.layout.columnCount             = 1;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.titleView.bottom+40, App_Frame_Width, _defaultView.height - self.titleView.bottom - 49-40) collectionViewLayout:self.layout];
        _collectionView.dataSource      = self;
        _collectionView.delegate        = self;
        _collectionView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1];
        [_collectionView registerClass:[CHTCollectionViewWaterfallCell class]
            forCellWithReuseIdentifier:@"cell"];
        [_defaultView addSubview:_collectionView];
        
    }
    
//    __weak  MainViewController *weakSelf = self;
//    // 4.3行集成上拉加载更多控件
//    _footer = [MJRefreshFooterView footer];
//    _footer.scrollView = _collectionView;
//    // 进入上拉加载状态就会调用这个方法
//    _footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
//        __strong MainViewController *strongSelf = weakSelf;
//        
//        if (!strongSelf)
//        {
//            return;
//        }
//        [strongSelf loadData:NO];
//        [strongSelf performSelector:@selector(reloadDeals) withObject:nil afterDelay:1];
//    };
    
}
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return resultArr.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
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



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CHTCollectionViewWaterfallCell * cell = (CHTCollectionViewWaterfallCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    [cell.displayImg setFrame:CGRectMake(10, 10, cell.width - 20 , cell.width - 20)];
    [cell.spinner setFrame:CGRectMake(10, 10, cell.width - 20 , cell.width - 20)];
    [cell.spinner setImage:[UIImage imageNamed:@"spinner"]];
    [cell.spinner setContentMode:UIViewContentModeCenter];
    

    if (indexPath.row >= resultArr.count)
    {
        return cell;
    }
    
    ScenicArea *tempDara = [resultArr objectAtIndex:indexPath.row];
    
    [cell.infoView setFrame:CGRectMake(0, cell.displayImg.bottom, cell.width, 55)];
    
    NSString *strTitle = tempDara.scenicName;

    
    cell.spinner.hidden = YES;
    

    [cell.displayImg setShowActivityIndicatorView:YES];
    [cell.displayImg setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [cell.displayImg sd_setImageWithURL:[NSURL URLWithString:tempDara.smallImage] placeholderImage:[UIImage imageNamed:@"placeholder_common"]options:SDWebImageProgressiveDownload | SDWebImageRetryFailed];
    
  
    CGSize size = [[LabelSize labelsizeManger] getStringRect:strTitle MaxSize:CGSizeMake(cell.width - 40, 30) FontSize:!isColumnCountEqual2One ? 14 : 17];
    [cell.adNamelbl setFont:[UIFont systemFontOfSize:!isColumnCountEqual2One ? 14 : 17]];
    [cell.adNamelbl setFrame:CGRectMake(10, 5, size.width, size.height)];
    cell.adNamelbl.textColor = [UIColor colorWithRed:0x40/255.0f green:0x40/255.0f blue:0x40/255.0f alpha:1];
    [cell.adNamelbl setText:strTitle];
    
    cell.alarmButton.tag = indexPath.row;
    
    [self initAlarmButton:cell.alarmButton onPosition:CGRectMake(cell.adNamelbl.right + 5, 2, 25, 25) withWarningType:tempDara.warning];
    
    
    @weakify(self);
    cell.alarmButton.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(UIButton *btn) {
        @strongify(self);
        
        NSInteger scenicIndex = btn.tag;
        if (scenicIndex < 0 || scenicIndex >= self->resultArr.count)
        {
            return [RACSignal empty];
        }
        
        ScenicArea *currentScenicData = [self->resultArr objectAtIndex:scenicIndex];
        
        if (currentScenicData)
        {
            AlarmViewController * vc = [[AlarmViewController alloc]init];
            vc.data = currentScenicData;
            [self.navigationController pushViewController:vc animated:YES];
        }
        return [RACSignal empty];
    }];


    tempDara.scenicLevel = [tempDara.scenicLevel stringByReplacingOccurrencesOfString:@"A" withString:@""];
    NSMutableString * str = [[NSMutableString alloc] init];
    for (int i = 0 ; i < [tempDara.scenicLevel intValue]; i ++)
    {
        [str appendString:@"A"];
    }
    CGSize size1 = [[LabelSize labelsizeManger] getStringRect:str MaxSize:CGSizeMake(200, 30) FontSize:13];


    [cell.levellbl setFrame:CGRectMake(10, cell.adNamelbl.bottom + 5, size1.width, size1.height)];
    [cell.levellbl setText:str];
    
    CGSize size2 = [[LabelSize labelsizeManger] getStringRect:tempDara.scenicType MaxSize:CGSizeMake(200, 30) FontSize:13];
    [cell.levelCot setFrame:CGRectMake(cell.levellbl.right + 5, cell.adNamelbl.bottom + 5, size2.width, size2.height)];
    [cell.levelCot setText:tempDara.scenicType];
    cell.levelCot.textColor = [UIColor colorWithRed:0x40/255.0f green:0x40/255.0f blue:0x40/255.0f alpha:1];
    
    if (!isColumnCountEqual2One)
    {
        [cell.levelCot setHidden:YES];
        [cell.levellbl setHidden:YES];
    }
    else
    {
        [cell.levellbl setHidden:NO];
        [cell.levelCot setHidden:NO];
    }
 
    NSString *favoriteNumString = [NSString stringWithFormat:@"%@",tempDara.favourNum];
    CGSize size3 = [[LabelSize labelsizeManger] getStringRect:favoriteNumString MaxSize:CGSizeMake(200, 30) FontSize:13];
    [cell.loveLbl setFrame:CGRectMake( isColumnCountEqual2One ? ( cell.infoView.width - 15 - size3.width) : cell.infoView.width - 10 - size3.width, isColumnCountEqual2One ? 7 : cell.alarmButton.bottom +5, size3.width +5, size3.height)];
    [cell.loveLbl setText:[NSString stringWithFormat:@"%@",favoriteNumString]];
    cell.loveLbl.textColor = [UIColor colorWithRed:0xa0/255.0f green:0xaf/255.0f blue:0xb2/255.0f alpha:1];
    
    [cell.loveImg setFrame:CGRectMake(cell.loveLbl.left - 20,  cell.loveLbl.top, 15, 15)];
    [cell.loveImg setImage:[UIImage imageNamed:@"praise"]];
    
    cell.loveBtn.tag = indexPath.row;
    [cell.loveBtn setFrame:CGRectMake(cell.loveImg.left, cell.loveLbl.top, size3.width + 20, 15)];
    [cell.loveBtn addTarget:self action:@selector(loveAciton:) forControlEvents:(UIControlEventTouchUpInside)];

    
    if (indexPath.row < cityLatLon.count)
    {
        CGSize size4 = [[LabelSize labelsizeManger] getStringRect:[NSString stringWithFormat:@"距离%d千米",[cityLatLon[indexPath.row] intValue] / 1000] MaxSize:CGSizeMake(200, 30) FontSize:13];
        [cell.distanceLabel setFrame:CGRectMake(isColumnCountEqual2One ? (cell.infoView.width - 10 - size4.width):10,isColumnCountEqual2One ? (cell.loveBtn.bottom + 10) : cell.loveLbl.top, size4.width, size4.height)];
        [cell.distanceLabel setText:[NSString stringWithFormat:@"距离%d千米",[cityLatLon[indexPath.row] intValue] / 1000]];
        
        cell.distanceLabel.textColor = [UIColor colorWithRed:0xa0/255.0f green:0xaf/255.0f blue:0xb2/255.0f alpha:1];
    }
    
    [cell.lineImg setFrame:CGRectMake(0, cell.infoView.bottom, cell.width, 1)];

    if (!isColumnCountEqual2One)
    {
        [cell.lineSimg setHidden:NO];
        [cell.lineSimg setFrame:CGRectMake(0, 0, 1, cell.height)];
        if ([favoriteNumString intValue] < 1000) {
            [cell.loveLbl setText:[NSString stringWithFormat:@"%@",favoriteNumString]];

        }
        else if ([favoriteNumString intValue] > 1000 && [favoriteNumString intValue] < 10000) {
            [cell.loveLbl setText:[NSString stringWithFormat:@"%dK+",[favoriteNumString intValue]/1000]];
        }
        else
        {
            [cell.loveLbl setText:[NSString stringWithFormat:@"%dW+",[favoriteNumString intValue]/10000]];
        }

    }
    else
    {
        [cell.lineSimg setHidden:YES];
        [cell.loveLbl setText:[NSString stringWithFormat:@"%@",favoriteNumString]];
    }
    return cell;
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (isColumnCountEqual2One)
    {
        return CGSizeMake(App_Frame_Width, (App_Frame_Width )+ 45);
    }
    else
    {
        return CGSizeMake(App_Frame_Width /2 , App_Frame_Width/2 + 50);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath || indexPath.row >= resultArr.count)
    {
        return;
    }
    
    [self selectCityImplictly];
    
    DetailViewController *vc = [[DetailViewController alloc]init];
    vc.data = [resultArr objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)selectCityImplictly
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    
    NSString *nonSpacingText = [locationBt.titleLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [userDef setObject:nonSpacingText forKey:@"LastSelectedOrLocatedCity"];
    
    [userDef synchronize];
}

#pragma mark - button click


- (void)loveAciton:(UIButton *)sender
{
    if (![User isLoggedIn])
    {
        LoginViewController *login = [[LoginViewController alloc] init];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:login];
        loginNav.navigationBarHidden = YES;
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
    }
    else
    {
        ScenicArea *tempDara = [resultArr objectAtIndex:sender.tag];
        
        __weak MainViewController *weakSelf = self;

        
//        [SVProgressHUD showWithOwner:@"MainViewController_praise"];
        

        [Interface praiseScenic:tempDara.scenicId UserID:[User sharedInstance].userid result:^(PraiseScenicResponse *response, NSError *error) {
             __strong MainViewController *strongSelf = weakSelf;
 
            if (!strongSelf)
            {
                return;
            }
            
//            [SVProgressHUD dismissFromOwner:@"MainViewController_praise"];
            
            if(response.status == 1)
            {
                int num = [tempDara.favourNum intValue];
                num = num +1;
                tempDara.favourNum = [NSString stringWithFormat:@"%d",num];
                
                [strongSelf updateCollectionViewAt:sender.tag withData:tempDara];

                [strongSelf.collectionView reloadData];
                [UWindowHud hudWithType:kToastType withContentString:@"点赞成功！"];
            }
            else if (response.status == 0)
            {
                [UWindowHud hudWithType:kToastType withContentString:@"已点赞，不能重复！"];
            }
            else if (response.status == 2)
            {
                [UWindowHud hudWithType:kToastType withContentString:@"网络不通，请重试！"];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



#pragma mark title btn
- (void)creatTitleBtn
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake((App_Frame_Width - 160)/2, 0, 160, 44)];
    titleView.backgroundColor = [UIColor clearColor];
    
    [self.titleView addSubview:titleView];
    
    NSString *cityName = CityLabelDefaultValue;
    _cityLabel = [[UILabel alloc] initWithFrame:CGRectMake((titleView.frame.size.width - cityName.length *20)/2, 0, cityName.length *20, 44)];
    _cityLabel.text = CityLabelDefaultValue;
    _cityLabel.backgroundColor = [UIColor clearColor];
    _cityLabel.textAlignment   = NSTextAlignmentCenter;
    _cityLabel.font            = [UIFont systemFontOfSize:16];
    _cityLabel.textColor       = [UIColor colorWithRed:0x40/255.0f green:0x40/255.0f blue:0x40/255.0f alpha:1];
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

- (void)layoutTitleNewFrame
{
    _cityLabel.frame = CGRectMake((160 - _cityLabel.text.length * 20 - 20)/2, _cityLabel.frame.origin.y, _cityLabel.text.length * 20, _cityLabel.frame.size.height);
    _cityArrowImg.frame = CGRectMake(CGRectGetMaxX(_cityLabel.frame) + 6, _cityArrowImg.frame.origin.y, 6, 4);
}

#pragma mark 弹出选择城市
- (void)chooseCityAction
{
    SearchCityViewController *vv = [[SearchCityViewController alloc]init];
    vv.selectCity = _cityLabel.text;
    [self.navigationController pushViewController:vv animated:YES];
    
    __weak MainViewController *weakSelf = self;
    [vv selectCityAction:^(CityModel *cityModel) {
        __strong MainViewController *strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }
        
        strongSelf->search.text = @"";
        
        strongSelf.lat = cityModel.citylat;
        strongSelf.lon = cityModel.citylng;
        
        [strongSelf->resultArr removeAllObjects];
        [strongSelf->cityLatLon removeAllObjects];
        [strongSelf.collectionView reloadData];
        strongSelf.lastCity = [NSString stringWithString:cityModel.cityName];
        [strongSelf selectCityFromList:cityModel.cityName latitude:cityModel.citylat longitude:cityModel.citylng];
 
        [strongSelf layoutTitleNewFrame];
    }];
}

- (void)selectCityFromList:(NSString*)cityName latitude:(NSString*)cityLat longitude:(NSString*)cityLon
{
    if (!cityName)
    {
        return;
    }
    
    _cityLabel.frame = CGRectMake(_cityLabel.frame.origin.x,
                                  _cityLabel.frame.origin.y,
                                  cityName.length*20,
                                  _cityLabel.frame.size.height);
    
    _cityLabel.text = cityName;
    
    _searchField.text = @"";
    
    lastLocatedOrSelectedCity = [NSString stringWithString:cityName];
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setObject:cityName forKey:@"LastSelectedOrLocatedCity"];
    [userDef setObject:cityLat forKey:@"LastSelectedOrLocatedCityLat"];
    [userDef setObject:cityLon forKey:@"LastSelectedOrLocatedCityLon"];
    [userDef synchronize];
    
    isCitySelectedFromList = YES;
}


#pragma mark 刷新
- (void)reloadDeals
{
    // 结束刷新状态
//    [_footer endRefreshing];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yy = scrollView.contentOffset.y;
    
    if (yy > 120.0)
    {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
    
}



- (void)loadSearchResult:(NSString *)searchText
{
    NSString *nonSpacingText = [searchText stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    /**
     *  增加代码
     */
    [locationBt setTitle:searchText forState:UIControlStateNormal];
//    _cityLabel.text = nonSpacingText;//CityLabelDefaultValue;
//    CGSize s = [Tools returnSizeWithStr:_cityLabel.text andBaseSize:CGSizeMake(140, 44) andBaseFont:16];
//    _cityLabel.frame = CGRectMake((160- s.width -40)/2, 0, s.width, 44);
    
    

    NSString *transString =  (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)nonSpacingText, NULL, NULL,  kCFStringEncodingUTF8 ));
    
    __weak MainViewController *weakSelf = self;
    
    
//    [SVProgressHUD showWithOwner:@"MainViewController_loadHomeSearch"];
    
    [Interface searchHomeListWithKey:transString result:^(HomeListResponse *response, NSError *error) {
         __strong MainViewController *strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }
        
//        [SVProgressHUD dismissFromOwner:@"MainViewController_loadHomeSearch"];
        
        if (response.status)
        {
            [strongSelf processCollectionViewDataSource:response.homeList withOption:YES];
            
            //改变代码
            if (resultArr.count > 0) {
                [self relodData];
            }
//            [strongSelf.collectionView reloadData];
            
            if (strongSelf.isInForground && strongSelf->resultArr.count <= 0)
            {
                [UWindowHud hudWithType:kToastType withContentString:@"未能查找到景区！"];
            }
        }
        else
        {
            if (strongSelf.isInForground)
            {
                [UWindowHud hudWithType:kToastType withContentString:@"网络不佳，请稍候重试！"];
            }
        }
        
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }];
}


- (void)searchAndUpdateListWithKeyWord:(NSString *)keyWord secretly:(BOOL)secretly
{
//    _footer.scrollView = nil;
    NSString *transString =  (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)keyWord, NULL, NULL,  kCFStringEncodingUTF8 ));
    
    
    __weak MainViewController *weakSelf = self;
    
    
    if (!secretly)
    {
//        [SVProgressHUD showWithOwner:@"MainViewController_searchAndUpdateListWithKeyWord"];
    }
    
    [Interface searchHomeListWithKey:transString result:^(HomeListResponse *response, NSError *error) {
         __strong MainViewController *strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }
        
        if (!secretly)
        {
//            [SVProgressHUD dismissFromOwner:@"MainViewController_searchAndUpdateListWithKeyWord"];
        }
        

        if (response.status)
        {
            [strongSelf processCollectionViewDataSource:response.homeList withOption:YES];
            /**
             *  修改代码
             */
            [self relodData];
            //[strongSelf.collectionView reloadData];
            
            [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        }
        else
        {
            if (strongSelf.isInForground)
            {
                [UWindowHud hudWithType:kToastType withContentString:@"网络不通，请稍后重试！"];
            }
        }
        
    }];
}

@end
