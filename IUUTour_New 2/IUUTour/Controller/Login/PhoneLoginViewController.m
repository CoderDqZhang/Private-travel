#import "PhoneLoginViewController.h"
#import "VerifyViewController.h"
#import "FogetPassViewController.h"

@interface PhoneLoginViewController ()

@end

@implementation PhoneLoginViewController

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleView.hidden = NO;
    
    UIImageView * imageBackground = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, App_Frame_Width, App_Frame_Height+20)];
    [imageBackground setImage:[UIImage imageNamed:@"sign_bg.png"]];
    [_defaultView addSubview:imageBackground];
    
    [self initWithXBtnPhoneLogin];
    
    _phoneTF = [[UITextField alloc] initWithFrame:CGRectMake(10, 140.0f, App_Frame_Width - 20, 40)];
    _phoneTF.placeholder     = @"手机号";
    _phoneTF.backgroundColor = [UIColor clearColor];
    [_phoneTF setValue:FontColorB forKeyPath:@"_placeholderLabel.textColor"];
    _phoneTF.delegate        = self;
    _phoneTF.textColor       = FontColorB;
    _phoneTF.borderStyle     = UITextBorderStyleNone;
    _phoneTF.keyboardType    = UIKeyboardTypePhonePad;
    [_defaultView addSubview:_phoneTF];
    
    CALayer *layer = [CALayer layer];
    layer.frame           = CGRectMake(0, _phoneTF.height-1, _phoneTF.width, 1);
    layer.backgroundColor = [UIColor grayColor].CGColor;
    [_phoneTF.layer addSublayer:layer];
    
    _passwordTF = [[UITextField alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_phoneTF.frame) + 0.0f, App_Frame_Width - 20, 40)];
    _passwordTF.borderStyle              = UITextBorderStyleNone;
    _passwordTF.placeholder              = @"密码";
    _passwordTF.delegate                 = self;
    _passwordTF.backgroundColor          = [UIColor clearColor];
    _passwordTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _passwordTF.keyboardType             = UIKeyboardTypeDefault;
    _passwordTF.secureTextEntry          = YES;
    [_passwordTF setValue:FontColorB forKeyPath:@"_placeholderLabel.textColor"];
    _passwordTF.textColor                = FontColorB;
    [_defaultView addSubview:_passwordTF];
    
    CALayer * layer1 = [CALayer layer];
    layer1.frame           = CGRectMake(0, _passwordTF.height-1, _passwordTF.width, 1);
    layer1.backgroundColor = [UIColor grayColor].CGColor;
    [_passwordTF.layer addSublayer:layer1];
    
    UILabel * lbl       = [[UILabel alloc]initWithFrame:CGRectMake(App_Frame_Width - 140, CGRectGetMaxY(_passwordTF.frame) +10, 130, 30)];
    lbl.font            = [UIFont systemFontOfSize:13];
    lbl.textColor       = [UIColor whiteColor];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textAlignment   = NSTextAlignmentRight;
    lbl.attributedText  = [self content:@"忘记密码？重置密码" searchTxt:@"重置密码"];
    [_defaultView addSubview:lbl];
    
    
    UIButton *forgetBtn = [[UIButton alloc] initWithFrame:CGRectMake(App_Frame_Width - 140, CGRectGetMaxY(_passwordTF.frame) +10, 130, 30)];
    [forgetBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [forgetBtn setBackgroundColor:[UIColor clearColor]];
    forgetBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [forgetBtn addTarget:self action:@selector(forgetAction) forControlEvents:UIControlEventTouchUpInside];
    [_defaultView addSubview:forgetBtn];
    
    //登陆
    UIButton *loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(10,CGRectGetMaxY(forgetBtn.frame) +10, App_Frame_Width - 10 * 2, 40)];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:FontColorA forState:UIControlStateNormal];
    [loginBtn setBackgroundColor:[UIColor whiteColor]];
    loginBtn.layer.cornerRadius = loginBtn.height/2;
    loginBtn.clipsToBounds      = YES;
    loginBtn.titleLabel.font    = [UIFont systemFontOfSize:16.0f];
    [loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [_defaultView addSubview:loginBtn];
    
    
    //注册
    UILabel * registerlbl = [[UILabel alloc]initWithFrame:CGRectMake(App_Frame_Width/2 - 75, CGRectGetMaxY(loginBtn.frame) +100, 150, 30)];
    registerlbl.font = [UIFont systemFontOfSize:13];
    registerlbl.textColor       = [UIColor whiteColor];
    registerlbl.backgroundColor = [UIColor clearColor];
    registerlbl.textAlignment   = NSTextAlignmentRight;
    registerlbl.attributedText  = [self content:@"还没有账号？注册新用户" searchTxt:@"注册新用户"];
    [_defaultView addSubview:registerlbl];
    
    UIButton *registerBtn = [[UIButton alloc] initWithFrame:registerlbl.frame];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerBtn setBackgroundColor:[UIColor clearColor]];
    registerBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [registerBtn addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    [_defaultView addSubview:registerBtn];
    _phoneTF.textColor = [UIColor blackColor];
    _passwordTF.textColor = [UIColor blackColor];    
}

- ( void)textFieldResignFirstResponder
{
    if (_phoneTF.becomeFirstResponder)
    {
        [_phoneTF resignFirstResponder];
    }
    if (_passwordTF.becomeFirstResponder)
    {
        [_passwordTF resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)initWithXBtnPhoneLogin
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(_defaultView.width -  44, 30.0f, 16.0f, 16.0f)];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"cancel_white.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(XPressPhoneLogin) forControlEvents:UIControlEventTouchUpInside];
    [_defaultView addSubview:backBtn];
}

-(void)XPressPhoneLogin
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)loginAction
{
    if (_phoneTF.text.length!=11)
    {
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:nil message:@"请输有效的手机号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
        return;
    }
    if (_passwordTF.text.length == 0)
    {
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:nil message:@"请输入密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
        return;
    }
    
    [SVProgressHUD showWithOwner:@"PhoneLoginViewController"];
    
    __weak __typeof(self)weakSelf = self;

    [Interface loginAction:@"" passWard:_passwordTF.text loginName:_phoneTF.text ssoaccount:@"0" result:^(CommonActionStatus *response, NSError *error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }
        
        [SVProgressHUD dismissFromOwner:@"PhoneLoginViewController"];
        
        if (!response.status)
        {
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:nil message:@"登录失败" delegate:strongSelf cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [al show];
            return ;
        }
        
        if ([User isLoggedIn])
        {
            [strongSelf dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter]postNotificationName:@"LoggedInFromPhone" object:nil];
            }];
        }
    }];
}

- (void)forgetAction
{
    FogetPassViewController *vc = [[FogetPassViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)registerAction
{
    VerifyViewController * vc = [[VerifyViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

//使搜索的内容 变色
- (NSMutableAttributedString *)content:(NSString *)ctt searchTxt:(NSString *)stt
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:ctt];
    NSRange rang = [ctt rangeOfString:stt];
    [str addAttribute:NSForegroundColorAttributeName value:FontColorA range:rang];
    return str;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
