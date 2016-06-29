//
//  ScenicSpotGuideViewController.m
//  Manyou
//
//  Created by Yang Eastern on 14/12/7.
//  Copyright (c) 2014年 yangjf. All rights reserved.
//

#import "ScenicSpotGuideViewController.h"
#import "DetailViewController.h"
#import "CommonTools.h"
#import "ZipArchive.h"


#define Unselected_Spot_Btn_Alpha 0.5
#define TimeInterval_Between_Spot 4

#define Selected_Spot_Color RGB(255, 255, 0)
#define Unselected_Spot_Color RGB(16, 124, 188)

#define Max_Map_Scale 2

@interface ScenicSpotGuideViewController ()
{
    BOOL isShow;//是否显示线路
    UIView * routeSelectView;
}
@end

@implementation ScenicSpotGuideViewController

@synthesize scenic;
@synthesize scenicDetail;
@synthesize currentRoute;

- (void)viewDidLoad {
    [super viewDidLoad];
    _defaultView.backgroundColor = [UIColor whiteColor];
    
    isShow = YES;
    self.titleView.hidden = NO;
    self.titleLabel.text = self.data.scenicName;
    [self initWithBackBtn];
    

    routeTextScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _defaultView.height - 43 -50, App_Frame_Width, 50)];
    routeTextScrollView.backgroundColor = [UIColor whiteColor];
    routeTextScrollView.showsHorizontalScrollIndicator = NO;
    routeTextScrollView.showsVerticalScrollIndicator = NO;
    [_defaultView addSubview:routeTextScrollView];

    mapScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.titleView.bottom, App_Frame_Width, _defaultView.height - self.titleView.bottom - 43)];
    mapScrollView.backgroundColor = [UIColor whiteColor];
    mapScrollView.showsHorizontalScrollIndicator = NO;
    mapScrollView.showsVerticalScrollIndicator = NO;
    [_defaultView addSubview:mapScrollView];
    
    // 缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [_defaultView addGestureRecognizer:pinchGestureRecognizer];
    
    UITapGestureRecognizer* doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];
    doubleRecognizer.numberOfTapsRequired = 2; // 双击
    [_defaultView addGestureRecognizer:doubleRecognizer];
    
    //底部工具栏
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, _defaultView.height - 43, App_Frame_Width, 43)];
    bottomBar.backgroundColor = [UIColor whiteColor];
    [_defaultView addSubview:bottomBar];
    
    //底部工具栏上的按钮
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 100, 24)];
    lbl.text = @"路线规划";
    lbl.textColor = FontColorA;
    lbl.font = [UIFont boldSystemFontOfSize:13];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.userInteractionEnabled = YES;
    [bottomBar addSubview:lbl];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showRouteSelect)];
    [lbl addGestureRecognizer:tap];
    
    favoriteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    favoriteBtn.frame = CGRectMake(App_Frame_Width - 20 - 64, 9, 64, 24);
    favoriteBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [favoriteBtn setTitle:@"IUU助手" forState:(UIControlStateNormal)];
    [favoriteBtn setTitleColor:FontColorA forState:(UIControlStateNormal)];
    [favoriteBtn addTarget:self action:@selector(favoriteClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:favoriteBtn];
    
    favoriteFilePath = [[FileTools defaultTools] GetFullFilePathInDocuments:@"favorite.plist"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)backClick
{
    //停止广告轮播
    [adTimer invalidate];
    
    //停止语音
    [audioPlayer stop];
}

- (void)scaleToNewSize:(float)newMapScale
{
    float newWidth = mapWidth * newMapScale;
    float newHeight = mapHeight * newMapScale;
    if (!(newHeight < mapScrollView.frame.size.height || newWidth < mapScrollView.frame.size.width))
    {
        //找到原来中心坐标
        float x = (mapScrollView.contentOffset.x + App_Frame_Width / 2) / mapScale;
        float y = (mapScrollView.contentOffset.y + _defaultView.height / 2) / mapScale;
        
        //执行缩放
        mapView.frame = CGRectMake(0, 0, newWidth, newHeight);
        routeView.frame = mapView.frame;
        mapScrollView.contentSize = CGSizeMake(newWidth, newHeight);
        
        //计算出新的中心坐标
        x = x / mapWidth * newWidth;
        y = y / mapHeight * newHeight;
        
        //重新定位气泡的位置
        /*
        float oldBalloonX = (balloon.frame.origin.x + 37) / mapScale;
        float oldBalloonY = (balloon.frame.origin.y + 42) / mapScale;
        NSLog(@"oldBalloonX %f oldBalloonY %f", oldBalloonX, oldBalloonY);
        balloon.frame = CGRectMake(oldBalloonX * newMapScale - 37, oldBalloonY * newMapScale - 42, 74, 42);
        [[balloon superview] bringSubviewToFront:balloon];
         */
        
        float oldUUX = (uu_walk.frame.origin.x + 15) / mapScale;
        float oldUUY = (uu_walk.frame.origin.y + 15) / mapScale;
        uu_walk.frame = CGRectMake(oldUUX * newMapScale - 15, oldUUY * newMapScale - 15, 30, 30);
        [[uu_walk superview] bringSubviewToFront:uu_walk];
        
        //计算scrollView的offset;
        x = x - App_Frame_Width / 2;
        y = y - App_Frame_Height / 2;
        
        if (x < 0) {
            x = 0;
        }
        if (y < 0) {
            y = 0;
        }
        if (x + App_Frame_Width > mapWidth * newMapScale) {
            x = mapWidth * newMapScale - App_Frame_Width;
        }
        if (y + mapScrollView.frame.size.height > mapHeight * newMapScale) {
            y = mapHeight * newMapScale - mapScrollView.frame.size.height;
        }
        
        //hotBtns 重新调整位置
        for (UIButton *hotBtn in hotBtns) {
            NSString *spotId = [hotBtn titleForState:UIControlStateReserved];
            NSDictionary *spot = [scenicSpots objectForKey:spotId];
            float longitude = [[spot objectForKey:Relative_Longitude] floatValue];
            float latitude = [[spot objectForKey:Relative_Latitude] floatValue];
            float width = [[spot objectForKey:Relative_Width] floatValue] / 2;
            float height = [[spot objectForKey:Relative_Height] floatValue] / 2;
            float cx = longitude / mapMaxX * mapWidth * newMapScale;
            float cy = (mapHeight - latitude / mapMaxY * mapHeight) * newMapScale;

            //NSLog(@"spotId:%@ %f %f %f", spotId, cx, cy, newMapScale);
            
            if (hotBtn.tag == 0) {
                hotBtn.frame = CGRectMake(cx - width / 2, cy - height / 2, width, height);
            }
            else if (hotBtn.tag == 1) {
                hotBtn.frame = CGRectMake(cx - 12, cy + 5, 24, 20);
            }
        }

        mapScrollView.contentOffset = CGPointMake(x, y);
        
        mapScale = newMapScale;
    }
}

- (void)pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        float scale = pinchGestureRecognizer.scale;
        float newMapScale = mapScale * scale;
        if (newMapScale > Max_Map_Scale)
        {
            newMapScale = Max_Map_Scale;
        }
        
        [self scaleToNewSize:newMapScale];
        
        pinchGestureRecognizer.scale = 1;
    }
}

- (void)doubleTap
{
    float newMapScale = mapScale + 0.2;
    if (newMapScale > Max_Map_Scale) {
        newMapScale = Max_Map_Scale;
    }
    
    [UIView beginAnimations:_defaultView.description context:nil];
    [UIView setAnimationDuration:0.5];
    [self scaleToNewSize:newMapScale];
    [UIView commitAnimations];
}

- (void)showMap {
    titleLabel.text = self.data.scenicName;

//    [CommonTools clearView:mapScrollView];

    //加载地图
    FileTools *fileTools = [FileTools defaultTools];
    NSString *mapFilePath = [fileTools GetFullFilePathInDocuments:[NSString stringWithFormat:@"scenic%@/%@", self.data.scenicId, [scenicDetail objectForKey:Scenic_Map_Url]]];


    UIImage *img = [[UIImage alloc] initWithContentsOfFile:mapFilePath];
    
    UIImageView * iamge = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0.01, 0.01)];
    [self.view addSubview:iamge];

    mapWidth = img.size.width / 2;
    mapHeight = img.size.height / 2;

    //尝试初始地图大小缩小到0.6，如果太小，那缩小到地图区域的高度或宽度。
    mapScale = 0.6;
    float smallMapWidth = mapWidth * mapScale;
    float smallMapHeight = mapHeight * mapScale;
    float widthRate = smallMapWidth / mapScrollView.frame.size.width;
    float heightRate = smallMapHeight / mapScrollView.frame.size.height;
    if (widthRate < 1 || heightRate < 1)
    {
        if (heightRate < widthRate)
        {
            mapScale = mapScrollView.frame.size.height / mapHeight;
        }
        else
        {
            mapScale = mapScrollView.frame.size.width / mapWidth;
        }
    }
    
    mapView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mapWidth * mapScale, mapHeight * mapScale)];
    mapView.image = img;

    [mapScrollView addSubview:mapView];

    mapMaxX = [[scenicDetail objectForKey:Scenic_Map_Max_X] floatValue];
    mapMaxY = [[scenicDetail objectForKey:Scenic_Map_Max_Y] floatValue];
    
    mapScrollView.contentSize = CGSizeMake(mapWidth * mapScale, mapHeight * mapScale);
    
    scenicSpots = [[NSMutableDictionary alloc] init];
    NSArray *spots = [scenicDetail objectForKey:Scenic_Map];
    for (NSDictionary *spot in spots)
    {
        NSString *idStr = [spot objectForKey:ID];
        [scenicSpots setObject:spot forKey:idStr];
    }
    
    [self showHotBtns];

    if (currentRoute != -1)
    {
        [self showRoute];
    }
    else
    {
        //还未选择线路的时候，先定位到地图中央。
        float x = (mapWidth - App_Frame_Width) / 2;
        float y = (mapHeight - mapScrollView.frame.size.height) / 2;
        mapScrollView.contentOffset = CGPointMake(x * mapScale, y * mapScale);
        
        //隐藏路线Bar
        mapScrollView.frame = CGRectMake(0, self.titleView.bottom, App_Frame_Width, _defaultView.height - self.titleView.bottom - 43);
    }
    
    //检查并显示广告栏
    //[self showAD];
    [NSThread detachNewThreadSelector:@selector(showAD) toTarget:self withObject:nil];
    
    //判断是否已收藏
//    [self showFavorite];
}

- (void)showRoute
{
    //如果有旧的线路图，先删除
    if (routeView != nil)
    {
        [routeView removeFromSuperview];
        routeView = nil;
    }
    
    NSArray *routes = [scenicDetail objectForKey:Scenic_Recommend_Line];
    NSArray *routeLines = [routes objectAtIndex:currentRoute];
    routeLines = [routeLines subarrayWithRange:NSMakeRange(1, [routeLines count] - 1)];
    //NSDictionary *route = [routeLines objectAtIndex:0];

    //地图之上加上路线图层
    routeView = [[RouteView alloc] initWithFrame:CGRectMake(0, 0, mapWidth, mapHeight)];
    
    routeView.maxMapX = mapMaxX;
    routeView.maxMapY = mapMaxY;
    routeView.lines = routeLines;
    routeView.scenicSpots = scenicSpots;
    routeView.alpha = 0.7;
    [mapScrollView addSubview:routeView];
    [self performSelector:@selector(adjustRouteViewScale) withObject:nil afterDelay:0.01];
    
    //有线路选择，定位到线路的起始景点
    NSDictionary *firstLine = [routeLines objectAtIndex:0];
//    NSLog(@"firstLine:%@", firstLine);
    
    NSString *firstSpotId = [firstLine objectForKey:A_Spot_Id];
//    NSLog(@"firstSpotId:%@",firstSpotId);
    
//    NSLog(@"scenicSpots:%@", scenicSpots);
    NSDictionary *spot = [scenicSpots objectForKey:firstSpotId];
//    NSLog(@"spot:%@", spot);
    
    float longtitude = [[spot objectForKey:Relative_Longitude] floatValue];
    float latitude = [[spot objectForKey:Relative_Latitude] floatValue];
    
    [self locateToLongitue:longtitude latitude:latitude text:[spot objectForKey:Scenic_Spot_Name]];
        
    //清空旧的，并显示新线路的景点名称
    [CommonTools clearView:routeTextScrollView];
    if (spotBtns == nil)
    {
        spotBtns = [[NSMutableDictionary alloc] init];
        spotTexts = [[NSMutableDictionary alloc] init];
        spotImgs = [[NSMutableDictionary alloc]init];
    }
    else
    {
        [spotBtns removeAllObjects];
        [spotTexts removeAllObjects];
        [spotImgs removeAllObjects];
    }
    
    float x = 20;
    firstLine = [routeLines objectAtIndex:0];
    firstSpotId = [firstLine objectForKey:A_Spot_Id];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(x, 5, 26, 26);
    [btn setBackgroundImage:[[UIColor colorWithRed:228/255.0f green:68/255.0f blue:87/255.0f alpha:1.0] image] forState:UIControlStateNormal];
    btn.tag = 0;
    btn.layer.cornerRadius = btn.height /2;
    btn.layer.masksToBounds = YES;
    [btn setTitle:@"1" forState:(UIControlStateNormal)];
    [btn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [btn addTarget:self action:@selector(spotClick:) forControlEvents:UIControlEventTouchUpInside];
    [routeTextScrollView addSubview:btn];
    NSNumber *key = [NSNumber numberWithLong:btn.tag];
    [spotBtns setObject:btn forKey:key];
    
    spot = [scenicSpots objectForKey:firstSpotId];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(x - 13, 31, 52, 19)];
    lbl.font = [UIFont systemFontOfSize:10];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.textColor = [UIColor blackColor];
    lbl.text = [spot objectForKey:Scenic_Spot_Name];
    [routeTextScrollView addSubview:lbl];
    [spotTexts setObject:lbl forKey:key];
    
//    NSString *idStr = [scenic objectForKey:ID];
//    NSString *dir = [[FileTools defaultTools] GetFullFilePathInDocuments:[NSString stringWithFormat:@"scenic%@", idStr]];
//    NSString *mp3File = [spot objectForKey:Scenic_Spot_Voice];
//    if (mp3File != nil && [mp3File length] > 0) {
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        NSString *audioFile = [dir stringByAppendingFormat:@"/%@", mp3File];
//        if ([fileManager fileExistsAtPath:audioFile]) {
//            //如果声音文件存在，就显示声音播放的小喇叭图标
//            UIImageView *hornImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x + 10, 15, 20, 20)];
//            hornImgView.image = [UIImage imageNamed:@"horn.png"];
//            [routeTextScrollView addSubview:hornImgView];
//        }
//    }
    
    NSUInteger count = [routeLines count];
    for (int i = 0; i < count; i ++)
    {
        // 景点间的连接线
        x += 26;
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(x, 17, 27, 2)];
        line.image = [[UIColor greenColor] image];
        line.tag = i;
        [routeTextScrollView addSubview:line];
        NSNumber *keyImg = [NSNumber numberWithLong:i];
        [spotImgs setObject:line forKey:keyImg];

        
        x += 27;
        NSString *spotId = [[routeLines objectAtIndex:i] objectForKey:B_Spot_Id];

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(x, 5, 26, 26);
        [btn setBackgroundImage:[[UIColor colorWithRed:53/255.0f green:201/255.0f blue:106/255.0f alpha:1.0] image] forState:UIControlStateNormal];
        btn.tag = i + 1;
        btn.layer.cornerRadius = btn.height /2;
        btn.layer.masksToBounds = YES;
        [btn setTitle:[NSString stringWithFormat:@"%ld",(long)btn.tag+1] forState:(UIControlStateNormal)];
        [btn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [btn addTarget:self action:@selector(spotClick:) forControlEvents:UIControlEventTouchUpInside];
        [routeTextScrollView addSubview:btn];
        key = [NSNumber numberWithLong:btn.tag];
        [spotBtns setObject:btn forKey:key];
        
        spot = [scenicSpots objectForKey:spotId];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(x - 13, 31, 52, 19)];
        lbl.font = [UIFont systemFontOfSize:10.5];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text = [spot objectForKey:Scenic_Spot_Name];
        lbl.textColor = [UIColor blackColor];
        [routeTextScrollView addSubview:lbl];
        [spotTexts setObject:lbl forKey:key];
        
        //先暂时不在景点圆点上显示喇叭图标
        /*
        mp3File = [spot objectForKey:Scenic_Spot_Voice];
        if (mp3File != nil && [mp3File length] > 0) {
            NSString *audioFile = [dir stringByAppendingFormat:@"/%@", mp3File];
            if ([[NSFileManager defaultManager] fileExistsAtPath:audioFile]) {
                //如果声音文件存在，就显示声音播放的小喇叭图标
                UIImageView *hornImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x + 10, 15, 20, 20)];
                hornImgView.image = [UIImage imageNamed:@"horn.png"];
                [routeTextScrollView addSubview:hornImgView];
            }
        }
         */
    }
    
    NSLog(@"spotBtns:%@", spotBtns);
    
    routeTextScrollView.contentSize = CGSizeMake(x + 80, 50);
    routeTextScrollView.contentOffset = CGPointZero;
    routeTextScrollView.alpha = 1;
    currentSpotId = firstSpotId;
    
    //调整地图区域的大小，显示出路线Bar
    mapScrollView.frame = CGRectMake(0, self.titleView.bottom, App_Frame_Width, _defaultView.height - self.titleView.bottom - 43 - 50);
    
    //重新加载热区按钮
    [self showHotBtns];
}

- (void)showHotBtns
{
    if (hotBtns == nil)
    {
        hotBtns = [[NSMutableArray alloc] init];
    }
    else
    {
        for (UIButton *hotBtn in hotBtns)
        {
            [hotBtn removeFromSuperview];
        }
        [hotBtns removeAllObjects];
    }
    
    for (NSString *spotId in [scenicSpots keyEnumerator])
    {
        NSDictionary *spot = [scenicSpots objectForKey:spotId];
        //点击热区
        float longitude = [[spot objectForKey:Relative_Longitude] floatValue];
        float latitude = [[spot objectForKey:Relative_Latitude] floatValue];
        float width = [[spot objectForKey:Relative_Width] floatValue];
        float height = [[spot objectForKey:Relative_Height] floatValue];
        float cx = longitude / mapMaxX * mapWidth * mapScale;
        float cy = (mapHeight - latitude / mapMaxY * mapHeight) * mapScale;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(cx - width / 2, cy - height / 2, width, height);
        btn.tag = 0;
        [btn setTitle:spotId forState:UIControlStateReserved];
        [btn addTarget:self action:@selector(hotBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [hotBtns addObject:btn];
        [mapScrollView addSubview:btn];
        
        //如果有语音，则显示喇叭图标
        NSString *mp3File = [spot objectForKey:Scenic_Spot_Voice];
        if (mp3File != nil && [mp3File length] > 0)
        {
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(cx - 12, cy + 5, 24, 20);
            btn.tag = 1;//喇叭图标的tag为1，调整缩放比的使用用来做判断
            [btn setTitle:spotId forState:UIControlStateReserved];
            [btn setBackgroundImage:[UIImage imageNamed:@"horn.png"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(hotBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [hotBtns addObject:btn];
            [mapScrollView addSubview:btn];
        }
    }
}

- (void)adjustRouteViewScale
{
    routeView.mapScale = mapScale;
}

- (void)locateToLongitue:(float)longtitude latitude:(float)latitude text:(NSString*)text
{
   
    float cx = longtitude / mapMaxX * mapWidth * mapScale;
    float cy = (mapHeight - latitude / mapMaxY * mapHeight) * mapScale;
    
    float x = cx - App_Frame_Width / 2;
    float y = cy - mapScrollView.frame.size.height / 2;
    
    if (x < 0)
    {
        x = 0;
    }
    if (y < 0)
    {
        y = 0;
    }
    
    if (x + App_Frame_Width > mapWidth * mapScale)
    {
        x = mapWidth * mapScale - App_Frame_Width;
    }
    if (y + mapScrollView.frame.size.height > mapHeight * mapScale)
    {
        y = mapHeight * mapScale - mapScrollView.frame.size.height;
    }
    
//    [UIView beginAnimations:_defaultView.description context:nil];
//    [UIView setAnimationDuration:0.5];
//    [UIView commitAnimations];
    
    if (uu_walk == nil)
    {
        uu_walk = [[UIImageView alloc] initWithFrame:CGRectMake(cx - 15, cy - 35, 30, 30)];
        uu_walk.animationDuration = 1;
        uu_walk.alpha = 0.8;
    }
    /*取消地名的标签
    if (balloon == nil) {
        balloon = [[UIView alloc] init];
        
        UIImageView *balloonBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 74, 42)];
        balloonBg.image = [UIImage imageNamed:@"select_balloon.png"];
        [balloon addSubview:balloonBg];

        //uu_walk = [[UIImageView alloc] initWithFrame:CGRectMake(cx - 20, cy - 80, 40, 50)];
     
        balloonLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 4, 66, 30)];
        balloonLabel.font = [UIFont systemFontOfSize:12];
        balloonLabel.numberOfLines = 2;
        balloonLabel.textAlignment = NSTextAlignmentCenter;
        balloonLabel.textColor = [UIColor whiteColor];
        [balloon addSubview:balloonLabel];
    }
    balloon.frame = CGRectMake(cx - 37, cy - 42, 74, 42);
    balloonLabel.text = text;
    [mapScrollView addSubview:balloon];
    [[balloon superview] bringSubviewToFront:balloon];
     */
    
    [mapScrollView addSubview:uu_walk];
    uu_walk.image = [UIImage imageNamed:@"default_head.png"];
    [uu_walk stopAnimating];

    [UIView beginAnimations:@"goto current dot" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    mapScrollView.contentOffset = CGPointMake(x, y);
    uu_walk.frame = CGRectMake(cx - 15, cy - 35, 30, 30);
    [mapScrollView bringSubviewToFront:uu_walk];
    [UIView commitAnimations];
}

- (void)showRouteSelect {
    NSLog(@"showRouteSelect");
//    
//    if (isShow) {
//        routeSelectView = [[UIView alloc]initWithFrame:CGRectMake(10, _defaultView.height - 43 - 20 - 60, 100, 70)];
//        routeSelectView.backgroundColor = [UIColor clearColor];
//        [_defaultView addSubview:routeSelectView];
//        
//        UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 60)];
//        bgView.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.9];
//        [routeSelectView addSubview:bgView];
//        
//        UIImageView * triangleImg = [[UIImageView alloc]initWithFrame:CGRectMake(20, 60, 10, 10)];
//        triangleImg.backgroundColor = [UIColor whiteColor];
//        [routeSelectView addSubview:triangleImg];
//        
//        UIButton * button = [UIButton buttonWithType:(UIButtonTypeCustom)];
//        [button setFrame:CGRectMake(0, 0, 100, 30)];
//        [button setTitleColor:FontColorA forState:(UIControlStateNormal)];
//        [button setTitle:@"经典路线" forState:(UIControlStateNormal)];
//        [button.titleLabel setFont:[UIFont systemFontOfSize:13]];
//        [button setTag:1];
//        [button addTarget:self action:@selector(routeAction:) forControlEvents:(UIControlEventTouchUpInside)];
//        
//        CALayer *layer = [CALayer layer];
//        [layer setFrame:CGRectMake(0, button.bottom, button.width, 1)];
//        [layer setBackgroundColor:[UIColor groupTableViewBackgroundColor].CGColor];
//        [button.layer addSublayer:layer];
//        [routeSelectView addSubview:button];
//        
//        
//        UIButton * button1 = [UIButton buttonWithType:(UIButtonTypeCustom)];
//        [button1 setFrame:CGRectMake(0, 30, 100, 30)];
//        [button1 setTitleColor:FontColorA forState:(UIControlStateNormal)];
//        [button1 setTitle:@"畅游路线" forState:(UIControlStateNormal)];
//        [button1.titleLabel setFont:[UIFont systemFontOfSize:13]];
//        [button1 setTag:2];
//        [button1 addTarget:self action:@selector(routeAction:) forControlEvents:(UIControlEventTouchUpInside)];
//        [routeSelectView addSubview:button1];
//        isShow = NO;
//    }
//    else
//    {
//        currentRoute = -1;
//        [routeView removeFromSuperview];
//        routeTextScrollView.alpha = 0;
//        routeView = nil;
//        
//        //地图恢复原大小
//        mapScrollView.frame = CGRectMake(0, self.titleView.bottom, App_Frame_Width, _defaultView.height - self.titleView.bottom - 43);
//        
//        //广告条位置下移
//        adImgView.frame = CGRectMake((App_Frame_Width - 300) / 2 , App_Frame_Height - 43 - 36, 300, 36);
//        adBtn.frame = adImgView.frame;
//        adCloseBtn.frame = CGRectMake((App_Frame_Width - 300) / 2 + 280, App_Frame_Height - 43 - 36 - 20, 20, 20);
//        
//        [routeSelectView removeFromSuperview];
//        isShow = YES;
//    }
 
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择线路" delegate:self cancelButtonTitle:@"关闭线路显示" destructiveButtonTitle:nil otherButtonTitles:nil];
    NSArray *routes = [scenicDetail objectForKey:Scenic_Recommend_Line];
    NSInteger count = [routes count];
    for (int i = 0; i < count; i ++) {
        NSDictionary *route = [[routes objectAtIndex:i] objectAtIndex:0];
        NSString *name = [route objectForKey:Recommend_Route_Name];
        NSString *routeTotalTime = [route objectForKey:Route_Total_Time];
        if (name != nil && routeTotalTime != nil && [routeTotalTime length] > 0) {
            [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@ (%@)", name, routeTotalTime]];
        }
        else {
            [actionSheet addButtonWithTitle:name];
        }
    }
    [actionSheet showInView:_defaultView];
}
- (void)routeAction:(UIButton *)sender
{
    [routeSelectView removeFromSuperview];
    //广告条位置上移
    adImgView.frame = CGRectMake((App_Frame_Width - 300) / 2 , App_Frame_Height - 43 - 36 - 50, 300, 36);
    adBtn.frame = adImgView.frame;
    adCloseBtn.frame = CGRectMake((App_Frame_Width - 300) / 2 + 280, App_Frame_Height - 43 - 36 - 20 - 50, 20, 20);
    
    currentRoute =  sender.tag-1;

    [self showRoute];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%d", (int)buttonIndex);
    if (buttonIndex == 0) {
        //关闭线路的显示
        currentRoute = -1;
        [routeView removeFromSuperview];
        routeTextScrollView.alpha = 0;
        routeView = nil;
        
        //地图恢复原大小
        mapScrollView.frame = CGRectMake(0, self.titleView.bottom, App_Frame_Width, _defaultView.height - self.titleView.bottom - 43);
        
        //广告条位置下移
        adImgView.frame = CGRectMake((App_Frame_Width - 300) / 2 , App_Frame_Height - 43 - 36, 300, 36);
        adBtn.frame = adImgView.frame;
        adCloseBtn.frame = CGRectMake((App_Frame_Width - 300) / 2 + 280, App_Frame_Height - 43 - 36 - 20, 20, 20);
        
        return;
    }
    else {
        //广告条位置上移
        adImgView.frame = CGRectMake((App_Frame_Width - 300) / 2 , App_Frame_Height - 43 - 36 - 50, 300, 36);
        adBtn.frame = adImgView.frame;
        adCloseBtn.frame = CGRectMake((App_Frame_Width - 300) / 2 + 280, App_Frame_Height - 43 - 36 - 20 - 50, 20, 20);
    }
    
    currentRoute = buttonIndex - 1;
    
    [self showRoute];
}

- (void)spotClick:(UIButton *)btn {
    //定位到对应的景点
    float longtitude = 0;
    float latitude = 0;
    
    NSArray *routes = [scenicDetail objectForKey:Scenic_Recommend_Line];
    NSArray *routeLines = [routes objectAtIndex:currentRoute];
    routeLines = [routeLines subarrayWithRange:NSMakeRange(1, [routeLines count] - 1)];
    NSString *spotName = nil;
    NSString *startSpotId = currentSpotId;

    if (btn.tag == 0) {
        NSDictionary *firstLine = [routeLines objectAtIndex:0];
        
        currentSpotId = [firstLine objectForKey:A_Spot_Id];
        
        NSDictionary *spot = [scenicSpots objectForKey:currentSpotId];
        spotName = [spot objectForKey:Scenic_Spot_Name];
        
        longtitude = [[spot objectForKey:Relative_Longitude] floatValue] / 2;
        latitude = [[spot objectForKey:Relative_Latitude] floatValue] / 2;
    }
    else {
        NSDictionary *line = [routeLines objectAtIndex:btn.tag - 1];
        
        currentSpotId = [line objectForKey:B_Spot_Id];
        
        NSDictionary *spot = [scenicSpots objectForKey:currentSpotId];
        spotName = [spot objectForKey:Scenic_Spot_Name];
        
        longtitude = [[spot objectForKey:Relative_Longitude] floatValue] / 2;
        latitude = [[spot objectForKey:Relative_Latitude] floatValue] / 2;
    }
    
//    UIImage *blueSpot = [UIImage imageNamed:@"blue_spot.png"];
//    UIImage *yellowSpot = [UIImage imageNamed:@"yellow_spot.png"];
    for (UIImageView * imag in [spotImgs objectEnumerator]) {
        if (imag.tag < btn.tag) {
            imag.image = [[UIColor colorWithRed:228/255.0f green:68/255.0f blue:87/255.0f alpha:1.0]image];
        }
        else
        {
            imag.image = [[UIColor colorWithRed:53/255.0f green:201/255.0f blue:106/255.0f alpha:1.0]image];
        }
    }
    
    NSInteger oldBtnTag = -1;
    for (UIButton *aBtn in [spotBtns objectEnumerator]) {
        if ([[aBtn titleForState:UIControlStateReserved] isEqualToString:@"current"]) {
            oldBtnTag = aBtn.tag;
        }
//        aBtn.alpha = Unselected_Spot_Btn_Alpha;
        if (aBtn.tag<btn.tag) {
            [aBtn setBackgroundImage:[[UIColor colorWithRed:228/255.0f green:68/255.0f blue:87/255.0f alpha:1.0]image] forState:UIControlStateNormal];
        }
        else
        [aBtn setBackgroundImage:[[UIColor colorWithRed:53/255.0f green:201/255.0f blue:106/255.0f alpha:1.0]image] forState:UIControlStateNormal];
        [aBtn setTitle:nil forState:UIControlStateReserved];
    }
    
    NSNumber *key = [NSNumber numberWithLong:btn.tag];
    UIButton *newBtn = [spotBtns objectForKey:key];
//    newBtn.alpha = 1;
    [newBtn setBackgroundImage:[[UIColor colorWithRed:228/255.0f green:68/255.0f blue:87/255.0f alpha:1.0]image] forState:UIControlStateNormal];
    [newBtn setTitle:@"current" forState:UIControlStateReserved];
    
    for (UILabel *lbl in [spotTexts objectEnumerator]) {
        lbl.textColor = [UIColor blackColor];
    }
    UILabel *newLbl = [spotTexts objectForKey:key];
    newLbl.textColor = [UIColor blackColor];

    if (![startSpotId isEqualToString:currentSpotId]) {
        BOOL forward = oldBtnTag < newBtn.tag ? TRUE : FALSE;
        [self animateFrom:startSpotId to:currentSpotId forward:forward];
    }

    [self playAudio];
}

- (void)animateFrom:(NSString*)startSpotId to:(NSString*)endSpotId forward:(BOOL)forward{
    if (!forward) {
        //如果路径是向后的，则直接跳转过去
        NSDictionary *spot = [scenicSpots objectForKey:currentSpotId];
        NSString *spotName = [spot objectForKey:Scenic_Spot_Name];
        
        [self locateToLongitue:[[spot objectForKey:Relative_Longitude] floatValue] latitude:[[spot objectForKey:Relative_Latitude] floatValue] text:spotName];

        return;
    }
    
    NSArray *routes = [scenicDetail objectForKey:Scenic_Recommend_Line];
    NSArray *routeLines = [routes objectAtIndex:currentRoute];
    routeLines = [routeLines subarrayWithRange:NSMakeRange(1, [routeLines count] - 1)];

    NSMutableArray *lines = [[NSMutableArray alloc] init];
    
    /*
    //先找出两点间的路径和行进方向
    BOOL forward = TRUE;//先确定方向，如果前方有，就不后退的原则。主要考虑回到景区大门的情况。
    for (NSDictionary *line in routeLines) {
        NSString *aSpotId = [line objectForKey:A_Spot_Id];
        NSString *bSpotId = [line objectForKey:B_Spot_Id];

        if ([aSpotId isEqualToString:startSpotId]) {
            forward = TRUE;
            break;
        }
        else if ([bSpotId isEqualToString:endSpotId]) {
            forward = FALSE;
            break;
        }
    }
     */
    
    if (forward) {
        BOOL begin = FALSE;
        for (NSDictionary *line in routeLines) {
            NSString *aSpotId = [line objectForKey:A_Spot_Id];
            NSString *bSpotId = [line objectForKey:B_Spot_Id];
            if (!begin) {
                if ([aSpotId isEqualToString:startSpotId]) {
                    begin = TRUE;
                }
            }
            
            if (begin) {
                [lines addObject:line];
                if ([bSpotId isEqualToString:endSpotId]) {
                    break;
                }
            }
        }
    }
    else {
        NSInteger lineCount = [routeLines count];
        BOOL begin = FALSE;
        for (NSInteger i = lineCount - 1; i >= 0; i --) {
            NSDictionary *line = [routeLines objectAtIndex:i];
            NSString *aSpotId = [line objectForKey:A_Spot_Id];
            NSString *bSpotId = [line objectForKey:B_Spot_Id];
            if (!begin) {
                if ([bSpotId isEqualToString:startSpotId]) {
                    begin = TRUE;
                }
            }
            if (begin) {
                [lines addObject:line];
                if ([aSpotId isEqualToString:endSpotId]) {
                    break;
                }
            }
        }
    }
    
//    NSLog(@"forward:%@ lines:%@", forward ? @"true" : @"false", lines);
    
    //把所有的坐标点放入一个Array中
    if (dots == nil) {
        dots = [[NSMutableArray alloc] init];
    }
    else {
        [dots removeAllObjects];
    }
    if (forward) {
        NSDictionary *spot = [scenicSpots objectForKey:startSpotId];
        [dots addObject:spot];
        
        for (NSDictionary *line in lines) {
            NSArray *lineDots = [line objectForKey:Recommend_Line_Section_Guide];
            for (NSDictionary *dot in lineDots) {
                [dots addObject:dot];
            }
            
            NSString *bSpotId = [line objectForKey:B_Spot_Id];
            NSDictionary *bSpot = [scenicSpots objectForKey:bSpotId];
            [dots addObject:bSpot];
        }
    }
    else {
        NSDictionary *spot = [scenicSpots objectForKey:startSpotId];
        [dots addObject:spot];
        
        //NSInteger lineCount = [lines count];
        //for (int i = lineCount - 1; i >= 0; i --) {
        for (NSDictionary *line in lines) {
            //NSDictionary *line = [lines objectAtIndex:i];
            NSArray *lineDots = [line objectForKey:@"线路段"];
            NSInteger count = [lineDots count];
            for (NSInteger j = count - 1; j >= 0; j --) {
                [dots addObject:[lineDots objectAtIndex:j]];
            }
            
            NSString *aSpotId = [line objectForKey:A_Spot_Id];
            NSDictionary *aSpot = [scenicSpots objectForKey:aSpotId];
            [dots addObject:aSpot];
        }
    }
    
//    NSLog(@"dots:%@", dots);
    
    totalLength = 0;//先把所有线段的总长度计算出来
    NSUInteger dotsCount = [dots count];
    for (int i = 0; i < dotsCount - 1; i ++) {
        NSDictionary *dot1 = [dots objectAtIndex:i];
        NSDictionary *dot2 = [dots objectAtIndex:i + 1];
        
        float x1 = [[dot1 objectForKey:Relative_Longitude] floatValue];
        float y1 = [[dot1 objectForKey:Relative_Latitude] floatValue];
        float x2 = [[dot2 objectForKey:Relative_Longitude] floatValue];
        float y2 = [[dot2 objectForKey:Relative_Latitude] floatValue];
        
        float deltaX = x1 - x2;
        float deltaY = y1 - y2;
        
        float length = sqrtf(deltaX * deltaX + deltaY * deltaY);
        totalLength += length;
    }
    //按线路长度计算总时间
    totalTime = totalLength / 100;//1秒钟50个点
    
    animateDotIndex = 0;
    //先移动到起始点
    NSDictionary *dot = [dots objectAtIndex:0];
    float cx = [[dot objectForKey:Relative_Longitude] floatValue] / mapMaxX * mapWidth * mapScale;
    float cy = (mapHeight - [[dot objectForKey:Relative_Latitude] floatValue] / mapMaxY * mapHeight) * mapScale;
    [UIView beginAnimations:@"goto start dot" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDidStopSelector:@selector(animateToNextDot)];
    //uu_walk.frame = CGRectMake(cx - 20, cy - 50, 40, 50);
    uu_walk.frame = CGRectMake(cx - 15, cy - 15, 30, 30);
    mapScrollView.contentOffset = CGPointMake(cx - App_Frame_Width / 2, cy - mapScrollView.frame.size.height / 2);
    [UIView commitAnimations];
    
    //uu开始走路的动画
    //uu_walk.animationImages = uuWalkLeftImgs;
    //[uu_walk startAnimating];
}

- (void)animateToNextDot {
    NSLog(@"animateToNextDot %d", animateDotIndex);
    
    if (animateDotIndex < [dots count] - 1) {
        NSDictionary *dot1 = [dots objectAtIndex:animateDotIndex];
        animateDotIndex ++;
        NSDictionary *dot2 = [dots objectAtIndex:animateDotIndex];
        
        float x1 = [[dot1 objectForKey:Relative_Longitude] floatValue];
        float y1 = [[dot1 objectForKey:Relative_Latitude] floatValue];
        float x2 = [[dot2 objectForKey:Relative_Longitude] floatValue];
        float y2 = [[dot2 objectForKey:Relative_Latitude] floatValue];
        
        NSLog(@"(%f, %f) -> (%f, %f)", x1, y1, x2, y2);
        
        float deltaX = x1 - x2;
        float deltaY = y1 - y2;
        
        float length = sqrtf(deltaX * deltaX + deltaY * deltaY);

        float cx = x2 / mapMaxX * mapWidth * mapScale;
        float cy = (mapHeight - y2 / mapMaxY * mapHeight) * mapScale;

        [UIView beginAnimations:[NSString stringWithFormat:@"goto dot: %d", animateDotIndex] context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:totalTime * length / totalLength];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDidStopSelector:@selector(animateToNextDot)];
        
        //uu_walk.frame = CGRectMake(cx - 20, cy - 50, 40, 50);
        uu_walk.frame = CGRectMake(cx - 15, cy - 15, 30, 30);
        mapScrollView.contentOffset = CGPointMake(cx - App_Frame_Width / 2, cy - mapScrollView.frame.size.height / 2);
        
        [UIView commitAnimations];
    }
    else {
        NSDictionary *spot = [scenicSpots objectForKey:currentSpotId];
        NSString *spotName = [spot objectForKey:Scenic_Spot_Name];

        [self locateToLongitue:[[spot objectForKey:Relative_Longitude] floatValue] latitude:[[spot objectForKey:Relative_Latitude] floatValue] text:spotName];
    }
}

//- (void)audioClick {
//    if (audioPlayer != nil && audioPlayer.playing) {
//        [audioPlayer stop];
//    }
//    else {
//        [self playAudio];
//    }
//}

- (void)playAudio {
    UIButton *hornBtn = nil;
    for (UIButton *hotBtn in hotBtns) {
        if (hotBtn.tag == 1) {
            [hotBtn setBackgroundImage:[UIImage imageNamed:@"horn.png"] forState:UIControlStateNormal];
            if ([[hotBtn titleForState:UIControlStateReserved] isEqualToString:currentSpotId]) {
                hornBtn = hotBtn;
            }
        }
    }
    
    if (audioPlayer != nil) {
        if ([currentSpotId isEqualToString:currentAudioSpotId]) {
            if (audioPlayer.playing) {
                [audioPlayer pause];
                [hornBtn setBackgroundImage:[UIImage imageNamed:@"horn.png"] forState:UIControlStateNormal];
            }
            else {
                [audioPlayer play];
                [hornBtn setBackgroundImage:[UIImage imageNamed:@"horn_on.png"] forState:UIControlStateNormal];
            }
            return;
        }
        else {
            [audioPlayer stop];
            audioPlayer = nil;
        }
    }

    //播放新语音
    NSString *idStr = self.data.scenicId;
    NSString *dir = [[FileTools defaultTools] GetFullFilePathInDocuments:[NSString stringWithFormat:@"scenic%@", idStr]];
    NSDictionary *spot = [scenicSpots objectForKey:currentSpotId];
    NSString *mp3File = [spot objectForKey:Scenic_Spot_Voice];
    if (mp3File != nil && [mp3File length] > 0) {
        NSString *audioFile = [dir stringByAppendingFormat:@"/%@", mp3File];
        //NSLog(@"audioFile:%@", audioFile);
        
        BOOL isDir = FALSE;
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:audioFile isDirectory:&isDir];
        if (exist && !isDir) {
            @try {
                audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[[NSURL alloc]initFileURLWithPath:audioFile] error:nil];
                audioPlayer.volume = 1;
                audioPlayer.delegate = self;
                [audioPlayer play];
                [hornBtn setBackgroundImage:[UIImage imageNamed:@"horn_on.png"] forState:UIControlStateNormal];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }
            @finally {
                
            }
        }
        else {
            //语音文件未找到的情况
        }
    }
    currentAudioSpotId = currentSpotId;
}

- (void)hotBtnClick:(UIButton*)hotBtn {
    NSString *spotId = [hotBtn titleForState:UIControlStateReserved];
    
    BOOL inRoute = FALSE;
    NSInteger spotIndex = 0;
    if (currentRoute != -1) {
        NSArray *routes = [scenicDetail objectForKey:Scenic_Recommend_Line];
        NSArray *routeLines = [routes objectAtIndex:currentRoute];
        routeLines = [routeLines subarrayWithRange:NSMakeRange(1, [routeLines count] - 1)];
        for (NSDictionary *line in routeLines) {
            if (spotIndex == 0) {
                NSString *aSpotId = [line objectForKey:A_Spot_Id];
                if ([aSpotId isEqualToString:spotId]) {
                    inRoute = TRUE;
                    break;
                }
                else {
                    spotIndex ++;
                }
            }
            
            NSString *bSpotId = [line objectForKey:B_Spot_Id];
            if ([bSpotId isEqualToString:spotId]) {
                inRoute = TRUE;
                break;
            }
            else {
                spotIndex ++;
            }
        }
    }
    
    if (inRoute) {
        //如果景点在当前路径上，那么模拟在路径上的点击
        UIButton *spotBtn = [spotBtns objectForKey:[NSNumber numberWithLong:spotIndex]];
        [self spotClick:spotBtn];
    }
    else {
        //如果景点不在当前路径上，跳转到此景点
        NSDictionary *spot = [scenicSpots objectForKey:spotId];
        NSString *spotName = [spot objectForKey:Scenic_Spot_Name];
        
        [self locateToLongitue:[[spot objectForKey:Relative_Longitude] floatValue] latitude:[[spot objectForKey:Relative_Latitude] floatValue] text:spotName];
        currentSpotId = spotId;

        //播放语音
        [self playAudio];
    }
}

- (void)showAD {
    @autoreleasepool {
        NSString *scenicId = self.data.scenicId;
        
        FileTools *fileTools = [FileTools defaultTools];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *adFilePath = [fileTools GetFullFilePathInDocuments:[NSString stringWithFormat:@"scenicAdvert%@/scenicAdvert%@.json", scenicId, scenicId]];
        NSTimeInterval lastModified = 0;
        if ([fileManager fileExistsAtPath:adFilePath]) {
            NSDictionary *fileAttrs = [fileManager attributesOfItemAtPath:adFilePath error:nil];
            NSDate *date = [fileAttrs objectForKey:NSFileModificationDate];
            lastModified = [date timeIntervalSinceReferenceDate];
        }
        if ([NSDate timeIntervalSinceReferenceDate] - lastModified > TimeInterval_1Day) {
            @try {
                //先删除旧的广告文件目录
                [fileTools deleteDirInDocuments:[NSString stringWithFormat:@"scenicAdvert%@", scenicId]];
                
                //时间间隔大于1天以上，重新下载广告包
                NSString *zipFilePath = [fileTools GetFullFilePathInDocuments:[NSString stringWithFormat:@"scenicAdvert%@.zip", scenicId]];
                //1. 下载
                [NetTools download:[NSString stringWithFormat:Scenic_Advertise_URL, scenicId] andSaveTo:zipFilePath];
                
                //2. 解压
                ZipArchive *zip = [[ZipArchive alloc] init];
                [zip UnzipOpenFile:zipFilePath];
                [zip UnzipFileTo:[fileTools GetDocumentsPath] overWrite:YES];
                [zip UnzipCloseFile];
                
                //3. 删除zip文件
                [fileTools deleteDir:zipFilePath];
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }
        
        if ([fileManager fileExistsAtPath:adFilePath]) {
            if (adImgs == nil) {
                adImgs = [[NSMutableArray alloc] init];
                
                adImgView = [[UIImageView alloc] initWithFrame:CGRectMake((App_Frame_Width - 300) / 2 , App_Frame_Height - 43 - 36, 300, 36)];
                CALayer *layer = adImgView.layer;
                layer.borderColor = [[UIColor yellowColor] CGColor];
                layer.borderWidth = 1;
                layer.masksToBounds = YES;
                layer.cornerRadius = 5;
                
                adBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                adBtn.frame = adImgView.frame;
                [adBtn addTarget:self action:@selector(adClick) forControlEvents:UIControlEventTouchUpInside];
                
                adCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                adCloseBtn.frame = CGRectMake((App_Frame_Width - 300) / 2 + 280, App_Frame_Height - 43 - 36 - 20, 20, 20);
                [adCloseBtn addTarget:self action:@selector(adCloseClick) forControlEvents:UIControlEventTouchUpInside];
                [adCloseBtn setBackgroundImage:[UIImage imageNamed:@"closeIcon.png"] forState:UIControlStateNormal];
            }
            else {
                [adImgs removeAllObjects];
            }
            
            //准备数据
            adDatas = [fileTools GetJSONObjectFromFile:adFilePath];
            if ([adDatas count] > 0) {
                for (NSDictionary *adData in adDatas) {
                    NSString *adImgFile = [adData objectForKey:AD_Pic];
                    UIImage *img = [UIImage imageWithContentsOfFile:[fileTools GetFullFilePathInDocuments:[NSString stringWithFormat:@"scenicAdvert%@/%@", scenicId, adImgFile]]];
                    [adImgs addObject:img];
                }
                
                //添加到界面上
                [_defaultView addSubview:adImgView];
                [_defaultView addSubview:adBtn];
                [_defaultView addSubview:adCloseBtn];
                
                //启动轮播图片
                [self performSelectorOnMainThread:@selector(startAd) withObject:nil waitUntilDone:YES];
            }
        }
        
        //广告条位置下移
        adImgView.frame = CGRectMake((App_Frame_Width - 300) / 2 , App_Frame_Height - 43 - 36, 300, 36);
        adBtn.frame = adImgView.frame;
        adCloseBtn.frame = CGRectMake((App_Frame_Width - 300) / 2 + 280, App_Frame_Height - 43 - 36 - 20, 20, 20);
    }
}

- (void)startAd {
    adIndex = 0;
    adImgView.image = [adImgs objectAtIndex:0];
    adTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                               target:self
                                             selector:@selector(showNextAdPic)
                                             userInfo:nil
                                              repeats:YES];
    NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:adTimer forMode:NSDefaultRunLoopMode];
}

- (void)showNextAdPic {
    if ([adDatas count] > 0) {
        adIndex ++;
        adIndex %= [adDatas count];
        adImgView.image = [adImgs objectAtIndex:adIndex];
    }
}

- (void)adClick {
    //停止轮播
    [adTimer invalidate];
    
    //跳转到广告的景区
    NSString *idStr = [[adDatas objectAtIndex:adIndex] objectForKey:AD_Scenic_Id];
    NSString *sceName = [[adDatas objectAtIndex:adIndex] objectForKey:@"advertscenicName"];

    ScenicArea *data = [[ScenicArea alloc] init];
    data.scenicId = idStr;
    data.scenicName = sceName;
    DetailViewController  *mainController = [[DetailViewController alloc] init];
    mainController.data = data;
    [self.navigationController pushViewController:mainController animated:YES];
    [self backClick];
    [self adCloseClick];
//    NSDictionary *scenicsMap = [[FileTools defaultTools] GetJSONObjectFromFile:mainController.scenicFilePath];
//    NSArray *scenics = [scenicsMap objectForKey:@"scenics"];
//    for (NSDictionary *aScenic in scenics) {
//        if ([[aScenic objectForKey:ID] isEqualToString:idStr]) {
//            DetailViewController *detailViewController = [[DetailViewController alloc] init];
//            detailViewController.scenic = aScenic;
//            [detailViewController refreshData];
//            UIView *detailView = detailViewController.view;
//            detailView.alpha = 0;
//            [mainController.view addSubview:detailView];
//            [CommonTools viewFadeIn:detailView];
//            [self backClick];
//            break;
//        }
//    }
}

- (void)adCloseClick {
    //停止轮播
    [adTimer invalidate];
    
    //移除广告条
    [adImgView removeFromSuperview];
    [adBtn removeFromSuperview];
    [adCloseBtn removeFromSuperview];
}

- (void)favoriteClick {
    
}

- (void)showFavorite {
    NSString *idStr = self.data.scenicId;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:favoriteFilePath]) {
        favorites = [NSMutableArray arrayWithContentsOfFile:favoriteFilePath];
    }
    else {
        favorites = [[NSMutableArray alloc] init];
    }
    
    if ([favorites containsObject:idStr]) {
        [favoriteBtn setBackgroundImage:[UIImage imageNamed:@"favorite_red.png"] forState:UIControlStateNormal];
    }
    else {
        [favoriteBtn setBackgroundImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateNormal];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    //语音播放结束，喇叭图标变灰
    for (UIButton *hotBtn in hotBtns) {
        if (hotBtn.tag == 1 && [[hotBtn titleForState:UIControlStateReserved] isEqualToString:currentSpotId]) {
            [hotBtn setBackgroundImage:[UIImage imageNamed:@"horn.png"] forState:UIControlStateNormal];
            break;
        }
    }
}
@end
