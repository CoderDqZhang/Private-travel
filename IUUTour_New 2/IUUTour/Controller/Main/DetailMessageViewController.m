#import "DetailMessageViewController.h"
#import "PeopleInfoViewController.h"
#import "LeaveMessageCell.h"
#import "LoginViewController.h"
#import "MJRefresh.h"



#define textViewBgHeight 45
#define textViewHeight 30
@interface DetailMessageViewController ()<UITextViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    int page ;
//    MJRefreshFooterView *_footer;//底部刷新请求更多数据
}
@property (nonatomic,retain) UITableView * tableView;
@property (nonatomic,retain) NSMutableArray *sections;

@end

@implementation DetailMessageViewController

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    page                      = 0;
    self.titleLabel.text      = @"留言墙";
    self.titleView.hidden     = NO;
    
    [self initWithBackBtn];
    
    self.sections  = [[NSMutableArray alloc] init];

    isShouldRefesh = NO;

    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.titleView.bottom, App_Frame_Width, _defaultView.height - self.titleView.bottom - textViewBgHeight) style:(UITableViewStyleGrouped)];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    
    [_defaultView addSubview:self.tableView];
    
    
//     __weak DetailMessageViewController *weakSelf = self;
//    // 4.3行集成上拉加载更多控件
//    _footer = [MJRefreshFooterView footer];
//    _footer.scrollView = _tableView;
//    // 进入上拉加载状态就会调用这个方法
//    _footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
//        __strong DetailMessageViewController *strongSelf = weakSelf;
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
    [self initWithText];
}

-(void)reloadData
{
    [SVProgressHUD  showWithOwner:@"DetailMessageViewController_getComments"];
    
    __weak __typeof(self)weakSelf = self;
    
    [Interface scenicComments:self.data.scenicId page:0 result:^(ScenicCmtResponse *response, NSError *error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }

        
        [SVProgressHUD dismissFromOwner:@"DetailMessageViewController_getComments"];
        
        
        if (response && response.status == 1)
        {
            NSLog(@"liuyanlist %@",response.cmtList);
            [strongSelf.sections removeAllObjects];
            [strongSelf.sections addObjectsFromArray: response.cmtList];
            NSLog(@"liuyanlist %@",strongSelf.sections);
            if (strongSelf.sections.count==10*(strongSelf->page+1)) {
                
                strongSelf->page++;
            }
            [strongSelf.tableView reloadData];
        }
        else if (response && response.status == 0)
        {
            [UWindowHud hudWithType:kToastType withContentString:@"获取留言列表失败，请检查网络！"];
        }
    }];
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
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
    ScenicCmts *tempdata = [self.sections objectAtIndex:indexPath.section];

    CGSize size = [[LabelSize labelsizeManger]getStringRect:tempdata.content MaxSize:CGSizeMake(App_Frame_Width - 20,400) FontSize:13];
    return size.height + 10 + 30 +10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * pString = @"LeaveMessage";
    LeaveMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:pString];
    if (cell == nil)
    {
        cell = [[LeaveMessageCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:pString];
    }
    ScenicCmts * tempdata = [self.sections objectAtIndex:indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titlelbl.attributedText = [self content:[NSString stringWithFormat:@"%@，%@，%@",tempdata.userName,tempdata.age,tempdata.gender] searchTxt:tempdata.userName];
    cell.titlelbl.tag            = indexPath.section;
    UITapGestureRecognizer * Tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(titleAction:)];
    [cell.titlelbl addGestureRecognizer:Tap];
    
    cell.timelbl.text = tempdata.commentTime;
    
    
    CGSize size = [[LabelSize labelsizeManger]getStringRect:tempdata.content MaxSize:CGSizeMake(App_Frame_Width - 20,400) FontSize:13];
    
    cell.contlbl.text  = tempdata.content;
    cell.contlbl.frame = CGRectMake(10, cell.titlelbl.bottom, size.width, size.height);
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


#pragma mark - textView

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if ([text isEqualToString:@"\n"]) {
        
        [self submitCommentAction];
        
        [textView resignFirstResponder];
        
        return NO;
    }
    return YES;
}

- (void)initWithText
{
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, _defaultView.height - textViewBgHeight, App_Frame_Width, textViewBgHeight)];
    bgView.backgroundColor     = [UIColor colorWithRed:249/255.0f green:250/255.0f blue:251/255.0f alpha:1];
    bgView.layer.shadowColor   = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:1].CGColor;
    bgView.layer.shadowRadius  = 0;
    bgView.layer.shadowOpacity = 1;
    bgView.layer.shadowOffset  = CGSizeMake(0, -1);
    [_defaultView addSubview:bgView];
    
    UIView *lineView         = [[UIView alloc] initWithFrame:CGRectMake(0, bgView.frame.size.height-1, bgView.frame.size.width, 1)];
    lineView.tag             = 112;
    lineView.backgroundColor = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:1];
    [bgView addSubview:lineView];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, (textViewBgHeight-textViewHeight)/2, App_Frame_Width - 70, textViewHeight)];
    _textView.layer.cornerRadius = 5;
    _textView.layer.borderWidth  = 1;
    _textView.returnKeyType      = UIReturnKeySend;
    _textView.scrollEnabled      = NO;
    _textView.layer.borderColor  = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1].CGColor;
    
    _textView.delegate           = self;

    @weakify(self);
    [[self rac_signalForSelector:@selector(textViewDidChange:)] subscribeNext:^(RACTuple *sender) {
        UITextView *textView = sender.first;
        @strongify(self);
       
        [UIView animateWithDuration:0.3 animations:^{
            [textView sizeToFit];
            
            
            self->bgView.frame = CGRectMake(0, self->y-(textView.frame.size.height-textViewHeight), App_Frame_Width, textView.frame.size.height+15);
            textView.frame = CGRectMake(10, (textViewBgHeight-textViewHeight)/2, App_Frame_Width - 70, self->bgView.frame.size.height-15);
            
            UIView *line = [self->bgView viewWithTag:112];
            line.frame = CGRectMake(0, self->bgView.frame.size.height-1, self->bgView.frame.size.width, 1);
        }];
    }];
    
    
    [bgView addSubview:_textView];
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame     = CGRectMake(_textView.right + 10, _textView.top, 40, textViewHeight);
    [button setTitle:@"留言" forState:(UIControlStateNormal)];
    button.backgroundColor    = ButtonColorA;
    button.layer.cornerRadius = 5;
    button.hidden             = NO;
    button.layer.borderWidth  = 1;
    button.titleLabel.font    = [UIFont systemFontOfSize:12];
    button.layer.borderColor  = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1].CGColor;
    [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(submitCommentAction) forControlEvents:(UIControlEventTouchUpInside)];
    [bgView addSubview:button];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)initWithMessage
{
    NSArray * paths     = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString * path     = [paths  objectAtIndex:0];
    NSString * filePath = [path stringByAppendingPathComponent:@"leavemessage.plist"];
    
    NSMutableArray *jsonObject = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    if (jsonObject==nil)
    {
        jsonObject = [[NSMutableArray alloc] init];
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:_textView.text forKey:@"content"];
    [dict setObject:self.data.scenicName forKey:@"scenicname"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    [dict setObject:strDate forKey:@"datetime"];
    [jsonObject addObject:dict];
    
    [jsonObject writeToFile:filePath atomically:YES];
    
}

- (void)submitCommentAction
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
        [_textView becomeFirstResponder];

        [SVProgressHUD showWithOwner:@"DetailMessageViewController_sendComments"];
        
        if(_textView.text.length == 0)
        {
           [UWindowHud hudWithType:kToastType withContentString:@"请输入评论内容！"];
            [SVProgressHUD dismissFromOwner:@"DetailMessageViewController_sendComments"];
            return;
        }
        
        NSString *age = @"0";
        if ([[User sharedInstance].birthday length] > 0)
        {
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
            
            NSInteger currentYear = [components year];
            
            NSArray *birthArray = [[User sharedInstance].birthday componentsSeparatedByString:@"-"];
            if (birthArray.count > 0)
            {
                age = [NSString stringWithFormat:@"%d", (int)currentYear - [birthArray[0] intValue]];
            }
        }
        
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];

        __weak __typeof(self)weakSelf = self;
        [Interface sendScenicComment:[User sharedInstance].userid UserName:[User sharedInstance].loginName Age:age ScenicID:self.data.scenicId Content:_textView.text Gender: [[User sharedInstance].sex isEqualToString:@"0"] ? @"女":@"男" result:^(SendScenicResponse *response, NSError *error) {
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (!strongSelf)
            {
                return;
            }
            
            
            [SVProgressHUD dismissFromOwner:@"DetailMessageViewController_sendComments"];
            
            if (response)
            {
                [strongSelf initWithMessage];
                strongSelf->_textView.text = @"";
                strongSelf->isShouldRefesh = YES;
                
                [strongSelf reloadData];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshLeaveMessage" object:nil];
                
                [UWindowHud hudWithType:kToastType withContentString:@"感谢留言！"];
            }
            else
            {
                [UWindowHud hudWithType:kToastType withContentString:@"提交失败，请重试！"];
            }
        }];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_textView resignFirstResponder];
}


- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    // Get the origin of the keyboard when it's displayed.
    NSValue *boundsValue = [userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGRect keyboardRect  = [boundsValue CGRectValue];
    
    if (keyboardRect.size.width < keyboardRect.size.height)
    {
        float tempHeight = keyboardRect.size.height;
        keyboardRect.size.height = keyboardRect.size.width;
        keyboardRect.size.width = tempHeight;
    }
    
    CGFloat keyboardTop = _defaultView.frame.size.height - keyboardRect.size.height;
    CGRect bottomViewFrame = bgView.frame;
    
    bottomViewFrame.origin.y = keyboardTop - bottomViewFrame.size.height;
    if (bottomViewFrame.size.height == textViewBgHeight)
    {
        y =bottomViewFrame.origin.y;
    }
    NSLog(@"%f",y);
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    __weak __typeof(self)weakSelf = self;
    
    [UIView animateWithDuration:animationDuration animations:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }
        
        strongSelf->bgView.frame = bottomViewFrame;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary* userInfo = [notification userInfo];
    CGRect bottomViewFrame = bgView.frame;
    bottomViewFrame.origin.y = _defaultView.frame.size.height - textViewBgHeight;
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    __weak __typeof(self)weakSelf = self;
    
    [UIView animateWithDuration:animationDuration animations:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }
        
        strongSelf->bgView.frame = bottomViewFrame;
    }];
}


//使搜索的内容 变色
- (NSMutableAttributedString *)content:(NSString *)ctt searchTxt:(NSString *)stt
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:ctt];
    
    NSRange rang = [ctt rangeOfString:stt];
    NSRange rang1 = [ctt rangeOfString:[stt uppercaseString]];//转换为大写
    NSRange rang2 = [ctt rangeOfString:[stt lowercaseString]];//转化为小写
    NSRange rang3 = [ctt rangeOfString:[stt capitalizedString]];//首字母大写
    [str addAttribute:NSForegroundColorAttributeName value:FontColorA range:rang];
    [str addAttribute:NSForegroundColorAttributeName value:FontColorA range:rang1];
    [str addAttribute:NSForegroundColorAttributeName value:FontColorA range:rang2];
    [str addAttribute:NSForegroundColorAttributeName value:FontColorA range:rang3];
    return str;
}

- (void)titleAction:(UITapGestureRecognizer *)tap
{
    PeopleInfoViewController * vc = [[PeopleInfoViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)backPress
{
    if(isShouldRefesh)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshCity" object:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
