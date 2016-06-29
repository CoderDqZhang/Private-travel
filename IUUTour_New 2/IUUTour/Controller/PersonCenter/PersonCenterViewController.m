#import "PersonCenterViewController.h"
#import "CExpandHeader.h"               //下拉 上拉动画效果
#import "EditePersonViewController.h"   //编辑基本信息
#import "ReSetPassWordViewController.h" //重设密码
#import "LeaveMessageViewController.h"  //我的留言墙
#import "MapManageViewController.h"     //地图管理
#import "SetViewController.h"           //设置
#import "LoginViewController.h"
#import "MyShareViewController.h"       //我的分享
#import "LuckyViewController.h"


#import "MFSideMenu.h"
#import "GBPathImageView.h"
#import "CustomButton.h"
#import "ReactiveCocoa.h"


#define ListUpX 250

@interface PersonCenterViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    CExpandHeader * _header;
    UILabel       * namelbl;
    UILabel       * agelbl;
    UIImageView   * sexImg;

    int           prizeCount;
    int           mapCount;
    int           messageCount;
    int           shareCount;
    
    BOOL          isLuckyDrawerSupport;
    
    
    UILabel       *userName;
    GBPathImageView *squareImage;
}
@property (nonatomic,retain) NSMutableArray *listItemNameArray;
@property (nonatomic,retain) NSArray        *listItemImageArray;
@property (nonatomic,retain) NSMutableArray *listItemStatisticsArray;

@property (nonatomic)NSInteger myCommentsCount;

@end

@implementation PersonCenterViewController


- (void)loadDefaultListDataWithLuckyDrawer
{
    prizeCount = -1;
    
    NSArray * paths       = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString * path       = [paths  objectAtIndex:0];
    NSString * filePath   = [path stringByAppendingPathComponent:@"leaveMapData.plist"];
    NSMutableArray * aray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    mapCount              = (int)aray.count;
    
    NSString *messagefilePath      = [path stringByAppendingPathComponent:@"leavemessage.plist"];
    NSMutableArray *messageListArr = [[NSMutableArray alloc] initWithContentsOfFile:messagefilePath];
    messageCount                   = (int)messageListArr.count;
    
    NSString *sharefilePath        = [path stringByAppendingPathComponent:@"shareContent.plist"];
    NSMutableArray *shareListArr   = [[NSMutableArray alloc] initWithContentsOfFile:sharefilePath];
    shareCount                     = (int)shareListArr.count;
    
    self.listItemNameArray       = nil;
    self.listItemStatisticsArray = nil;
    self.listItemImageArray      = nil;
    
    self.listItemNameArray       = [[NSMutableArray alloc]initWithObjects:@"地图管理",@"天天有礼",@"我的留言墙",@"我的分享", nil];
    
    if ([User sharedInstance].userid)
    {
        self.listItemStatisticsArray = [[NSMutableArray alloc]initWithObjects:
                                          [NSString stringWithFormat:@"%ld",(unsigned long)self->mapCount],
                                          [NSString stringWithFormat:@"%@", @"获取中"],
                                          [NSString stringWithFormat:@"%ld",(unsigned long)self->messageCount],
                                          [NSString stringWithFormat:@"%ld",(unsigned long)self->shareCount], nil];
    }
    else
    {
        self.listItemStatisticsArray = [[NSMutableArray alloc]initWithObjects:
                                        [NSString stringWithFormat:@"%ld",(unsigned long)self->mapCount],
                                        [NSString stringWithFormat:@"%@", @"未登录"],
                                        [NSString stringWithFormat:@"%ld",(unsigned long)self->messageCount],
                                        [NSString stringWithFormat:@"%ld",(unsigned long)self->shareCount], nil];
    }
    
    self.listItemImageArray      = @[@"me_map.png",@"me_personality",@"me_message.png",@"me_share.png"];
    
    [self.pPersonTable reloadData];
}

- (void)loadDefaultListDataWithoutLuckyDrawer
{
    prizeCount = -1;
    
    NSArray * paths       = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString * path       = [paths  objectAtIndex:0];
    NSString * filePath   = [path stringByAppendingPathComponent:@"leaveMapData.plist"];
    NSMutableArray * aray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    mapCount              = (int)aray.count;
    
    NSString *messagefilePath      = [path stringByAppendingPathComponent:@"leavemessage.plist"];
    NSMutableArray *messageListArr = [[NSMutableArray alloc] initWithContentsOfFile:messagefilePath];
    messageCount                   = (int)messageListArr.count;
    
    NSString *sharefilePath        = [path stringByAppendingPathComponent:@"shareContent.plist"];
    NSMutableArray *shareListArr   = [[NSMutableArray alloc] initWithContentsOfFile:sharefilePath];
    shareCount                     = (int)shareListArr.count;
    
    self.listItemNameArray       = nil;
    self.listItemStatisticsArray = nil;
    self.listItemImageArray      = nil;
    
    self.listItemNameArray = [[NSMutableArray alloc]initWithObjects:@"地图管理",@"我的留言墙",@"我的分享", nil];
    self.listItemStatisticsArray = [[NSMutableArray alloc]initWithObjects:
                                    [NSString stringWithFormat:@"%ld", (unsigned long)self->mapCount],
                                    [NSString stringWithFormat:@"%ld", (unsigned long)self->messageCount],
                                    [NSString stringWithFormat:@"%ld", (unsigned long)self->shareCount], nil];
    self.listItemImageArray = @[@"me_map.png",@"me_message.png",@"me_share.png"];
    
    [self.pPersonTable reloadData];
}

//#define LUCKY_DRAWER_ALWAYS_ON
-(void)updateListData
{
    prizeCount = -1;
    
    BOOL isPublished = NO;
    
#ifdef LUCKY_DRAWER_ALWAYS_ON
    isPublished = YES;
#endif
    
#ifdef LUCKY_DRAWER_ALWAYS_ON
    if (isPublished)
    {
        self->isLuckyDrawerSupport = YES;
        
        [self loadDefaultListDataWithLuckyDrawer];
        
        if ([User sharedInstance].userid && [User sharedInstance].userid.length > 0)
        {
            [SVProgressHUD showWithOwner:@"LuckyViewController_queryMyPrizeList"];
            

            __weak __typeof(self) weakSelf = self;
            [Interface queryMyPrizeList:^(LotteryWinnerListResponse *response, NSError *error) {
                
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                
                if (!strongSelf)
                {
                    [SVProgressHUD dismissFromOwner:@"LuckyViewController_queryMyPrizeList"];
                    
                    return;
                }
                
                
                if (response.status)
                {
                    strongSelf->prizeCount = (int)response.winnerList.count;
                    
                    
                    strongSelf.listItemStatisticsArray = [[NSMutableArray alloc]initWithObjects:
                                                           [NSString stringWithFormat:@"%ld", (unsigned long)strongSelf->mapCount],
                                                           [NSString stringWithFormat:@"%ld", (unsigned long)strongSelf->prizeCount],
                                                           [NSString stringWithFormat:@"%ld", (unsigned long)strongSelf->messageCount],
                                                           [NSString stringWithFormat:@"%ld", (unsigned long)strongSelf->shareCount], nil];
                }
                else
                {
                    strongSelf.listItemStatisticsArray = [[NSMutableArray alloc]initWithObjects:
                                                           [NSString stringWithFormat:@"%ld", (unsigned long)strongSelf->mapCount],
                                                           [NSString stringWithFormat:@"%@", @"请稍候重试"],
                                                           [NSString stringWithFormat:@"%ld", (unsigned long)strongSelf->messageCount],
                                                           [NSString stringWithFormat:@"%ld", (unsigned long)strongSelf->shareCount], nil];
                }
                
                [strongSelf.pPersonTable reloadData];
                
                [SVProgressHUD dismissFromOwner:@"LuckyViewController_queryMyPrizeList"];
            }];
        }
        else
        {
            [self loadDefaultListDataWithLuckyDrawer];
            
            [self.pPersonTable reloadData];
        }
    }
    else
    {
        [self loadDefaultListDataWithoutLuckyDrawer];
        
        [self.pPersonTable reloadData];
    }
    
#else
    self.listItemNameArray       = nil;
    self.listItemStatisticsArray = nil;
    self.listItemImageArray      = nil;
    
    self.listItemNameArray       = [[NSMutableArray alloc]initWithObjects:@"地图管理",@"我的留言墙",@"我的分享", nil];
    self.listItemStatisticsArray = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"%ld",(unsigned long)mapCount],
                                          [NSString stringWithFormat:@"%ld",(unsigned long)messageCount],
                                          [NSString stringWithFormat:@"%ld",(unsigned long)shareCount], nil];
    self.listItemImageArray      = @[@"me_map.png",@"me_message.png",@"me_share.png"];

    [self.pPersonTable reloadData];
#endif
}



- (void)loggedInFromLoginViewController
{
    [self loadLocalProfile];
    
    if (!isLuckyDrawerSupport)
    {
        [self loadDefaultListDataWithoutLuckyDrawer];
    }
    else
    {
        [self loadDefaultListDataWithLuckyDrawer];
    }
    
    [self refreshData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
//    self.myCommentsCount = 0;
//    
//    isLuckyDrawerSupport = NO;
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedInFromLoginViewController) name:@"LoggedInFromLoginViewController" object:nil];
//    
//    prizeCount            = -1;
//
//    self.titleView.hidden = YES;
//
//
//    self.pPersonTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, App_Frame_Width, _defaultView.height-49) style:(UITableViewStylePlain)];
//    self.pPersonTable.delegate        = self;
//    self.pPersonTable.dataSource      = self;
//    self.pPersonTable.tableHeaderView = [self createPersonTableHead];
//    self.pPersonTable.tableFooterView = [[UIView alloc]init];
//    self.pPersonTable.backgroundColor = [UIColor clearColor];
//    [_defaultView addSubview:self.pPersonTable];
//    
//
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 200)];
//    [imageView setImage:[UIImage imageNamed:@"image"]];
//    imageView.userInteractionEnabled = YES;
//    _header = [CExpandHeader expandWithScrollView:self.pPersonTable expandView:imageView];
//    
//
//    UIView* profileImageView = [self createProfileImageView];
//    [_defaultView addSubview:profileImageView];
//    
//
//    [self loadLocalProfile];
//    
//
//    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [leftBtn setFrame:CGRectMake(10.0f, 20.0f, 44.0f, 44.0f)];
//    [leftBtn setImage:[UIImage imageNamed:@"me_setting"] forState:UIControlStateNormal];
//    [leftBtn setBackgroundColor:[UIColor clearColor]];
//    [leftBtn addTarget:self action:@selector(leftAction) forControlEvents:UIControlEventTouchUpInside];
//    [_defaultView addSubview:leftBtn];
//    
//
//    [self createPersonInfoListView];
//    
//    
//    [self loadDefaultListDataWithoutLuckyDrawer];
    [self setupMenuBarButtonItem];
    
    [self setupProfileView];
}


-(void)setupProfileView
{
    
    UIView *proView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, App_Frame_Height)];
    [proView setBackgroundColor:PerSonBgColor];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSURL *portraitUrl = [NSURL URLWithString:[User sharedInstance].userpic];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:portraitUrl
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (image) {
                                    
                                    squareImage = [[GBPathImageView alloc] initWithFrame:CGRectMake((App_Frame_Width-72.5)/2, (90.5+72.5)/2, 72.5, 72.5) image:image pathType:GBPathImageViewTypeCircle pathColor:[UIColor clearColor] borderColor:[UIColor clearColor] pathWidth:0.1];
                                    [proView addSubview:squareImage];
                                }
                            }];
    });
    userName = [[UILabel alloc] initWithFrame:CGRectMake(0, 173.5, App_Frame_Width, 25)];
    userName.text = [User sharedInstance].nickname;
    
    userName.textAlignment = NSTextAlignmentCenter;
    userName.textColor = [UIColor whiteColor];
    [proView addSubview:userName];
    
    [self.view addSubview:proView];
    
    
    UIImage *image = [UIImage imageNamed:@"top_bg"];
    UIImageView *topBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, image.size.height*App_Frame_Width/image.size.width)];
    topBg.image = image;
    [proView addSubview:topBg];
    
    [self setupBt:proView];
    
}


-(void)setupBt:(UIView *)proView
{
    CustomButton *leaveMessageBt = [[CustomButton alloc] initWithFrame:CGRectMake(App_Frame_Width/2 - 116, userName.frame.size.height+userName.frame.origin.y + 42, 114, 122)];
    [leaveMessageBt setImage:[UIImage imageNamed:@"ic_ leavemessagewall"] forState:UIControlStateNormal];
    [leaveMessageBt setTitle:@"我的留言墙" forState:UIControlStateNormal];
    [[leaveMessageBt rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x){
        [self.navigationController pushViewController:[[LeaveMessageViewController alloc] init] animated:YES];
//        [self presentViewController:[[LeaveMessageViewController alloc] init] animated:YES completion:nil];
    }];
    [proView addSubview:leaveMessageBt];
    
    CustomButton *shareBt = [[CustomButton alloc] initWithFrame:CGRectMake(App_Frame_Width/2 + 2, userName.frame.size.height+userName.frame.origin.y + 42, 114, 122)];
    [shareBt setImage:[UIImage imageNamed:@"ic_share"] forState:UIControlStateNormal];
    [shareBt setTitle:@"我的分享" forState:UIControlStateNormal];
    [[shareBt rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x){
        [self.navigationController pushViewController:[[MyShareViewController alloc] init] animated:YES];
//        [self presentViewController:[[MyShareViewController alloc] init] animated:YES completion:nil];
    }];
    [proView addSubview:shareBt];
    
    CustomButton *editBt = [[CustomButton alloc] initWithFrame:CGRectMake(App_Frame_Width/2 - 116, leaveMessageBt.frame.size.height+leaveMessageBt.frame.origin.y + 2, 114, 122)];
    [editBt setImage:[UIImage imageNamed:@"ic_edit"] forState:UIControlStateNormal];
    [[editBt rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x){
        [self.navigationController pushViewController:[[EditePersonViewController alloc] init] animated:YES];
//        [self presentViewController:[[EditePersonViewController alloc] init] animated:YES completion:nil];
    }];
    [editBt setTitle:@"编辑基本信息" forState:UIControlStateNormal];
    [proView addSubview:editBt];
    
    CustomButton *resetPasswordBt = [[CustomButton alloc] initWithFrame:CGRectMake(App_Frame_Width/2 + 2, editBt.frame.origin.y, 114, 122)];
    [resetPasswordBt setImage:[UIImage imageNamed:@"ic_password"] forState:UIControlStateNormal];
    [resetPasswordBt setTitle:@"重置密码" forState:UIControlStateNormal];
    [[resetPasswordBt rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x){
        [self.navigationController pushViewController:[[ReSetPassWordViewController alloc] init] animated:YES];
//        [self presentViewController:[[ReSetPassWordViewController alloc] init] animated:YES completion:nil];
    }];
    [proView addSubview:resetPasswordBt];
    
    
    UIButton *loginOut = [UIButton buttonWithType:UIButtonTypeCustom];
//    loginOut.layer.borderColor = [[UIColor colorWithRed:96/255 green:96/255 blue:96/255 alpha:1.0] CGColor];
//    loginOut.backgroundColor = [UIColor colorWithRed:15/255 green:255/255 blue:255/255 alpha:0.2];
    loginOut.layer.borderColor = [[UIColor grayColor] CGColor];
    loginOut.frame = CGRectMake(30, App_Frame_Height - 74, App_Frame_Width - 60, 44) ;
    loginOut.layer.borderWidth = 1.0;
    [loginOut setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    loginOut.layer.cornerRadius = 4;
    [[loginOut rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x){
        [User logout];
        if ([User sharedInstance].clearMyCenterDataBlock)
        {
            [User sharedInstance].clearMyCenterDataBlock();
        }
        [_image setImage:[UIImage imageNamed:@"me_Icon"]];
        
        if (!isLuckyDrawerSupport)
        {
            [self loadDefaultListDataWithoutLuckyDrawer];
        }
        else
        {
            [self loadDefaultListDataWithLuckyDrawer];
        }
        userName.text = @"";
        squareImage.image = [UIImage imageNamed:@""];
        BaseNavigationController *baseNav = [[BaseNavigationController alloc] initWithRootViewController:[[MainViewController alloc]init]];
        self.menuContainerViewController.centerViewController = baseNav;
        [_delegate loginOut];
        [self backAciton];
    }];

    [loginOut setTitle:@"退出登录" forState:UIControlStateNormal];
    [proView addSubview:loginOut];
    
}

/**
 *  增加代码
 */
#pragma mark -
#pragma mark - UIBarButtonItems

- (void)setupMenuBarButtonItem{
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage createImageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage createImageWithColor:[UIColor clearColor]]];
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
        [self setupMenuBarButtonItem];
    }];
}


- (UIView*)createPersonTableHead
{
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, App_Frame_Width, 100)];
    view.backgroundColor = [UIColor whiteColor];
    
    return view;
}



- (UIView *)createProfileImageView
{
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 150, App_Frame_Width, 100)];
    UIColor *whiteTransparentColor = [ [ UIColor alloc ]initWithWhite: 1.0 alpha: 0];
    view.backgroundColor = whiteTransparentColor;//[UIColor whiteColor];
    _image = [[UIImageView alloc]initWithFrame:CGRectMake(App_Frame_Width/2 - 50, 0, 100, 100)];
    
    
    if (![User sharedInstance].userid)
    {
        [_image setImage:[UIImage imageNamed:@"me_Icon"]];
    }
    else
    {
        [_image setShowActivityIndicatorView:YES];
        [_image setIndicatorStyle:UIActivityIndicatorViewStyleGray];
        NSString *headUrl = [Interface getHeadImgUrl];
        [_image sd_setImageWithURL:[NSURL URLWithString:headUrl] placeholderImage:[UIImage imageNamed:@"me_Icon"] options:SDWebImageProgressiveDownload | SDWebImageRetryFailed];
    }
    
    
    [_image.layer setCornerRadius:_image.height/2];
    [_image.layer setMasksToBounds:YES];
    [_image setContentMode:UIViewContentModeScaleAspectFill];
    [_image setUserInteractionEnabled:YES];
    [view addSubview:_image];
    
    UITapGestureRecognizer * imageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageTapclick:)];
    [_image addGestureRecognizer:imageTap];
    return view;
}


- (void)createPersonInfoListView
{
    self.personInfoView = [[UIView alloc]initWithFrame:CGRectMake(0, _defaultView.bottom, App_Frame_Width, _defaultView.height - 300)];
    self.personInfoView.backgroundColor = [UIColor whiteColor];
    [_defaultView addSubview:self.personInfoView];
    
    namelbl               = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, App_Frame_Width, 30)];
    namelbl.font          = [UIFont systemFontOfSize:15];
    namelbl.textAlignment = NSTextAlignmentCenter;
    namelbl.textColor     = [UIColor colorWithRed:0x40/255.0f green:0x40/255.0f blue:0x40/255.0f alpha:1];
    namelbl.text          = [User sharedInstance].loginName;
    [self.personInfoView addSubview:namelbl];
    
    CGSize nameSize =[[LabelSize labelsizeManger]getStringRect:namelbl.text  MaxSize:CGSizeMake(App_Frame_Width, 30) FontSize:15];
    sexImg = [[UIImageView alloc]initWithFrame:CGRectMake(App_Frame_Width/2.0 + nameSize.width/2.0 + 5, 20, 6, 12)];
    sexImg.backgroundColor = [UIColor clearColor];

    if ([[User sharedInstance].sex isEqualToString:@"1"])
    {
        sexImg.image = [UIImage imageNamed:@"me_man"];
    }
    else
    {
        sexImg.image = [UIImage imageNamed:@"me_woman"];
    }

    [self.personInfoView addSubview:sexImg];
    
    agelbl                 = [[UILabel alloc]initWithFrame:CGRectMake(0, namelbl.bottom, self.personInfoView.width, 20)];
    agelbl.font            = [UIFont systemFontOfSize:15];
    agelbl.textAlignment   = NSTextAlignmentCenter;
    agelbl.textColor       = [UIColor colorWithRed:0x40/255.0f green:0x40/255.0f blue:0x40/255.0f alpha:1];
    agelbl.backgroundColor = [UIColor clearColor];


    NSString *address = @"";
    NSString *age     = @"";
    if ([User sharedInstance].address.length == 0)
    {
        address = @"";
    }
    else
    {
        address = [NSString stringWithFormat:@"%@",[User sharedInstance].address];
    }
    if([User sharedInstance].age.length == 0)
    {
        age = @"0";
    }
    else
    {
        age = [NSString stringWithFormat:@"%@",[User sharedInstance].age];
    }
    
    agelbl.text = [NSString stringWithFormat:@"%@岁、%@",age,address];

    
    [self.personInfoView addSubview:agelbl];
    
    float starHeight = 13;
    float starWidth  = 13;
    
    for (int i = 0; i < 5; i ++)
    {
        UIImageView * starImg = [[UIImageView alloc]initWithFrame:CGRectMake(self.personInfoView.width/2 - 50 + i * 22, agelbl.bottom, starWidth, starHeight)];
        starImg.image  = ([[User sharedInstance].level intValue]<=i)?[UIImage imageNamed:@"star_gray"]:[UIImage imageNamed:@"star_red"];
        [self.personInfoView addSubview:starImg];
    }
    
    float personInfoMaxHeigt   = self.view.bottom - ListUpX - 49;//49 is height of toolbar below
    float usedHeight           = namelbl.height + agelbl.height + starHeight;
    float remainingHeight      = personInfoMaxHeigt - usedHeight;
    float listItemButtonHeight = 30;
    float initialSpanning      = (remainingHeight - listItemButtonHeight * 3) / 2.0f;
    
    
    NSArray * array = [[NSArray alloc]initWithObjects:@"编辑基本信息",@"重置密码",@"退出登陆", nil];
    for (int i = 0; i < 3; i++)
    {
        UIButton * button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
        button.titleLabel.textColor = [UIColor colorWithRed:0x1d/255.0f green:0x9f/255.0f blue:0xd3/255.0f alpha:1];
        [button setFrame:CGRectMake(0, (agelbl.bottom + initialSpanning) + i * listItemButtonHeight, self.personInfoView.width, 20)];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setTag:i];
        [button setTitle:[array objectAtIndex:i] forState:(UIControlStateNormal)];
        [button setTitleColor:FontColorA forState:(UIControlStateNormal)];
        [button addTarget:self action:@selector(buttonActon:) forControlEvents:(UIControlEventTouchUpInside)];
        [self.personInfoView addSubview:button];
    }
    
    UIButton * backBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [backBtn setFrame:CGRectMake(self.personInfoView.width/2 - 15, self.personInfoView.height - 35, 30, 30)];
    [backBtn setImage:[UIImage imageNamed:@"me_downarrow"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAciton) forControlEvents:(UIControlEventTouchUpInside)];
    [self.personInfoView addSubview:backBtn];
}



-(void)refreshData
{
    [self loadRemoteProfile];
    
    [self updateListData];
    
    [self.pPersonTable reloadData];
    
    
    namelbl.text =  [User sharedInstance].loginName;
    namelbl.textColor = [UIColor colorWithRed:0x40/255.0f green:0x40/255.0f blue:0x40/255.0f alpha:1];
    
    CGSize nameSize =[[LabelSize labelsizeManger]getStringRect:namelbl.text  MaxSize:CGSizeMake(App_Frame_Width, 30) FontSize:15];
    [sexImg setFrame:CGRectMake(App_Frame_Width/2.0 + nameSize.width/2.0 + 5, 20, 6, 12)];
    //sexImg = [[UIImageView alloc]initWithFrame:CGRectMake(App_Frame_Width/2.0 + nameSize.width/2.0 + 5, 20, 6, 12)];
    
    if ([[User sharedInstance].sex isEqualToString:@"1"])
    {
        sexImg.image = [UIImage imageNamed:@"me_man.png"];
    }
    else
    {
        sexImg.image = [UIImage imageNamed:@"me_woman.png"];
    }


    NSString *address = @"";
    NSString *age     = @"";
    if ([User sharedInstance].address.length == 0)
    {
        address = @"";
    }
    else
    {
        address = [NSString stringWithFormat:@"%@",[User sharedInstance].address];
    }
    if([User sharedInstance].age.length == 0)
    {
        age = @"0";
    }
    else
    {
        age = [NSString stringWithFormat:@"%@",[User sharedInstance].age];
    }
    
    agelbl.text = [NSString stringWithFormat:@"%@岁、%@",age,address];
    agelbl.textColor = [UIColor colorWithRed:0x40/255.0f green:0x40/255.0f blue:0x40/255.0f alpha:1];
    

    [self backAciton];
}


- (void)loadLocalProfile
{
    if (![User sharedInstance].userid)
    {
        [_image setImage:[UIImage imageNamed:@"me_Icon"]];
    }
    else
    {
        __weak __typeof(self)weakSelf = self;
        [Interface getLocalHeadImg:^(NSData *headData, NSError *error) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            
            if (!strongSelf)
            {
                return;
            }
            
            UIImage *image = [[UIImage alloc] initWithData:headData];
            if (image && image.size.width > 10)
            {
                [strongSelf->_image setImage:image];
            }
            else
            {
                [strongSelf->_image setImage:[UIImage imageNamed:@"me_Icon"]];
            }
        }];
    }
}

- (void)loadRemoteProfile
{
    if (![User sharedInstance].userid)
    {
        [_image setImage:[UIImage imageNamed:@"me_Icon"]];
    }
    else
    {
        [_image setShowActivityIndicatorView:YES];
        [_image setIndicatorStyle:UIActivityIndicatorViewStyleGray];
        NSString *headUrl = [Interface getHeadImgUrl];
        [_image sd_setImageWithURL:[NSURL URLWithString:headUrl] placeholderImage:[UIImage imageNamed:@"me_Icon"] options:SDWebImageProgressiveDownload | SDWebImageRetryFailed];
    }
}


#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listItemNameArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * pString = @"PersonTable";
    UITableViewCell * cell    = [tableView dequeueReusableCellWithIdentifier:pString];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:pString];
    }
    cell.imageView.image      = [UIImage imageNamed:[self.listItemImageArray objectAtIndex:indexPath.row]];
    cell.textLabel.text       = [self.listItemNameArray objectAtIndex:indexPath.row];
    cell.textLabel.font       = [UIFont systemFontOfSize:15];
    if ((self.listItemStatisticsArray.count == 4 && indexPath.row == 2) ||
        (self.listItemStatisticsArray.count == 3 && indexPath.row == 1))
    {

            [RACObserve(self, myCommentsCount) subscribeNext:^(NSNumber *count) {
                if ([User sharedInstance].userid && [User sharedInstance].userid.length > 0)
                {
                    if ([count integerValue] <= 0)
                    {
                        cell.detailTextLabel.text = @"获取中";
                    }
                    else
                    {
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", [count integerValue]];
                    }
                }
                else
                {
                    cell.detailTextLabel.text = @"未登录";
                }
            }];
    }
    else
    {
        cell.detailTextLabel.text = [self.listItemStatisticsArray objectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row)
    {
        case 0:
        {
            MapManageViewController * vc = [[MapManageViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            

        case 1:
        {
            if (self.listItemNameArray.count > 3)
            {
                if (![User sharedInstance].userid)
                {
                    [UWindowHud hudWithType:kToastType withContentString:@"请点击头像登录！"];
                }
                else
                {
                LuckyViewController * vc = [[LuckyViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
                }
            }
            else
            {
                if (![User sharedInstance].userid)
                {
                    [UWindowHud hudWithType:kToastType withContentString:@"请点击头像登录！"];
                }
                else
                {
                LeaveMessageViewController * vc  = [[LeaveMessageViewController alloc]init];
                [self.navigationController pushViewController:vc animated:YES];
                }
            }
        }
            break;
        case 2:
        {
            if (self.listItemNameArray.count > 3)
            {
                if (![User sharedInstance].userid)
                {
                    [UWindowHud hudWithType:kToastType withContentString:@"请点击头像登录！"];
                }
                else
                {
                LeaveMessageViewController * vc  = [[LeaveMessageViewController alloc]init];
                [self.navigationController pushViewController:vc animated:YES];
                }
            }
            else
            {
                MyShareViewController *vc = [[MyShareViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }

        }
            break;
        case 3:
        {
            if (self.listItemNameArray.count > 3)
            {
                MyShareViewController *vc = [[MyShareViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;

        default:
            break;
    }
}

#pragma mark - button click
- (void)leftAction
{
    SetViewController * vc = [[SetViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)buttonActon:(UIButton *)sender
{
    switch (sender.tag)
    {
        case 0:
        {
            EditePersonViewController * vc = [[EditePersonViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            ReSetPassWordViewController * vc = [[ReSetPassWordViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            // 退出
            [User logout];
            if ([User sharedInstance].clearMyCenterDataBlock)
            {
                [User sharedInstance].clearMyCenterDataBlock();
            }
            [_image setImage:[UIImage imageNamed:@"me_Icon"]];

            if (!isLuckyDrawerSupport)
            {
                [self loadDefaultListDataWithoutLuckyDrawer];
            }
            else
            {
                [self loadDefaultListDataWithLuckyDrawer];
            }
            
            [self backAciton];
        }
            break;
        default:
            break;
    }
}

- (void)backAciton
{
    
    //开始动画
    [UIView beginAnimations:nil context:nil];
    //设定动画持续时间
    [UIView setAnimationDuration:1];
    self.personInfoView.frame       = CGRectMake(0, _defaultView.bottom, App_Frame_Width, _defaultView.bottom - 250);
    self.pPersonTable.scrollEnabled = YES;
    
    [UIView commitAnimations];
}

#pragma mark - tap
- (void)imageTapclick:(UITapGestureRecognizer *)tap
{
    NSLog(@"1");
    //开始动画
    [UIView beginAnimations:nil context:nil];
    //设定动画持续时间
    [UIView setAnimationDuration:1];
    //动画的内容
    self.personInfoView.frame       = CGRectMake(0, ListUpX, App_Frame_Width, self.personInfoView.height);
    self.pPersonTable.scrollEnabled = NO;
    //动画结束
    [UIView commitAnimations];
    if (![User isLoggedIn])
    {
        LoginViewController *login       = [[LoginViewController alloc] init];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:login];
        loginNav.navigationBarHidden     = YES;
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
    }
}


- (void)willMove2Forground
{
    [self refreshData];
    
    self.myCommentsCount = 0;
    
    if ([User sharedInstance].userid && [User sharedInstance].userid.length > 0)
    {
        [Interface getMyComments:[User sharedInstance].userid result:^(MyCommentsResponse *response, NSError *error) {
            self.myCommentsCount = response.commentsList.count;
        }];
    }
}

- (void)willMove2Background
{
    [SVProgressHUD dismiss];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
