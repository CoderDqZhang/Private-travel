#import "RegisterViewController.h"

@interface RegisterViewController ()<UITextFieldDelegate>
@property (nonatomic,retain) NSMutableArray * sexBtnArray;
@end

@implementation RegisterViewController

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleView.hidden = NO;
    self.titleLabel.text = @"新用户注册";
    [self initWithBackBtn];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(self.titleView.width - 50, 6, 40.0f, 20.0f)];
    [rightBtn setTitle:@"完成" forState:(UIControlStateNormal)];
    [rightBtn setBackgroundColor:[UIColor clearColor]];
    [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [rightBtn setBackgroundColor:[UIColor colorWithRed:20/255. green:140/255. blue:203/255. alpha:1]];
    [rightBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:rightBtn];
    
    //显示头像
    UIImageView * headImage = [[UIImageView alloc]initWithFrame:CGRectMake(App_Frame_Width/2 - 50, self.titleView.bottom + 50, 100, 100)];
    headImage.image = [UIImage imageNamed:@"me_Icon"];
    [headImage.layer setCornerRadius:headImage.height/2];
    [headImage.layer setMasksToBounds:YES];
    [_defaultView addSubview:headImage];
    
    //拍照按钮
    UIButton * photoBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [photoBtn setFrame:CGRectMake(headImage.right - 22, headImage.bottom - 22, 23, 23)];
    [photoBtn setBackgroundColor:[UIColor clearColor]];
    [photoBtn setBackgroundImage:[UIImage imageNamed:@"sign_photoNor"] forState:UIControlStateNormal];
    [photoBtn setBackgroundImage:[UIImage imageNamed:@"sign_photoSel"] forState:UIControlStateHighlighted];
    [photoBtn addTarget:self action:@selector(photoAction) forControlEvents:(UIControlEventTouchUpInside)];
    [_defaultView addSubview:photoBtn];
    
    NSArray * titleArray = [[NSArray alloc]initWithObjects:@"用户名",@"生日",@"密码",@"重复密码", nil];
    NSArray * txtArray   = [[NSArray alloc]initWithObjects:@"请输入您的用户名",@"请选择出生日期",@"",@"", nil];
    
    for (int i = 0; i < titleArray.count; i++)
    {
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(10, (headImage.bottom + 100) + i*40 , App_Frame_Width - 10, 40)];
        view.backgroundColor = [UIColor clearColor];
        [_defaultView addSubview:view];
        
        CALayer * layer       = [CALayer layer];
        layer.frame           = CGRectMake(0, view.height-1, view.width, 1);
        layer.backgroundColor = [UIColor grayColor].CGColor;
        [view.layer addSublayer:layer];
        
        UILabel * titlelbl       = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 39)];
        titlelbl.font            = [UIFont systemFontOfSize:14];
        titlelbl.textAlignment   = NSTextAlignmentLeft;
        titlelbl.backgroundColor = [UIColor clearColor];
        titlelbl.textColor       = [UIColor blackColor];
        titlelbl.text            = [titleArray objectAtIndex:i];
        [view addSubview:titlelbl];
        
        UITextField * txt = [[UITextField alloc]initWithFrame:CGRectMake(titlelbl.right + 10 , 0, view.width - titlelbl.right -10 - 100, 39)];
        txt.delegate    = self;
//        txt.text = @"123456asdf";
        txt.tag         = 100+i;
        txt.borderStyle = UITextBorderStyleNone;
        txt.placeholder = txtArray[i];
        txt.backgroundColor = [UIColor clearColor];
        if (i>=2) {
            txt.secureTextEntry  = YES;
        }
        [view addSubview:txt];
        
        if (i == 0)
        {
            self.sexBtnArray = [[NSMutableArray alloc] init];
            
            NSArray * sexArray = [[NSArray alloc]initWithObjects:@"女",@"男", nil];
            for (int j = 2; j > 0; j--)
            {
                UIButton * button = [UIButton buttonWithType:(UIButtonTypeCustom)];
                [button setFrame:CGRectMake(view.width - 10 - j*30 , 7.5, 30, 25)];
                [button setBackgroundColor:[UIColor clearColor]];
                [button setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
                [button setTitle:sexArray[j-1] forState:(UIControlStateNormal)];
                [button.layer setBorderColor:ButtonColorC.CGColor];
                [button.layer setBorderWidth:0.5];
                [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
                [button addTarget:self action:@selector(sexAction:) forControlEvents:(UIControlEventTouchUpInside)];
                [view addSubview:button];
                
                
                [self.sexBtnArray addObject:button];
                
                if (j == 2)
                {
                    button.selected = YES;
                    [button setBackgroundColor:ButtonColorC];
                    [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
                }
            }
        }
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)doneAction
{
    [SVProgressHUD showWithOwner:@"RegisterViewController"];
    UITextField *tfUserName = (UITextField *)[self.view viewWithTag:100];
    UITextField *tfPwd      = (UITextField *)[self.view viewWithTag:102];
    if (tfUserName.text.length == 0)
    {
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请输入用户名" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
        return;
    }
    if (tfPwd.text.length == 0)
    {
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请输入密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    [Interface  registerAction:self.phone passwd:tfPwd.text loginName:tfUserName.text nickName:@"" sex:@""  address:@"" ssoSource:@"0" ssoAccount:@"" result:^(CommonActionStatus *response, NSError *err) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }
        
        NSLog(@"%@",response);
        [SVProgressHUD dismissFromOwner:@"RegisterViewController"];
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)photoAction
{
    
}

- (void)sexAction:(UIButton *)sender
{
    for (UIButton * button in self.sexBtnArray)
    {
        button.selected = NO;
        [button setBackgroundColor:[UIColor clearColor]];
        [button setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    }
    
    sender.selected = YES;
    [sender setBackgroundColor:[UIColor greenColor]];
    [sender setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
