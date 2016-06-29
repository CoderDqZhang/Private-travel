#import "SetViewController.h"
#import "UMessage.h"

#import "MFSideMenu.h"

@interface SetViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    UILabel     *_folder;
}
@property (nonatomic,retain) NSArray * titleArray;

@end

@implementation SetViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"设置";
    
    self.titleLabel.text  = @"设置";
    self.titleView.hidden = NO;
    [self initWithBackBtn];
    
    self.titleArray = [[NSArray alloc]initWithObjects:@"接收消息通知",@"声音",@"清除缓存", nil];
    
    _tableView                 = [[UITableView alloc]initWithFrame:CGRectMake(0, self.titleView.bottom, App_Frame_Width, _defaultView.height - self.titleView.bottom) style:(UITableViewStyleGrouped)];
    _tableView.delegate        = self;
    _tableView.dataSource      = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [_defaultView addSubview:_tableView];
    
    [self setupMenuBarButtonItem];
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * pString = @"SetView";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:pString];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:pString];;
    }
    
    cell.textLabel.text = self.titleArray[indexPath.row];
    if (![self.titleArray[indexPath.row] isEqualToString:@"清除缓存"])
    {
        UISwitch * pSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(App_Frame_Width - 60, 5, 30, 40)];
        pSwitch.tag = indexPath.row;
        pSwitch.on  = YES;
        [pSwitch addTarget:self action:@selector(SwitchContactClick:) forControlEvents:(UIControlEventTouchUpInside)];
        [cell addSubview:pSwitch];
    }
    else
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(App_Frame_Width - 115, 0, 100, 40)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor       = [UIColor darkGrayColor];
        label.font            = [UIFont systemFontOfSize:16];
        label.tag             = indexPath.row;
        label.textAlignment   = NSTextAlignmentRight;
        [cell addSubview:label];
    }
    
    if (indexPath.row == 2)
    {
        _folder      = (UILabel *)[cell viewWithTag:indexPath.row];
        _folder.text = [self updateCacheLabel];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 2)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定删除缓存？" message:@"缓存包括您浏览的景区图片、贴士、交通等信息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [SVProgressHUD showErrorWithStatus:@"清除缓存成功"];
        [self deleteImageFolder];
        _folder.text = [self updateCacheLabel];
        [_tableView reloadData];
    }
}

- (void)SwitchContactClick:(UISwitch *)sth
{
    NSInteger index = sth.tag;
    switch (index)
    {
        case 0:
        {
            if (sth.selected)
            {
                [Interface sendPushToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"] recv_msg:@"0" result:^(CommonActionStatus *response, NSError *error) {
                    NSLog(@"sendPushTokensendPushTokensendPushToken%@",response.message);
                }];
            }
            else
            {
                [Interface sendPushToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"] recv_msg:@"1" result:^(CommonActionStatus *response, NSError *error) {
                    NSLog(@"sendPushTokensendPushTokensendPushToken%@",response.message);
                }];
            }
        }
            break;
        case 1:
        {
            
        }
            
        default:
            break;
    }
    
}


//删除沙盒目录文件；
- (void) deleteImageFolder
{
    __weak __typeof(self)weakSelf = self;
    dispatch_async(
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                   , ^{
                       __strong __typeof(weakSelf)strongSelf = weakSelf;
                       
                       if (!strongSelf)
                       {
                           return;
                       }

                       NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0];
                       NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
                       for (NSString *p in files) {
                           NSError *error;
                           NSString *path = [cachPath stringByAppendingPathComponent:p];
                           if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                               [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                           }
                       }
                       [strongSelf performSelectorOnMainThread:@selector(clearCacheSuccess) withObject:nil waitUntilDone:YES];
                   });
}

- (void)clearCacheSuccess
{
    [_tableView reloadData];
}

- (NSString *)updateCacheLabel
{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    float size = [self folderSizeAtPath:cachePath];
    if(size < 1)
    {
        size = 0;
    }
    
    NSString *folderSize = [NSString stringWithFormat:@"%.2fM", size];
    
    return folderSize;
}

- (float)folderSizeAtPath:(NSString *)folderPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil)
    {
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

- (long long)fileSizeAtPath:(NSString *)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath])
    {
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
