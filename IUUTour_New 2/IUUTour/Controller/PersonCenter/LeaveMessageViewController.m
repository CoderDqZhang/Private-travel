#import "LeaveMessageViewController.h"
#import "LeaveMessageCell.h"
#import "MyComment.h"
#import "MJRefresh.h"

@interface LeaveMessageViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *messageListArr;
//    MJRefreshFooterView *_footer;//底部刷新请求更多数据
}
@property (nonatomic,retain) UITableView * tableView;
@end

@implementation LeaveMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.titleView.hidden = NO;
    self.titleLabel.text  = @"我的留言墙";
    [self initWithBackBtn];
    

    messageListArr      = [[NSMutableArray alloc] init];

    self.tableView      = [[UITableView alloc]initWithFrame:CGRectMake(0, self.titleView.bottom, App_Frame_Width, _defaultView.height - self.titleView.bottom) style:(UITableViewStyleGrouped)];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    [_defaultView addSubview:self.tableView];
    
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
//        [strongSelf performSelector:@selector(reloadDeals) withObject:nil afterDelay:0];
//    };

    
    [self reloadData];
}


#pragma mark 刷新
- (void)reloadDeals
{
    // 结束刷新状态
//    [_footer endRefreshing];
}

- (void)reloadData
{
    [SVProgressHUD  showWithOwner:@"LeaveMessageViewController_getComments"];
    [Interface getMyComments:[User sharedInstance].userid result:^(MyCommentsResponse *response, NSError *error) {
        [messageListArr removeAllObjects];
        [messageListArr addObjectsFromArray:response.commentsList];
        
        [self.tableView reloadData];
        [SVProgressHUD dismissFromOwner:@"LeaveMessageViewController_getComments"];
    }];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
}


#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return messageListArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyComment *comment = messageListArr[indexPath.section];
    CGSize size = [[LabelSize labelsizeManger]getStringRect:comment.content MaxSize:CGSizeMake(App_Frame_Width - 20,400) FontSize:13];
    return size.height + 10 + 30 + 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * pString = @"LeaveMessage";
    LeaveMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:pString];
    if (cell == nil) {
        cell = [[LeaveMessageCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:pString];
    }
    
    MyComment *comment = messageListArr[indexPath.section];

    cell.titlelbl.text = comment.scenicId;
    
    
    NSDateFormatter *decodeFormatter = [[NSDateFormatter alloc] init];
    [decodeFormatter setDateFormat: @"yyyyMMddHHmmss"];
    NSDate *decodedDate = [decodeFormatter dateFromString:comment.commentTime];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"MM月dd日 HH:mm"];
    
    cell.timelbl.text  = [formatter stringFromDate:decodedDate];
    
    CGSize size = [[LabelSize labelsizeManger]getStringRect:comment.content MaxSize:CGSizeMake(App_Frame_Width - 20,400) FontSize:13];
    
    cell.contlbl.text  = comment.content;
    cell.contlbl.frame = CGRectMake(10, cell.titlelbl.bottom, size.width, size.height);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
