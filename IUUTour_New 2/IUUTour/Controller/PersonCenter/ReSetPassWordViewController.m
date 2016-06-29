#import "ReSetPassWordViewController.h"

@interface ReSetPassWordViewController ()

@end

@implementation ReSetPassWordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleView.hidden = NO;
    [self initWithBackBtn];
    self.titleLabel.text  = @"重置密码";
    
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(self.titleView.width - 60, 14.5, 54.0f, 25.0f)];
    [rightBtn setTitle:@"完成" forState:(UIControlStateNormal)];
    [rightBtn setBackgroundColor:[UIColor colorWithRed:20/255. green:140/255. blue:203/255. alpha:1]];
    [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    rightBtn.layer.cornerRadius = 5.0f;
    rightBtn.clipsToBounds = YES;
    [rightBtn addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:rightBtn];
    
    _passwordTF = [[UITextField alloc] initWithFrame:CGRectMake(10, self.titleView.bottom, App_Frame_Width - 20, 40)];
    _passwordTF.borderStyle              = UITextBorderStyleNone;
    _passwordTF.placeholder              = @"请输入新密码";
    _passwordTF.delegate                 = self;
    _passwordTF.backgroundColor          = [UIColor clearColor];
    _passwordTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _passwordTF.keyboardType             = UIKeyboardTypeDefault;
    _passwordTF.secureTextEntry          = YES;
    [_defaultView addSubview:_passwordTF];
    
    CALayer * layer = [CALayer layer];
    layer.frame = CGRectMake(0, _passwordTF.height-1, _passwordTF.width, 1);
    layer.backgroundColor = [UIColor grayColor].CGColor;
    [_passwordTF.layer addSublayer:layer];
    
    
    _repasswordTF = [[UITextField alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_passwordTF.frame) + 0.0f, App_Frame_Width - 20, 40)];
    _repasswordTF.borderStyle              = UITextBorderStyleNone;
    _repasswordTF.placeholder              = @"请重复输入新密码";
    _repasswordTF.delegate                 = self;
    _passwordTF.backgroundColor            = [UIColor clearColor];
    _repasswordTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _repasswordTF.keyboardType             = UIKeyboardTypeDefault;
    _repasswordTF.secureTextEntry          = YES;
    [_defaultView addSubview:_repasswordTF];
    
    CALayer * layer1 = [CALayer layer];
    layer1.frame = CGRectMake(0, _repasswordTF.height-1, _repasswordTF.width, 1);
    layer1.backgroundColor = [UIColor grayColor].CGColor;
    [_repasswordTF.layer addSublayer:layer1];

}

- ( void)textFieldResignFirstResponder
{
    if (_repasswordTF.becomeFirstResponder)
    {
        [_repasswordTF resignFirstResponder];
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

#pragma marki¥ button action 
- (void)rightAction
{
    if (![_passwordTF.text isEqualToString:_repasswordTF.text])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入相同的密码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [Interface resetAction:[User sharedInstance].userid passWard:_passwordTF.text result:^(CommonActionStatus *response, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }
        
        [SVProgressHUD showSuccessWithStatus:@"更新密码成功!"];
        [strongSelf.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
