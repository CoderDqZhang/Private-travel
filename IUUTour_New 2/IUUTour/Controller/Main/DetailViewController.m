//
//  ScenicDetailViewController.m
//  IUUTour
//
//  Created by admin on 16/1/2.
//  Copyright (c) 2016年 DevDiv Technology. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailMessageViewController.h"
#import "VOSegmentedControl.h"
#import "HotelCell.h"
#import "FoodCell.h"
#import "AppDelegate.h"
#import "ZipArchive.h"
#import "ScenicSpotGuideViewController.h"
#import "ShareView.h"
#import "UMSocialControllerService.h"
#import "UMSocialSnsPlatformManager.h"
#import "LoginViewController.h"
#import "MapNaviViewController.h"
#import "DownResource.h"
#import "Interface.h"
#import "AlarmViewController.h"
#import <CoreText/CoreText.h>
#import "AFDownloadRequestOperation.h"
#import "OfflineMapDownloader.h"
#import "AFNetworking.h"
#import "ImgListViewController.h"

@interface DetailViewController()<UIScrollViewDelegate,DPRequestDelegate,MAMapViewDelegate, UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UITableView        * _tableView;
    UIButton           * _mapBtn;
    
    long long         bytesReceived;
    float             packageSize;
    
    
    int               fixY;
    NSString          * zipFilePath;
    NSFileHandle      * zipFileHandle;
    BOOL              isMap;
    NSDictionary      * scenicDetail;
    
    
    NSMutableArray    * hotelName;
    NSMutableArray    * hotelAddress;
    NSMutableArray    * businessUrl;
    NSMutableArray    * hotelPrice;
    NSMutableArray    * hotelImage;
    NSMutableArray    * hotelStar;
    NSMutableArray    * hotelScore;
    NSMutableArray    * hoteldistance;
    
    UIButton          * offineMapBtn;
    UILabel           * lovelbl;
    MAPointAnnotation * item;
    BOOL              isOffice;
    UILabel           * cmtlbl;
    
    KDownStatus        downloadStatus;
    
    UIScrollView      *mainScrollView;
    UIView            *introduceView;
    UIView            *tipsView;
    UIView            *transportView;
    UIView            *recommendView;
    UIButton          *currentBtn;
}
@property (nonatomic, strong) MAMapView *mapView;

@end

@implementation DetailViewController
{
    NSArray   *urlArray;
    NSArray   *paramsArray;
    NSInteger indexA;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addGesture];
    
    urlArray = [NSArray arrayWithObjects:@"v1/business/find_businesses"
                , @"v1/deal/find_deals"
                , @"v1/deal/get_single_deal"
                , @"v1/review/get_recent_reviews"
                , nil];
    
    [Interface getScenicDetail:self.data.scenicId result:^(ScenicDetailResponse *response, NSError *error) {
        if (response && response.status)
        {
            self.data = response.dataItem;
            [self loadDada];
        }
        else
        {
            [UWindowHud hudWithType:kToastType withContentString:@"获取失败，请检查网络！"];
        }
    }];
    
    [self createNavigation];
}

-(void)createNavigation
{
    UIButton *loveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loveBtn.frame = CGRectMake(App_Frame_Width - 112, 30, 33.5, 33.5);
    [loveBtn setBackgroundImage:[UIImage imageNamed:@"ic_shoucang"] forState:UIControlStateNormal];
    [loveBtn addTarget:self action:@selector(loveAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_shoucang"] style:UIBarButtonItemStyleDone target:self action:@selector(loveAction)];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(App_Frame_Width - 61, 30, 33.5, 33.5);
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"ic_share"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_share"] style:UIBarButtonItemStyleDone target:self action:@selector(shareAction:)];
    
    self.navigationItem.rightBarButtonItems = @[rightItem1,rightItem];
}

-(void)viewWillAppear:(BOOL)animated{
    
    NSUserDefaults *offsetDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *number = [offsetDefault valueForKey:@"offset"];
    CGFloat y = [number floatValue];
    mainScrollView.contentOffset = CGPointMake(0, y);
}

-(void)viewWillDisappear:(BOOL)animated{
    
    NSNumber *number = [[NSNumber alloc] initWithFloat:mainScrollView.contentOffset.y];
    NSUserDefaults *offsetDefault = [NSUserDefaults standardUserDefaults];
    [offsetDefault setValue:number forKey:@"offset"];
}

-(void)viewDidAppear:(BOOL)animated{
    
}

-(void)loadDada{
    [Interface getScenicBriefIntro:self.data.scenicId result:^(ScenicIntorResponse *response, NSError *error) {
        if(response.status)
        {
            self.infoData = response.dataItem;
            [self createDetailView];
            [self createMapView];
            [self createIntroduceView];
            [self createImageListView];
        }
        else
        {
            [UWindowHud hudWithType:kToastType withContentString:@"获取失败，请检查网络！"];
        }
    }];
    
    [Interface getScenicTips:self.data.scenicId result:^(ScenicTipsResponse *response, NSError *error) {
        if (response.status)
        {
            self.tipsData = response.dataItem;
            [self createTipsView];
        }
        else
        {
            [UWindowHud hudWithType:kToastType withContentString:@"获取失败，请检查网络！"];
        }
    }];
    [Interface getScenicTransport:self.data.scenicId result:^(ScenicTransportResponse *response, NSError *error) {
        if (response.status)
        {
            self.tranData = response.dataItem;
            [self createTransportView];
            [self createRecommendScenicView];
            [self initCircumView];
        }
        else
        {
            [UWindowHud hudWithType:kToastType withContentString:@"获取失败，请检查网络！"];
        }
    }];
}

- (void)createDetailView
{
    mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Screen_Height)];
    mainScrollView.backgroundColor = [UIColor blackColor];
    mainScrollView.scrollEnabled = YES;
    [self.view addSubview:mainScrollView];
    
    if (!self.data & !self.infoData)
    {
        //数据为空
    }
    else{
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 211)];
        topView.backgroundColor = [UIColor orangeColor];
        [mainScrollView addSubview:topView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 211)];
        imageView.userInteractionEnabled = YES;
        [imageView setShowActivityIndicatorView:YES];
        [imageView setIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [imageView sd_setImageWithURL:[NSURL URLWithString:self.data.smallImage] placeholderImage:[UIImage imageNamed:@"placeholder_common"]options:SDWebImageProgressiveDownload | SDWebImageRetryFailed];
        [topView addSubview:imageView];
        
        UIImageView *topShadowImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 60)];
        topShadowImg.image = [UIImage imageNamed:@"top_shadow"];
        [topView addSubview:topShadowImg];
        
        
        
        
        //景点介绍
        UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 211 - 50, App_Frame_Width, 50)];
//        infoView.backgroundColor = [UIColor redColor];
        [topView addSubview:infoView];
        
        UIImageView *bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 70)];
        bgImage.image = [UIImage imageNamed:@"bottom_shadow"];
        [infoView addSubview:bgImage];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, 5, App_Frame_Width - 80, 16)];
        nameLabel.text = self.data.scenicName;
        nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        nameLabel.textColor = [UIColor whiteColor];
        [infoView addSubview:nameLabel];
        
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, 27, 60, 11)];
        descLabel.text = self.infoData.scenicType;
        descLabel.font = [UIFont systemFontOfSize:11];
        descLabel.textColor = [UIColor whiteColor];
        [infoView addSubview:descLabel];
        
        self.infoData.scenicLevel = [self.infoData.scenicLevel stringByReplacingOccurrencesOfString:@"A" withString:@""];
        for (int i = 0 ; i < [self.infoData.scenicLevel intValue]; i ++)
        {
            UIImageView *levelImg = [[UIImageView alloc] initWithFrame:CGRectMake(78 + i*17, 25, 15, 15)];
            levelImg.image = [UIImage imageNamed:@"star"];
            [infoView addSubview:levelImg];
        }
        for (int i = 5-[self.infoData.scenicLevel intValue]; i > 0; i--) {
            UIImageView *unstarImg = [[UIImageView alloc] initWithFrame:CGRectMake(78 + [self.infoData.scenicLevel intValue]*17, 25, 15, 15)];
            unstarImg.image = [UIImage imageNamed:@"un-star"];
            [infoView addSubview:unstarImg];
        }
        
        UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(172, 27, 50, 12)];
        scoreLabel.text = @"9.2分";
        scoreLabel.font = [UIFont systemFontOfSize:12];
        scoreLabel.textColor = [UIColor orangeColor];
        [infoView addSubview:scoreLabel];
        
        UIImage *tickeImage = [UIImage imageNamed:@"ticket"];
        
        UIButton *ticketBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        ticketBtn.frame = CGRectMake(App_Frame_Width - 20 - tickeImage.size.width, infoView.frame.size.height - 12 - tickeImage.size.height, tickeImage.size.width, tickeImage.size.height);
        [ticketBtn setBackgroundImage: tickeImage forState:UIControlStateNormal];
        [infoView addSubview:ticketBtn];
    }
}

-(void)createMapView{
    UIView *mapView = [[UIView alloc] initWithFrame:CGRectMake(0, 211, App_Frame_Width, 51)];
    mapView.backgroundColor = [UIColor colorWithRed:24.0/255.0 green:24.0/255.0 blue:26.0/255.0 alpha:1.0];
    [mainScrollView addSubview:mapView];
    
    UIButton *mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    mapBtn.frame = CGRectMake(42, 9.5, App_Frame_Width - 82, 32.5);
    [mapBtn setTitle:@"手漫地图导航" forState:UIControlStateNormal];
    [mapBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    mapBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    mapBtn.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:178.0/255.0 blue:27.0/255.0 alpha:1.0];
    [mapBtn addTarget:self  action:@selector(mapAction) forControlEvents:UIControlEventTouchUpInside];
    mapBtn.layer.cornerRadius = 15;
    [mapView addSubview:mapBtn];
}

-(void)createIntroduceView{
    introduceView = [[UIView alloc] initWithFrame:CGRectMake(0, 266, App_Frame_Width, 20)];
    introduceView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:33.0/255.0 alpha:1.0];
    [mainScrollView addSubview:introduceView];
    
    UILabel *introduceLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 15, App_Frame_Width - 24, 20)];
    introduceLabel.text = self.infoData.desc;
    introduceLabel.numberOfLines = 0;
    introduceLabel.font = [UIFont systemFontOfSize:13.0f];
    introduceLabel.textColor = [UIColor lightTextColor];
    CGRect rect = [introduceLabel.text boundingRectWithSize:CGSizeMake(App_Frame_Width - 24, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:introduceLabel.font} context:nil];
    introduceLabel.frame = CGRectMake(12, 15, rect.size.width, rect.size.height);
    
    [introduceView addSubview:introduceLabel];
    
    UILabel *levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 14+14+rect.size.height, 30, 11)];
    levelLabel.text = self.data.scenicLevel;
    levelLabel.font = [UIFont systemFontOfSize:11.0f];
    levelLabel.textColor = [UIColor orangeColor];
    [introduceView addSubview:levelLabel];
    
    UILabel *levelLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(30, levelLabel.frame.origin.y, 100, 11)];
    levelLabel1.text = @"级旅游景点";
    levelLabel1.font = [UIFont systemFontOfSize:11.0f];
    levelLabel1.textColor = [UIColor lightTextColor];
    [introduceView addSubview:levelLabel1];
    
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 32+14+rect.size.height, 30, 11)];
    numLabel.text = self.data.favourNum;
    numLabel.font = [UIFont systemFontOfSize:11.0f];
    numLabel.textColor = [UIColor orangeColor];
    [introduceView addSubview:numLabel];
    
    UILabel *numLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(30, numLabel.frame.origin.y, 160, 11)];
    numLabel1.text = @"位游客喜欢这个地方";
    numLabel1.font = [UIFont systemFontOfSize:11.0f];
    numLabel1.textColor = [UIColor lightTextColor];
    [introduceView addSubview:numLabel1];
    
    introduceView.frame = CGRectMake(0, 262, App_Frame_Height, rect.size.height + 70);
    mainScrollView.contentSize = CGSizeMake(App_Frame_Width, 262+introduceView.frame.size.height);
}

-(void)createImageListView{
    UIView *imageListView = [[UIView alloc] initWithFrame:CGRectMake(0, 262 + introduceView.frame.size.height, App_Frame_Width, 140)];
    imageListView.backgroundColor = [UIColor colorWithRed:41.0/255.0 green:40.0/255.0 blue:43.0/255.0 alpha:1.0];
    [mainScrollView addSubview:imageListView];
    
    UIImageView *tipsImg = [[UIImageView alloc] initWithFrame:CGRectMake(12, 10, 5, 15)];
    tipsImg.image = [UIImage imageNamed:@"tips"];
    [imageListView addSubview:tipsImg];
    
    UILabel *scenicImgLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, 12.5, 100, 15)];
    scenicImgLabel.text = @"景区图片";
    scenicImgLabel.center = CGPointMake(scenicImgLabel.center.x, tipsImg.center.y);
    scenicImgLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
    scenicImgLabel.textColor = [UIColor lightGrayColor];
    [imageListView addSubview:scenicImgLabel];
    
    UIScrollView *imageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 41.5, App_Frame_Width, 86)];
    imageScroll.backgroundColor = [UIColor colorWithRed:41.0/255.0 green:40.0/255.0 blue:43.0/255.0 alpha:1.0];
    imageScroll.scrollEnabled = YES;
    imageScroll.contentSize = CGSizeMake(8 + 148 * self.infoData.imageList.count, 86);
    [imageListView addSubview:imageScroll];
    
    for (int i = 0 ; i<self.infoData.imageList.count ; i++) {
        Recommend *tempRecommend = [self.infoData.imageList objectAtIndex:i];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8 + i*148, 0, 140, 86)];
        [imageView setShowActivityIndicatorView:YES];
        [imageView setIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [imageView sd_setImageWithURL:[NSURL URLWithString:tempRecommend.imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_common"]options:SDWebImageProgressiveDownload | SDWebImageRetryFailed];
        [imageScroll addSubview:imageView];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(8 + i*148, 0, 140, 86);
        button.backgroundColor = [UIColor clearColor];
        button.tag = i;
        [button addTarget:self action:@selector(showImageList:) forControlEvents:UIControlEventTouchUpInside];
        [imageScroll addSubview:button];
    }
    mainScrollView.contentSize = CGSizeMake(App_Frame_Width, 402+introduceView.frame.size.height);
}

-(void)showImageList:(UIButton *)button{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (Recommend *recommend in self.infoData.imageList) {
        [array addObject:recommend.imageUrl];
    }
    ImgListViewController *imgView = [[ImgListViewController alloc] init];
    imgView.urlArray = array;
    imgView.index = button.tag;
    [self.navigationController pushViewController:imgView animated:YES];
}

-(void)createTipsView{
    tipsView = [[UIView alloc] initWithFrame:CGRectMake(0, 402+introduceView.frame.size.height, App_Frame_Width, 20)];
    tipsView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0];
    [mainScrollView addSubview:tipsView];
    
    UIImage *tipsImage = [UIImage imageNamed:@"ic_xiaotieshi"];
    UIImageView *tipsImg = [[UIImageView alloc] initWithFrame:CGRectMake(12, 21, tipsImage.size.width, tipsImage.size.height)];
    tipsImg.image = tipsImage;
    [tipsView addSubview:tipsImg];
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(tipsImg.frame.size.width + tipsImg.frame.origin.x + 9, 20, 76, 15)];
    tipsLabel.text = @"小贴士";
    tipsLabel.center = CGPointMake(tipsLabel.center.x, tipsImg.center.y);
    tipsLabel.textColor = [UIColor lightGrayColor];
    tipsLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    [tipsView addSubview:tipsLabel];
    
    UILabel *tipsDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 40, App_Frame_Width - 24, 20)];
    tipsDescLabel.text = self.tipsData.desc;
    tipsDescLabel.textColor = [UIColor lightGrayColor];
    tipsDescLabel.numberOfLines = 0;
    tipsDescLabel.font = [UIFont systemFontOfSize:13.0];
    CGRect rect = [tipsDescLabel.text boundingRectWithSize:CGSizeMake(App_Frame_Width - 24, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:tipsDescLabel.font} context:nil];
    tipsDescLabel.frame = CGRectMake(12, 40, App_Frame_Width - 24, rect.size.height);
    [tipsView addSubview:tipsDescLabel];
    tipsView.frame = CGRectMake(0, 402+introduceView.frame.size.height, App_Frame_Width, rect.size.height + 50);
    mainScrollView.contentSize = CGSizeMake(App_Frame_Width, 502+introduceView.frame.size.height + tipsView.frame.size.height);
}

-(void)createTransportView{
    transportView = [[UIView alloc] initWithFrame:CGRectMake(0, 402+introduceView.frame.size.height + tipsView.frame.size.height, App_Frame_Width, 20)];
    transportView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0];
    [mainScrollView addSubview:transportView];
    
    UIImage *transportImage = [UIImage imageNamed:@"ic_xiaotieshi"];
    UIImageView *transportImg = [[UIImageView alloc] initWithFrame:CGRectMake(12, 20, transportImage.size.width, transportImage.size.height)];
    transportImg.image = transportImage;
    [transportView addSubview:transportImg];
    
    UILabel *transportLabel = [[UILabel alloc] initWithFrame:CGRectMake(transportImg.frame.size.width + transportImg.frame.origin.x + 9, 20, 76, 15)];
    transportLabel.text = @"交通";
    transportLabel.center = CGPointMake(transportLabel.center.x, transportImg.center.y);
    transportLabel.textColor = [UIColor lightGrayColor];
    transportLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    [transportView addSubview:transportLabel];
    
    UILabel *transportDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 60, App_Frame_Width - 24, 20)];
    transportDescLabel.text = self.tranData.desc;
    transportDescLabel.font = [UIFont systemFontOfSize:13.0];
    transportDescLabel.textColor = [UIColor lightGrayColor];
    transportDescLabel.numberOfLines = 0;
    CGRect rect = [transportDescLabel.text boundingRectWithSize:CGSizeMake(App_Frame_Width - 24, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:transportDescLabel.font} context:nil];
    transportDescLabel.frame = CGRectMake(12, 60, App_Frame_Width - 24, rect.size.height);
    [transportView addSubview:transportDescLabel];
    transportView.frame = CGRectMake(0, 402+introduceView.frame.size.height+tipsView.frame.size.height, App_Frame_Width, rect.size.height + 70);
    mainScrollView.contentSize = CGSizeMake(App_Frame_Width, 402+introduceView.frame.size.height + tipsView.frame.size.height+transportView.frame.size.height);
}

-(void)createRecommendScenicView{
    recommendView = [[UIView alloc] initWithFrame:CGRectMake(0, 402+introduceView.frame.size.height + tipsView.frame.size.height+transportView.frame.size.height, App_Frame_Width, 70)];
    recommendView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0];
    [mainScrollView addSubview:recommendView];
    
    
    UIImage *recommendImage = [UIImage imageNamed:@"ic_xiaotieshi"];
    UIImageView *recommendImg = [[UIImageView alloc] initWithFrame:CGRectMake(12, 21, recommendImage.size.width, recommendImage.size.height)];
    recommendImg.image = recommendImage;
    [recommendView addSubview:recommendImg];
    
    
    UILabel *recommendLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, 12.5, 100, 15)];
    recommendLabel.text = @"推荐景区";
    recommendLabel.center = CGPointMake(recommendLabel.center.x, recommendImg.center.y);
    recommendLabel.textColor = [UIColor lightGrayColor];
    recommendLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
    [recommendView addSubview:recommendLabel];
    
    CGFloat imageWidth = (App_Frame_Width - 31)/2;
    
    if (self.data.recommendScenicList.count > 0)
    {
        for (int i = 0; i < [self.data.recommendScenicList count]; i++)
        {
            Recommend *tempRecommend = [self.data.recommendScenicList objectAtIndex:i];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake((i%2)*(imageWidth + 6) +6 , floor(i/2)*(imageWidth+10) + 60, imageWidth, 120);
            button.backgroundColor = [UIColor clearColor];
            button.tag = i;
            [button addTarget:self action:@selector(imageBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [recommendView addSubview:button];
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((i%2)*(imageWidth + 10) +10 , floor(i/2)*(imageWidth+10) + 60, imageWidth, 120)];
            [imageView setShowActivityIndicatorView:YES];
            [imageView setIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [imageView sd_setImageWithURL:[NSURL URLWithString:tempRecommend.imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_common"]options:SDWebImageProgressiveDownload | SDWebImageRetryFailed];
            [recommendView addSubview:imageView];
            
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake((i%2)*(imageWidth + 10) +10 , floor(i/2)*(imageWidth+10) + 45+imageWidth, imageWidth, 13)];
            nameLabel.font = [UIFont systemFontOfSize:13.0f];
            nameLabel.text = tempRecommend.name;
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.textColor = [UIColor lightTextColor];
            [recommendView addSubview:nameLabel];
        }
    }
    else
    {
        
    }
    recommendView.size = CGSizeMake(App_Frame_Width, (self.data.recommendScenicList.count+1)/2 *imageWidth+90);
    mainScrollView.contentSize = CGSizeMake(App_Frame_Width, 592+introduceView.frame.size.height + tipsView.frame.size.height+transportView.frame.size.height+(self.data.recommendScenicList.count+1)/2 *imageWidth);
}

- (void)loveAction
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
        __weak __typeof(self)weakSelf = self;
        
        [Interface praiseScenic:self.data.scenicId UserID:[User sharedInstance].userid result:^(PraiseScenicResponse *response, NSError *error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (!strongSelf)
            {
                return;
            }
            
            if (response.status == 1)
            {
                int num = [strongSelf.data.favourNum intValue];
                num = num +1;
                strongSelf->lovelbl.text = [NSString stringWithFormat:@"%d",num];
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


- (void)mapAction
{
    if ([self.data.canNavi intValue] == 1)
    {
        MapNaviViewController * vc = [[MapNaviViewController alloc] init];
        vc.data = self.data;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        if ([self.data.mapSize longLongValue] < 0.01f)
        {
            [UWindowHud hudWithType:kToastType withContentString:@"离线地图不存在！"];
            return;
        }
        
        NSUserDefaults * userDef = [NSUserDefaults standardUserDefaults];
        
        if ([[userDef objectForKey:[NSString stringWithFormat:@"%@",self.data.scenicId]] isEqualToString:@"有"])
        {
            ScenicSpotGuideViewController *guideViewController = [[ScenicSpotGuideViewController alloc] init];
            guideViewController.data         = self.data;
            guideViewController.scenicDetail = scenicDetail;
            guideViewController.currentRoute = -1;
            [guideViewController showMap];
            [self.navigationController pushViewController:guideViewController animated:YES];
        }
        else
        {
            AFNetworkReachabilityManager *reachabilityMgr = [AFNetworkReachabilityManager sharedManager];
            if (reachabilityMgr.networkReachabilityStatus != AFNetworkReachabilityStatusReachableViaWiFi)
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您未接入WiFi，确定开始下载？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alert show];
            }
            else
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"尚未下载景区地图，确定开始下载？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alert show];
            }
        }
    }
}

- (void)shareAction:(UIButton *)btn
{
    [ShareView showShareViewChoice:^(NSInteger index)
     {
         NSArray *arr = [NSArray arrayWithObjects:@"wxsession",@"wxtimeline",@"sina",@"tencent",@"qq",@"qzone", @"renren",@"email",nil];
         NSString *snsName = [arr objectAtIndex:index];
         NSString *shareText = [NSString stringWithFormat:@"IUU旅行让世界变小。我今天来“%@”玩了，景色非常不做，你还等什么呢。www.imyuu.com  Appstore下载地址:https://itunes.apple.com/cn/app/iuu-lu-xing/id955692460?mt=8",self.data.scenicName];
         
         UIImage *image = [UIImage imageNamed:@"shareIcon"];
         [[UMSocialDataService defaultDataService] postSNSWithTypes:@[snsName] content:shareText image:image location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity * response){
             
             if (response.responseCode == UMSResponseCodeSuccess)
             {
                 [self saveShareContent:snsName];
                 UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"成功" message:@"分享成功" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
                 [alertView show];
             }
             else if(response.responseCode != UMSResponseCodeCancel)
             {
                 UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"失败" message:@"分享失败" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
                 [alertView show];
             }
         }];
         
     } cancel:^{
     }];
}

-(void)saveShareContent:(NSString *)type
{
    NSArray * paths     = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString * path     = [paths  objectAtIndex:0];
    NSString * filePath = [path stringByAppendingPathComponent:@"shareContent.plist"];
    
    NSMutableArray *jsonObject = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    if (jsonObject==nil) {
        jsonObject = [[NSMutableArray alloc] init];
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:type forKey:@"shareType"];
    [dict setObject:self.data.scenicName forKey:@"scenicName"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    [dict setObject:strDate forKey:@"datetime"];
    [jsonObject addObject:dict];
    [jsonObject writeToFile:filePath atomically:YES];
    
}

- (void)imageBtnAction:(UIButton *)sender
{
    Recommend *tempRecommend = [self.data.recommendScenicList objectAtIndex:sender.tag];
    
    ScenicArea *dataTemp = [[ScenicArea alloc] init];
    dataTemp.scenicId = tempRecommend.intentLink;
    dataTemp.scenicName = tempRecommend.name;
    
    DetailViewController * vc = [[DetailViewController alloc] init];
    vc.data = dataTemp;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 周边
-(void)initCircumView{
    UIView *circumView = [[UIView alloc] initWithFrame:CGRectMake(0, 402+introduceView.frame.size.height + tipsView.frame.size.height+transportView.frame.size.height+recommendView.frame.size.height, App_Frame_Width, 50)];
    circumView.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:41.0/255.0 blue:42.0/255.0 alpha:1.0];
    [mainScrollView addSubview:circumView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake((App_Frame_Width - 2)/2, 17.5, 2, 15)];
    lineView.backgroundColor = [UIColor grayColor];
    [circumView addSubview:lineView];
    
    UIButton *foodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    foodBtn.frame = CGRectMake(0, 0, App_Frame_Width/2, 50);
    [foodBtn setTitle:@"周边美食" forState:UIControlStateNormal];
    [foodBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    foodBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    foodBtn.tag = 1001;
    [foodBtn addTarget:self action:@selector(circumBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [circumView addSubview:foodBtn];
    currentBtn = foodBtn;
    
    UIButton *hotelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    hotelBtn.frame = CGRectMake(App_Frame_Width/2, 0, App_Frame_Width/2, 50);
    [hotelBtn setTitle:@"周边酒店" forState:UIControlStateNormal];
    [hotelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    hotelBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    hotelBtn.tag = 1002;
    [hotelBtn addTarget:self action:@selector(circumBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [circumView addSubview:hotelBtn];
    
    mainScrollView.contentSize = CGSizeMake(App_Frame_Width, 452+introduceView.frame.size.height + tipsView.frame.size.height+transportView.frame.size.height+recommendView.frame.size.height);
    
    [self initTableView];
}

-(void)circumBtnClick:(UIButton *)sender{
    currentBtn = sender;
    if (sender.tag == 1001) {
        [currentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        UIButton *button = (UIButton *)[self.view viewWithTag:1002];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        NSArray * array = [NSArray arrayWithObjects:[NSString stringWithFormat:@"category=美食&city=%@&latitude=%@&longitude=%@&sort=1&limit=40&offset_type=1&out_offset_type=1&platform=2&radius=5000",self.data.city,self.data.lat,self.data.lng], nil];
        NSString *url = [urlArray objectAtIndex:0];
        NSString *params = [array objectAtIndex:0];
        [[[AppDelegate instance] dpapi] requestWithURL:url paramsString:params delegate:self];
        
        _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0.01)];
        [_tableView reloadData];
        
    }else{
        [currentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        UIButton *button = (UIButton *)[self.view viewWithTag:1001];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        paramsArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"category=酒店&city=%@&latitude=%@&longitude=%@&sort=1&limit=40&offset_type=1&out_offset_type=1&platform=2&radius=5000",self.data.city,self.data.lat,self.data.lng], nil];
        NSString *url = [urlArray objectAtIndex:0];
        NSString *params = [paramsArray objectAtIndex:0];
        [[[AppDelegate instance] dpapi] requestWithURL:url paramsString:params delegate:self];
        _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0.01)];
        [_tableView reloadData];
    }
}

-(void)initTableView{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 452+introduceView.frame.size.height + tipsView.frame.size.height+transportView.frame.size.height+recommendView.frame.size.height, App_Frame_Width, 240) style:(UITableViewStyleGrouped)];
    _tableView.delegate        = self;
    _tableView.dataSource      = self;
    _tableView.scrollEnabled   = NO;
    _tableView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0];
    [mainScrollView addSubview:_tableView];
    [self circumBtnClick:currentBtn];
    _tableView.size = CGSizeMake(App_Frame_Width, 452+introduceView.frame.size.height + tipsView.frame.size.height+transportView.frame.size.height+recommendView.frame.size.height+96*(hotelName.count) + 20);
    mainScrollView.contentSize = CGSizeMake(App_Frame_Width, 452+introduceView.frame.size.height + tipsView.frame.size.height+transportView.frame.size.height+recommendView.frame.size.height+_tableView.frame.size.height);
}

#pragma mark tableView delegate method
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return hotelName.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 96;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * ides = @"foodcell";
    FoodCell * cell = [tableView dequeueReusableCellWithIdentifier:ides];
    if (cell == nil)
    {
        cell = [[FoodCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:ides];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.spinner.hidden = YES;
    
    [cell.image setShowActivityIndicatorView:YES];
    [cell.image setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [cell.image sd_setImageWithURL:[NSURL URLWithString:[hotelImage objectAtIndex:indexPath.row]] placeholderImage:[UIImage imageNamed:@"placeholder_common"]options:SDWebImageProgressiveDownload | SDWebImageRetryFailed];
    
    cell.titlelbl.text    = [hotelName objectAtIndex:indexPath.row];
    
    [cell.StarImg setShowActivityIndicatorView:YES];
    [cell.StarImg setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [cell.StarImg sd_setImageWithURL:[NSURL URLWithString:[hotelStar objectAtIndex:indexPath.row]] placeholderImage:[UIImage imageNamed:@"placeholder_common"]options:SDWebImageProgressiveDownload | SDWebImageRetryFailed];
    
    
    cell.scorelbl.text = [NSString  stringWithFormat:@"%@分",[hotelScore objectAtIndex:indexPath.row]];
    cell.pricelbl.text = [NSString stringWithFormat: @"￥%@起",[hotelPrice objectAtIndex:indexPath.row]];
    cell.addresslbl.text  = [hotelAddress objectAtIndex:indexPath.row];
    cell.distancelbl.text = [NSString stringWithFormat:@"%@米",[hoteldistance objectAtIndex:indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < businessUrl.count)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[businessUrl objectAtIndex:indexPath.row]]];
    }
}

-(void)addGesture{
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backPress)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeGesture];
}

-(void)backPress
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 大众点评数据拉去代理
- (void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    NSString *dianpingFoodCacheKey = [NSString stringWithFormat:@"category=美食&city=%@&latitude=%@&longitude=%@", self.data.city, self.data.lat, self.data.lng];
    NSString *dianpingHotelCacheKey = [NSString stringWithFormat:@"category=酒店&city=%@&latitude=%@&longitude=%@", self.data.city, self.data.lat, self.data.lng];
    
    
    NSMutableDictionary *jsonObject = nil;
    
    BOOL containsFoodKey = ([request.url rangeOfString:dianpingFoodCacheKey options:NSCaseInsensitiveSearch].location != NSNotFound);
    BOOL containsHotelKey = ([request.url rangeOfString:dianpingHotelCacheKey options:NSCaseInsensitiveSearch].location != NSNotFound);
    //    if ([request.url containsString:dianpingFoodCacheKey])
    if (containsFoodKey)
    {
        [SVProgressHUD dismissFromOwner:@"DetailViewController_p4"];
        
        NSData *serializedData = [Interface deserializeFrom:dianpingFoodCacheKey];
        if (serializedData)
        {
            jsonObject = [NSJSONSerialization JSONObjectWithData:serializedData options:NSJSONReadingAllowFragments error:nil];
        }
        //jsonObject = [[Interface deserializeFrom:dianpingFoodCacheKey] objectFromJSONData];
    }
    //else if([request.url containsString:dianpingHotelCacheKey])
    else if (containsHotelKey)
    {
        [SVProgressHUD dismissFromOwner:@"DetailViewController_p5"];
        
        NSData *serializedData = [Interface deserializeFrom:dianpingHotelCacheKey];
        if (serializedData)
        {
            jsonObject = [NSJSONSerialization JSONObjectWithData:serializedData options:NSJSONReadingAllowFragments error:nil];
        }
        //jsonObject = [[Interface deserializeFrom:dianpingHotelCacheKey] objectFromJSONData];
    }
    
    if (jsonObject)
    {
        [self processDPResult:jsonObject];
    }
    else
    {
        [UWindowHud hudWithType:kToastType withContentString:@"获取失败，请检查网络！"];
    }
}

- (void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
    if (!result)
    {
        return;
    }
    NSString *dianpingFoodCacheKey = [NSString stringWithFormat:@"category=美食&city=%@&latitude=%@&longitude=%@", self.data.city, self.data.lat, self.data.lng];
    NSString *dianpingHotelCacheKey = [NSString stringWithFormat:@"category=酒店&city=%@&latitude=%@&longitude=%@", self.data.city, self.data.lat, self.data.lng];
    
    NSMutableDictionary *dic = (NSMutableDictionary*)result;
    
    BOOL containsFoodKey = ([request.url rangeOfString:dianpingFoodCacheKey options:NSCaseInsensitiveSearch].location != NSNotFound);
    BOOL containsHotelKey = ([request.url rangeOfString:dianpingHotelCacheKey options:NSCaseInsensitiveSearch].location != NSNotFound);
    
    //if ([request.url containsString:dianpingFoodCacheKey])
    if (containsFoodKey)
    {
        [SVProgressHUD dismissFromOwner:@"DetailViewController_p4"];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        
        [Interface serialize:jsonData to:dianpingFoodCacheKey];
    }
    //else if([request.url containsString:dianpingHotelCacheKey])
    else if (containsHotelKey)
    {
        [SVProgressHUD dismissFromOwner:@"DetailViewController_p5"];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        
        [Interface serialize:jsonData to:dianpingHotelCacheKey];
    }
    
    [self processDPResult:dic];
}

- (void)processDPResult:(NSMutableDictionary *)result
{
    hotelAddress = [[NSMutableArray alloc]init];
    businessUrl  = [[NSMutableArray alloc]init];
    hotelName    = [[NSMutableArray alloc]init];
    hotelImage   = [[NSMutableArray alloc]init];
    hotelPrice   = [[NSMutableArray alloc]init];
    hotelStar    = [[NSMutableArray alloc]init];
    hotelScore   = [[NSMutableArray alloc]init];
    hoteldistance= [[NSMutableArray alloc]init];
    
    NSArray *businessArray = [result objectForKey:@"businesses"];
    for (int i = 0; businessArray && i < [businessArray count]; i++)
    {
        NSDictionary *dic = [businessArray objectAtIndex:i];
        if (dic)
        {
            NSString *name = [dic objectForKey:@"name"];
            NSString *fileterName = [name stringByReplacingOccurrencesOfString:@"(这是一条测试商户数据，仅用于测试开发，开发完成后请申请正式数据...)" withString:@""];
            [hotelName addObject:fileterName];
            [hotelAddress addObject:[dic objectForKey:@"address"]];
            [businessUrl addObject:[dic objectForKey:@"business_url"]];
            [hotelImage addObject:[dic objectForKey:@"photo_url"]];
            [hotelStar addObject:[dic objectForKey:@"rating_img_url"]];
            [hotelScore addObject:[dic objectForKey:@"service_grade"]];
            [hotelPrice addObject:[dic objectForKey:@"avg_price"]];
            [hoteldistance addObject:[dic objectForKey:@"distance"]];
        }
    }
    
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
