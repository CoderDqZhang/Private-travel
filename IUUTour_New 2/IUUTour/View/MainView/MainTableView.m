//
//  MainTableView.m
//  IUUTour
//
//  Created by Zhang on 12/31/15.
//  Copyright © 2015 DevDiv Technology. All rights reserved.
//

#import "MainTableView.h"
#import "SceneryTableViewCell.h"
#import "MJRefresh.h"
#import "ScenicArea.h"
#import "CityModel.h"
#import "ScenicArea.h"


@interface MainTableView()
{
    NSTimer *scollerViewTimer;
    UIButton *regionBt;
    UIButton *dianceBt;
    UIButton *appraiseBt;
    
    
}

@property (nonatomic) float tableviewY;

@end

@implementation MainTableView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        _imagesData = [NSMutableArray arrayWithObjects:@"image1.jpg", @"image2.jpg", @"image3.jpg", @"image4.jpg", nil];
//        _sceneryData = [NSMutableArray arrayWithObjects:@"西南向心而行江玉龙雪山风景区",@"洱海苍山",@"渔山小镇",@"西藏芝林", nil];
        _imagesData = [NSMutableArray arrayWithCapacity:4];
        _sceneryData = [NSMutableArray arrayWithCapacity:4];
        
        _tourModelArray = [[NSMutableArray alloc] init];
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Screen_Height + 49)];
        _tableView.separatorStyle = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = [self taleHeaderView];
        scollerViewTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(scrollToNextPage:) userInfo:nil repeats:YES];
        [self addSubview:_tableView];
        [self createMJReshView];
        _currentOffSety = @"";
//        [[self rac_signalForSelector:@selector(scrollViewDidScroll:)] subscribeNext:^(UIScrollView *sender){
//            NSLog(@"成员变量 username 被修改成了：%f", sender.contentOffset.y);
//        }];
//        [RACObserve(self, currentOffSety) subscribeNext:^(id x) {
//            NSLog(@"成员变量 username 被修改成了：%@", x);
//        }];
        
    }
    return self;
}

-(void)reloadDeals
{
    [self.tableView.mj_footer endRefreshing];
    [self.tableView.mj_header endRefreshing];
}

-(void)createMJReshView
{
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        [self performSelector:@selector(reloadDeals) withObject:nil afterDelay:1];
    }];
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        [_delegate mjReloadData];
        [self performSelector:@selector(reloadDeals) withObject:nil afterDelay:1];
    }];
}

-(void)reloadData
{
    //这里写了点逻辑代码有点不好
    
    [_imagesData removeAllObjects];
    [_sceneryData removeAllObjects];
    if (self.tourModelArray.count > 4) {
        for (int i = 0; i < 4; i++) {
            [_imagesData addObject:[[self.tourModelArray objectAtIndex:i] smallImage]];
            [_sceneryData addObject:[[self.tourModelArray objectAtIndex:i] scenicName]];
        }

    }
    [self headerViewReload];
    [_tableView reloadData];
    
}

-(void)mainTableDelegate:(ScenicArea *)model
{
    [_delegate pushViewAndModel:model];
}

-(void)searchText:(NSString *)city
{
    [_delegate searchText:city];
}

-(void)headerViewReload
{
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.frame) * self.imagesData.count, CGRectGetHeight(_scrollView.frame));
    _pageControl.numberOfPages = self.imagesData.count;
    _pageControl.frame = CGRectMake(App_Frame_Width - (self.imagesData.count-1) * 20, CGRectGetMaxY(_scrollView.frame) - 40, self.imagesData.count * 20, 40);
    [self setupScrollViewImages];
}



-(CollectView *)setupCollectView:(CGRect)frame
{
    _collectView = [[CollectView alloc] initWithFrame:frame];
    _collectView.delegate = self;
    _collectView.tourModelArray = self.tourModelArray;
    _collectView.cityLatLon = self.cityLatLon;
    return _collectView;
}


-(UIView *)taleHeaderView
{
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 200)];
    tableHeaderView.backgroundColor = [UIColor redColor];
    [self createPageContol:tableHeaderView];
    [self addPageControl:tableHeaderView];
    return tableHeaderView;
}

-(UIView *)setupView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 50)];
    
    regionBt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width/3, 50)];
    [regionBt setTitle:@"区域 ▽ " forState:UIControlStateNormal];
    regionBt.tag = 100;
    regionBt.titleEdgeInsets = UIEdgeInsetsMake(3, 0, -3, 0);
    regionBt.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [regionBt setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [regionBt setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [regionBt addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:regionBt];
    
    UILabel *lineLable = [[UILabel alloc] initWithFrame:CGRectMake(App_Frame_Width/3, 22.5, 1, 15)];
    lineLable.backgroundColor = [UIColor grayColor];
    [headerView addSubview:lineLable];
    
    dianceBt = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width/3, 0, App_Frame_Width/3, 50)];
    [dianceBt setTitle:@"距离 ▽ " forState:UIControlStateNormal];
    dianceBt.tag = 200;
    dianceBt.titleEdgeInsets = UIEdgeInsetsMake(3, 0, -3, 0);
    dianceBt.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [dianceBt setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [dianceBt addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:dianceBt];
    
    UILabel *lineLable1 = [[UILabel alloc] initWithFrame:CGRectMake(App_Frame_Width - App_Frame_Width/3, 22.5, 1, 15)];
    lineLable1.backgroundColor = [UIColor grayColor];
    [headerView addSubview:lineLable1];
    
    
    appraiseBt = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width - App_Frame_Width/3, 0, App_Frame_Width/3, 50)];
    [appraiseBt setTitle:@"评价 ▽ " forState:UIControlStateNormal];
    appraiseBt.titleEdgeInsets = UIEdgeInsetsMake(3, 0, -3, 0);
    appraiseBt.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [appraiseBt setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    appraiseBt.tag = 300;
    [appraiseBt addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:appraiseBt];
    
    return headerView;
}

-(void)buttonPress:(UIButton *)sender
{
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setButtonTag:sender.tag];
    
}

-(void)setButtonTag:(NSInteger)tag
{
    if (tag == 100) {
        [dianceBt setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [appraiseBt setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_delegate selectCity];
    }else if(tag == 200){
        [regionBt setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [appraiseBt setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self sortWithDistance];
    }else{
        [dianceBt setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [regionBt setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self sortWithAppraise];
    }
    
}

-(void)setButtonTitleColor:(UIButton *)button
{
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
}

-(void)sortWithDistance
{
    for (int i = 9; i < _tourModelArray.count; i ++) {
        NSString *string = [_cityLatLon objectAtIndex:i];
        for (int j = i + 1; j< _tourModelArray.count; j ++) {
            NSString *temp = [_cityLatLon objectAtIndex:j];
            ScenicArea *tempArea = [_tourModelArray objectAtIndex:i];
            if ([string intValue] > [temp intValue]) {
                string = temp;
                [_tourModelArray replaceObjectAtIndex:i withObject:tempArea];
            }
        }
    }
    [self.tableView reloadData];
}

-(void)sortWithAppraise
{
    for (int i = 9; i < _tourModelArray.count; i ++) {
        ScenicArea *area = [_tourModelArray objectAtIndex:i];
        for (int j = i + 1; j< _tourModelArray.count; j ++) {
            ScenicArea *tempArea = [_tourModelArray objectAtIndex:j];
            if (area.favourNum < tempArea.favourNum) {
                area = tempArea;
                [_tourModelArray replaceObjectAtIndex:i withObject:tempArea];
            }
        }
    }
    [self.tableView reloadData];
}

/**
 *  创建上方滑动视图模型
 *
 *  @param pageView 传入UIview
 */
-(void)createPageContol:(UIView *)pageView
{
    CGRect frame = pageView.frame;
    [self initScollerView:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self setupScrollViewImages];
    [pageView addSubview:_scrollView];
}

/**
 *  创建滑动视图
 *
 *  @param frame 传入视图的大小
 */
-(void)initScollerView:(CGRect)frame
{
    _scrollView = [[UIScrollView alloc] initWithFrame:frame];
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.frame) * self.imagesData.count, CGRectGetHeight(_scrollView.frame));
    _scrollView.pagingEnabled = YES;
    _scrollView.bouncesZoom = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delaysContentTouches = YES;
    _scrollView.canCancelContentTouches = YES;
    _scrollView.delegate = self;
    
    
}

#pragma mark - Utils
- (void)setupScrollViewImages
{
    [self.imagesData enumerateObjectsUsingBlock:^(NSString *imageName, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_scrollView.frame) * idx, 0, CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame))];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:[UIImage imageNamed:@"placeholder_common"]options:SDWebImageProgressiveDownload | SDWebImageRetryFailed];
        [_scrollView addSubview:imageView];

        UILabel *sceneryName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(_scrollView.frame) * idx + 20, CGRectGetHeight(_scrollView.frame) - 48, CGRectGetWidth(_scrollView.frame), 20)];
        sceneryName.text = [_sceneryData objectAtIndex:idx];
        sceneryName.textColor = [UIColor whiteColor];
        sceneryName.font = [UIFont systemFontOfSize:20.0f];
        [_scrollView addSubview:sceneryName];
        
        imageView.userInteractionEnabled = YES;
        //单指单击
        UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(fingerIncident:)];
        //手指数
        singleFingerOne.numberOfTouchesRequired = 1;
        //点击次数
        singleFingerOne.numberOfTapsRequired = 1;
        //设置代理方法
        singleFingerOne.delegate= self;
        [imageView addGestureRecognizer:singleFingerOne];
        
        
    }];
    
}
/**
 *  创建上方可滑动的视图
 *
 *  @param headerview 传入tableView的headerView
 */
-(void)addPageControl:(UIView *)headerview
{
    [self createWrapper:CGRectMake(0, _scrollView.frame.size.height-20, App_Frame_Width, 20)];
    _pageControl = [[TAPageControl alloc] initWithFrame:CGRectMake(App_Frame_Width - self.imagesData.count * 20, CGRectGetMaxY(_scrollView.frame) - 40, self.imagesData.count * 20, 40)];
    _pageControl.delegate      = self;
    _pageControl.numberOfPages = self.imagesData.count;
    _pageControl.dotImage        = [UIImage imageNamed:@"dotInactive"];
    _pageControl.currentDotImage = [UIImage imageNamed:@"dotActive"];
    _pageControl.dotSize       = CGSizeMake(12, 12);
    [headerview addSubview:_pageControl];
}

-(void)createWrapper:(CGRect)frame
{
    _wrapper = [[UIView alloc] initWithFrame:frame];
    [_scrollView addSubview:_wrapper];
}

-(void)fingerIncident:(UIGestureRecognizer *)gestureRecognizer
{
    [_delegate pushViewAndModel:[self.tourModelArray objectAtIndex:_pageControl.currentPage]];
    
}

#pragma mark - ScrollView delegate

-(void)scrollToNextPage:(id)sender
{
    NSInteger pageNum = _pageControl.currentPage;
    CGSize viewSize=_scrollView.frame.size;
    if (pageNum == self.imagesData.count-1) {
        CGRect newRect=CGRectMake(0, 0, viewSize.width, viewSize.height);
        [_scrollView scrollRectToVisible:newRect animated:NO];
    }else{
        CGRect rect=CGRectMake((pageNum+1)*viewSize.width, 0, viewSize.width, viewSize.height);
        [_scrollView scrollRectToVisible:rect animated:NO];
        pageNum++;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger pageIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
    _pageControl.currentPage = pageIndex;
    _tableviewY = scrollView.contentOffset.y;
    _currentOffSety = [NSString stringWithFormat:@"%f",scrollView.contentOffset.y];
//    NSLog(@"%f",scrollView.contentOffset.y);
    
}

- (void)TAPageControl:(TAPageControl *)pageControl didSelectPageAtIndex:(NSInteger)index
{
    NSLog(@"Bullet index %ld", (long)index);
    [_scrollView scrollRectToVisible:CGRectMake(CGRectGetWidth(self.scrollView.frame) * index, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame)) animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tourModelArray.count - 6;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 450;
    }else if (indexPath.row == 1){
        return 50;
    }else{
        return 197;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *reuseIdetify = @"CollectView";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdetify];
        }
        cell.userInteractionEnabled = YES;
        CGRect frame = CGRectMake(0, 0, App_Frame_Width, 450);
        [cell.contentView addSubview:[self setupCollectView:frame]];
        UIView *view_bg = [[UIView alloc]initWithFrame:cell.frame];
        view_bg.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = view_bg;
        
        return cell;
    }else if(indexPath.row == 1){
        static NSString *reuseIdetify = @"MainTableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdetify];
        }
        cell.userInteractionEnabled = YES;
        
        UIView *view_bg = [[UIView alloc]initWithFrame:cell.frame];
        view_bg.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = view_bg;
        cell.backgroundColor = [UIColor colorWithRed:30/255.0 green:31/255.0 blue:31/255.0 alpha:1.0];
        [cell.contentView addSubview:[self setupView]];
        return cell;
    }else {
        static NSString *reuseIdetify = @"SceneryTableViewCell";
        SceneryTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
        if (!cell) {
            cell = [[SceneryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdetify];
        }
        cell.userInteractionEnabled = YES;
        [cell setData:[_tourModelArray objectAtIndex:indexPath.row + 6]];
        UIView *view_bg = [[UIView alloc]initWithFrame:cell.frame];
        view_bg.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = view_bg;
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= 2) {
        [_delegate pushViewAndModel:[self.tourModelArray objectAtIndex:indexPath.row + 6]];
    }
}




@end
