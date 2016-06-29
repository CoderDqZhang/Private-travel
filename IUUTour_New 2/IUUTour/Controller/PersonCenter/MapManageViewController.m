#import "MapManageViewController.h"
#import "DownResource.h"
#import "MapManageCell.h"
#import "AddMapScenicViewController.h"
#import "AFDownloadRequestOperation.h"


@interface MapManageViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,retain) NSMutableArray      *timeArray;

@property (nonatomic,retain) NSMutableArray      *isUpDateArray;

@property (nonatomic,retain) NSMutableArray      *isDownArray;
@property (nonatomic,retain) NSMutableDictionary *dicData;
@property (nonatomic,retain) UITableView         *pTableView;
@end

@implementation MapManageViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSArray * paths     = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString * path     = [paths  objectAtIndex:0];
    NSString * filePath = [path stringByAppendingPathComponent:@"leaveMapData.plist"];
    
    self.isDownArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    
    if (self.isDownArray.count <= 0)
    {
        [UWindowHud hudWithType:kToastType withContentString:@"尚未下载任何离线地图！"];
    }
    
    [self.pTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.titleLabel.text  = @"地图管理";
    self.titleView.hidden = NO;
    [self initWithBackBtn];
    
    self.isUpDateArray = [[NSMutableArray alloc] init];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(self.titleView.width - 80, 11.5f, 70.0f, 21.0f)];
    [rightBtn setTitleColor:ButtonColorB forState:UIControlStateNormal];
    [rightBtn setTitle:@"添加地图" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [rightBtn addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:rightBtn];

    self.pTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.titleView.bottom, App_Frame_Width, _defaultView.height - self.titleView.bottom) style:(UITableViewStylePlain)];
    self.pTableView.delegate = self;
    self.pTableView.dataSource = self;
    self.pTableView.tableFooterView = [[UIView alloc]init];
    [_defaultView addSubview:self.pTableView];
    
    [self timerFired];

}

- (void)timerFired
{
    NSArray * paths     = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString * path     = [paths  objectAtIndex:0];
    NSString * filePath = [path stringByAppendingPathComponent:@"leaveMapData.plist"];
    
    self.isDownArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    NSMutableString * string = [[NSMutableString alloc] init];
    for (int i= 0; i < self.isDownArray.count; i++)
    {
        [string appendString:[NSString stringWithFormat:@"%@,",[[self.isDownArray objectAtIndex:i] objectForKey:@"scenicID"]]];
    }
    
    __weak __typeof(self)weakSelf = self;
    [Interface getMapLastUpdateTime:string result:^(UpDateMapResponse *response, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }
        
        strongSelf.isUpDateArray = response.date;

        [strongSelf.pTableView reloadData];
    }];
}

#pragma mark - table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.isDownArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * pstring = @"MapManage";
    MapManageCell * cell = [tableView dequeueReusableCellWithIdentifier:pstring];
    if (cell == nil) {
        cell = [[MapManageCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:pstring];
    }
    
    NSDictionary *dict  = self.isDownArray[indexPath.row];
    NSArray * paths     = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString * path     = [paths  objectAtIndex:0];
    NSString * filePath = [path stringByAppendingPathComponent:[dict objectForKey:@"imageName"]];

    
    NSFileManager * fileManage = [NSFileManager defaultManager];
    NSData * pData = [fileManage contentsAtPath:filePath];
    

    //图片
    [cell.image setImage:[UIImage imageWithData:pData]];
    
    //标题
    [cell.title setText:[dict objectForKey:@"scenicname"]];
    cell.title.textColor = [UIColor colorWithRed:0x40/255.0f green:0x40/255.0f blue:0x40/255.0f alpha:1];
    
    //文件大小
    [cell.sizelbl setText:[NSString stringWithFormat:@"文件大小:%@",[dict objectForKey:@"size"]]];
    cell.sizelbl.textColor = [UIColor colorWithRed:0x40/255.0f green:0x40/255.0f blue:0x40/255.0f alpha:1];
    
    for (int i = 0; i < self.isUpDateArray.count; i++) {
        UpDateData * datetemp = [self.isUpDateArray objectAtIndex:i];
        if ([datetemp.scenicId intValue] == [[dict objectForKey:@"scenicID"] intValue]) {
            if ([datetemp.mapVersion intValue] == [[dict objectForKey:@"mapVerison"] intValue]) {
                [cell.update setHidden:YES];
            }
            else
            {
                [cell.update setHidden:NO];
                [cell.update setTag:indexPath.row*10000+[datetemp.mapVersion intValue]];
            }
        }

    }

    [cell.update addTarget:self action:@selector(updateAction:) forControlEvents:(UIControlEventTouchUpInside)];

    

    CGSize timeSize = [[LabelSize labelsizeManger]getStringRect:[dict objectForKey:@"datetime"] MaxSize:CGSizeMake(200, 20) FontSize:12];

    [cell.timelbl setFrame:CGRectMake(cell.image.right + 5, cell.sizelbl.bottom, timeSize.width + 60, 20)];
    [cell.timelbl setText:[NSString stringWithFormat:@"下载时间:%@",[dict objectForKey:@"datetime"]]];
    cell.timelbl.textColor = [UIColor colorWithRed:0x40/255.0f green:0x40/255.0f blue:0x40/255.0f alpha:1];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
        return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        NSDictionary * dic = [self.isDownArray objectAtIndex:indexPath.row];
        [self deleteFile:[dic objectForKey:@"scenicID"]];
        [self deleteFile:[NSString stringWithFormat:@"scenic%@",[dic objectForKey:@"scenicID"]]];
        [self.isDownArray removeObjectAtIndex:indexPath.row];
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString * path = [paths  objectAtIndex:0];
        NSString * filePath = [path stringByAppendingPathComponent:@"leaveMapData.plist"];
        [self.isDownArray writeToFile:filePath atomically:YES];
        
        // 删除 索引的方法 后面是动画样式
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:(UITableViewRowAnimationLeft)];
    }
}

-(void)deleteFile:(NSString *)str
{
    NSFileManager* fileManager=[NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    
    //文件名
    NSString *uniquePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:str];
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:uniquePath];
    if (!blHave) {
        NSLog(@"no  have");
        return ;
    }else {
        NSLog(@" have");
        BOOL blDele= [fileManager removeItemAtPath:uniquePath error:nil];
        if (blDele) {
            NSLog(@"dele success");
        }else {
            NSLog(@"dele fail");
        }
        
    }
}

#pragma mark - button action

- (void)updateAction:(UIButton *)sender
{
    NSInteger send      = sender.tag/10000;
    clickMapVerison     = sender.tag- ((sender.tag/10000) *10000);
    button              = sender;
    sender.enabled      = NO;
    NSDictionary * json = [self.isDownArray objectAtIndex:send];
    

    scenicID = [json objectForKey:@"scenicID"];
    @autoreleasepool {
        
        NSString *scenicId = [json objectForKey:@"scenicID"];
        NSString *canNavi  = [json objectForKey:@"canNavi"];
        NSString *urlStr;
        NSString *scenic;
        if ([canNavi intValue] == 1) {
            urlStr = [NSString stringWithFormat:@"http://map.imyuu.com:9100/map/%@.zip", scenicId];
            scenic = @"";
        }
        else
        {
            urlStr = [NSString stringWithFormat:@"http://www.imyuu.com/trip/oneScenicScenicAreaAction.action?scenicId=%@", scenicId];
            scenic = @"scenic";
        }
        
        FileTools *fileTools = [FileTools defaultTools];
        zipFilePath = [fileTools GetFullFilePathInDocuments:[NSString stringWithFormat:@"%@%@.zip",scenic, scenicId]];
        
        [fileTools deleteDir:zipFilePath];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
        
        NSString *fileIdentifier = [urlStr stringByReplacingOccurrencesOfString:@":" withString:@"_"];
        NSString *fileIdentifierEx = [fileIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        //NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileIdentifierEx];
        
        AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request fileIdentifier:fileIdentifierEx targetPath:zipFilePath shouldResume:YES];
        
        __weak __typeof(self)weakSelf = self;
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            [strongSelf performSelectorOnMainThread:@selector(showUncompressAndProcessDownload) withObject:nil waitUntilDone:NO];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (!strongSelf)
            {
                return;
            }

            
            [strongSelf->button setTitle:@"下载" forState:(UIControlStateNormal)];
            strongSelf->button.enabled =  YES;
            
            [UWindowHud hudWithType:kToastType withContentString:@"网络不佳，请稍候重试！"];
            
        }];
        
        [operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            [strongSelf performSelectorOnMainThread:@selector(updateDownProgress:) withObject:[NSNumber numberWithLongLong:totalBytesReadForFile * 100 / totalBytesExpectedToReadForFile] waitUntilDone:NO];
        }];
        
        [[NSOperationQueue mainQueue] addOperation:operation];
    }
}

- (void)updateDownProgress:(NSNumber*)totalBytesRead
{
    [button setTitle:[NSString stringWithFormat:@"%d%%",(int)([totalBytesRead longLongValue])] forState:(UIControlStateNormal)];
}

- (void)showUncompressAndProcessDownload
{
    [button setTitle:@"解压中..." forState:(UIControlStateNormal)];
    
    [self performSelectorInBackground:@selector(processDownload) withObject:nil];
}


- (void)processDownload
{
    FileTools *fileTools = [FileTools defaultTools];
    
    
    NSString *urlAddress = @"";
    NSString *scenic     = @"";
    
    
    //1.解压前先删除原目录
    NSString *scenicId = scenicID;
    if ([canNai intValue] == 1) {
        scenic          = @"";
        urlAddress      = [NSString stringWithFormat:@"/%@%@",scenic,scenicId];
    }
    else
    {
        scenic          = @"scenic";
        urlAddress      = @"";
    }
    NSString *path  = [fileTools GetFullFilePathInDocuments:[NSString stringWithFormat:@"%@%@", scenic,scenicId]];
    [fileTools deleteDir:path];
    
    //2. 解压
    ZipArchive *zip = [[ZipArchive alloc] init];
    [zip UnzipOpenFile:zipFilePath];
    [zip UnzipFileTo:[NSString stringWithFormat:@"%@%@",[fileTools GetDocumentsPath],urlAddress] overWrite:YES];
    [zip UnzipCloseFile];
    
    //3. 删除zip文件
    [fileTools deleteDir:zipFilePath];
    
    
    [self performSelectorOnMainThread:@selector(refreshAfterDownload) withObject:nil waitUntilDone:YES];
}


- (void)refreshAfterDownload
{
    [button setTitle:@"已更新" forState:(UIControlStateNormal)];

    [self initWithMapData];
}

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString
{
    NSURL* URL     = [NSURL fileURLWithPath: filePathString];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);

    NSError *error = nil;
    BOOL success   = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}



-(void)initWithMapData
{
    
    NSArray * paths     = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString * path     = [paths  objectAtIndex:0];
    NSString * filePath = [path stringByAppendingPathComponent:@"leaveMapData.plist"];
    
    //下载图片
    
    NSMutableArray *jsonObject = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    for (int i = 0; i < jsonObject.count; i++) {
        if ([[[jsonObject objectAtIndex:i] objectForKey:@"scenicID"] intValue] == [scenicID intValue]) {
            [[jsonObject objectAtIndex:i] setObject:[NSNumber numberWithInteger:clickMapVerison] forKey:@"mapVerison"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd"];
            NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
            [[jsonObject objectAtIndex:i] setObject:strDate forKey:@"datetime"];
        }
    }
    
    [jsonObject writeToFile:filePath atomically:YES];
    
    [self.pTableView reloadData];
}


- (void)rightAction
{
    AddMapScenicViewController * vc = [[AddMapScenicViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)stopAction:(UIButton *)sender
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
