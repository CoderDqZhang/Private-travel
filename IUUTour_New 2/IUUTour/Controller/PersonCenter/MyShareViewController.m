#import "MyShareViewController.h"
#import "ShareTableViewCell.h"

@interface MyShareViewController ()

@end

@implementation MyShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleView.hidden = NO;
    self.titleLabel.text  = @"我的分享";
    [self initWithBackBtn];
    
    NSArray * paths     = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString * path     = [paths  objectAtIndex:0];
    NSString * filePath = [path stringByAppendingPathComponent:@"shareContent.plist"];
    
    _shareListArr  = [[NSMutableArray alloc] initWithContentsOfFile:filePath];

    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.titleView.bottom, App_Frame_Width, _defaultView.height - self.titleView.bottom) style:(UITableViewStyleGrouped)];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    [_defaultView addSubview:self.tableView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _shareListArr.count;
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
    NSDictionary *dict = _shareListArr[indexPath.section];
    NSString *contentStr = [NSString stringWithFormat:@"我在%@分享了到%@游玩的经历！",dict[@"shareType"],dict[@"scenicName"]];
    CGSize size = [[LabelSize labelsizeManger]getStringRect:contentStr MaxSize:CGSizeMake(App_Frame_Width - 20,400) FontSize:14];
    return size.height + 10 + 30 +10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * pString = @"LeaveMessage";
    ShareTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:pString];
    if (cell == nil)
    {
        cell = [[ShareTableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:pString];
    }
    NSDictionary *dict   = _shareListArr[indexPath.section];

    cell.timelbl.text    = dict[@"datetime"];

    NSString *contentStr = [NSString stringWithFormat:@"我在%@分享了到%@游玩的经历！",dict[@"shareType"],dict[@"scenicName"]];
    
    CGSize size = [[LabelSize labelsizeManger]getStringRect:contentStr MaxSize:CGSizeMake(App_Frame_Width - 30,400) FontSize:14];
    
    cell.contlbl.text  = contentStr;
    cell.contlbl.frame = CGRectMake(15, cell.timelbl.bottom, size.width, size.height);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
