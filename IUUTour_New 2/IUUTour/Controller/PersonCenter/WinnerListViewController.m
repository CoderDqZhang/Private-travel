#import "WinnerListViewController.h"
#import "MJRefresh.h"
#import "WinnerListCell.h"
#import "PrizeWinner.h"

@interface WinnerListViewController ()<UITextViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
//    MJRefreshFooterView *_footer;
}

@property (nonatomic, strong) UITableView    * tableView;
@property (nonatomic, strong) NSMutableArray *winnerList;

@end

@implementation WinnerListViewController


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text  = @"获奖记录";
    self.titleView.hidden = NO;
    [self initWithBackBtn];
    
    
    //  TableView to show list
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.titleView.bottom, App_Frame_Width, _defaultView.height - self.titleView.bottom) style:(UITableViewStyleGrouped)];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.sectionHeaderHeight = 0.0;
    self.tableView.sectionFooterHeight = 0.0;
    [_defaultView addSubview:self.tableView];
    
    
    //  Table view data source
    self.winnerList = [[NSMutableArray alloc]init];
    
    //  Footer to refresh
//    __weak __typeof(self)weakSelf = self;
//    // 4.3行集成上拉加载更多控件
//    _footer = [MJRefreshFooterView footer];
//    _footer.scrollView = _tableView;
//    // 进入上拉加载状态就会调用这个方法
//    _footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
//        __strong __typeof(weakSelf)strongSelf = weakSelf;
//        
//        if (!strongSelf)
//        {
//            return;
//        }
//        
//        [strongSelf reloadData];
//        
//        [strongSelf performSelector:@selector(reloadDeals) withObject:nil afterDelay:0];
//    };
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)reloadData
{
    [SVProgressHUD  showWithOwner:@"WinnerListViewController"];
    
    __weak __typeof(self)weakSelf = self;
    
    [Interface queryWinnerList:^(LotteryWinnerListResponse *response, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }
        
        [self.winnerList removeAllObjects];
        [self.winnerList addObjectsFromArray:response.winnerList];
        
        [SVProgressHUD dismissFromOwner:@"WinnerListViewController"];
    
        
        if (response && response.status == 1)
        {
             [strongSelf.tableView reloadData];
        }
        else if (response && response.status != 1)
        {
            [UWindowHud hudWithType:kToastType withContentString:@"获取信息失败！"];
        }
    }];
}


#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.winnerList.count;
}



-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 0.01;
    }
    return 0.01;
}

-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
}

-(UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * pString = @"WinnerListCell";
    WinnerListCell * cell     = [tableView dequeueReusableCellWithIdentifier:pString];
    if (cell == nil)
    {
        cell = [[WinnerListCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:pString];
    }
    
    PrizeWinner *winnerInfo       = [self.winnerList objectAtIndex:indexPath.row];

    const float cellContentHeight = 70;
    const float yIndent           = 10;

    [cell.profileImg setFrame:CGRectMake(10, yIndent, cellContentHeight, cellContentHeight)];
    [cell.spinner setFrame:CGRectMake(10, yIndent, cellContentHeight, cellContentHeight)];
    [cell.spinner setImage:[UIImage imageNamed:@"spinner"]];
    [cell.spinner setContentMode:UIViewContentModeCenter];
    
    
    NSString *profileUrlString = nil;

    if ([winnerInfo.userPortrait rangeOfString:@"http:" options:NSCaseInsensitiveSearch].location == NSNotFound)
    {
        if ([winnerInfo.userPortrait hasPrefix:@"/images/"])
        {
            NSString *correctRelativeUrl = [winnerInfo.userPortrait stringByReplacingOccurrencesOfString:@"/images/" withString:@""];
            profileUrlString = [NSString stringWithFormat:@"%@%@", K_Image_URL, correctRelativeUrl];
        }
        else if ([winnerInfo.userPortrait hasPrefix:@"images/"])
        {
            NSString *correctRelativeUrl = [winnerInfo.userPortrait stringByReplacingOccurrencesOfString:@"images/" withString:@""];
            profileUrlString = [NSString stringWithFormat:@"%@%@", K_Image_URL, correctRelativeUrl];
        }
        else
        {
            profileUrlString = [NSString stringWithFormat:@"%@%@", K_Image_URL, winnerInfo.userPortrait];
        }
    }
    else
    {
        profileUrlString = winnerInfo.userPortrait;
    }
    

    cell.spinner.hidden = YES;
    
    
    [cell.profileImg setShowActivityIndicatorView:YES];
    [cell.profileImg setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [cell.profileImg sd_setImageWithURL:[NSURL URLWithString:profileUrlString] placeholderImage:[UIImage imageNamed:@"placeholder_common"]options:SDWebImageProgressiveDownload | SDWebImageRetryFailed];

    [cell.profileImg.layer setMasksToBounds:YES];
    [cell.profileImg.layer setBorderColor:[UIColor colorWithRed:226/255. green:226/255. blue:226/255. alpha:1].CGColor];//边框颜色
    [cell.profileImg.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
    [cell.profileImg.layer setBorderWidth:1.0];  //边框宽度
    

    [cell.userInfo setFrame:CGRectMake(cell.profileImg.width + 40, yIndent, cell.width * 2 / 3 - cell.profileImg.width, cellContentHeight)];
    [cell.userInfo.userName setFrame:CGRectMake(0, yIndent, cell.userInfo.width, cell.userInfo.height / 2)];
    [cell.userInfo.userName setText:winnerInfo.userName];
    [cell.userInfo.userLocation setFrame:CGRectMake(0, cell.userInfo.height / 2, cell.userInfo.width, cell.userInfo.height / 2)];
    [cell.userInfo.userLocation setText:winnerInfo.userLocation];
    

    [cell.prizeName setFrame:CGRectMake(App_Frame_Width * 2 / 3, yIndent, App_Frame_Width * 2 / 3, cellContentHeight)];
    [cell.prizeName setText:winnerInfo.prizeName];
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark 刷新
- (void)reloadDeals
{
    // 结束刷新状态
//    [_footer endRefreshing];
}


@end
