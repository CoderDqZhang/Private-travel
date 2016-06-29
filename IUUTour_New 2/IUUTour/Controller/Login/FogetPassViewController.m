#import "FogetPassViewController.h"

@interface FogetPassViewController ()

@end

@implementation FogetPassViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleView.hidden = NO;
    [self initWithBackBtn];
    self.titleLabel.text  = @"忘记密码";
    
    _phoneTF = [[UITextField alloc] initWithFrame:CGRectMake(10, self.titleView.bottom + 15, App_Frame_Width - 20, 40)];
    _phoneTF.placeholder     = @"您的手机号码";
    _phoneTF.backgroundColor = [UIColor clearColor];
    _phoneTF.delegate        = self;
    _phoneTF.textColor       = [UIColor blackColor];
    _phoneTF.borderStyle     = UITextBorderStyleNone;
    _phoneTF.keyboardType    = UIKeyboardTypePhonePad;
    [_defaultView addSubview:_phoneTF];
    
    CALayer *layer = [CALayer layer];
    layer.frame           = CGRectMake(0, _phoneTF.height - .5f, App_Frame_Width, .5f);
    layer.backgroundColor = [UIColor grayColor].CGColor;
    [_phoneTF.layer addSublayer:layer];
    
    UIButton *pbutton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [pbutton setFrame:CGRectMake(App_Frame_Width - 110 , self.titleView.bottom + 15, 100, 30)];
    [pbutton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [pbutton setTitleColor:FontColorA forState:(UIControlStateNormal)];
    [pbutton setBackgroundColor:[UIColor whiteColor]];
    [pbutton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [pbutton.layer setBorderColor:[UIColor grayColor].CGColor];
    [pbutton.layer setBorderWidth:0.5f];
    pbutton.layer.contentsScale = 5.0f;
    [pbutton addTarget:self action:@selector(verifyBtn) forControlEvents:(UIControlEventTouchUpInside)];
    [_defaultView addSubview:pbutton];
}

- ( void)textFieldResignFirstResponder
{
    if (_phoneTF.becomeFirstResponder)
    {
        [_phoneTF resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)verifyBtn
{
    if (_phoneTF.text.length != 11)
    {
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:nil message:@"请输有效的手机号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
        return;
    }
    
    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [Interface forgetPassWord:_phoneTF.text result:^(CommonActionStatus *response, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }

        
        if (response.status)
        {
            [SVProgressHUD showSuccessWithStatus:@"手机密码已经发送到您的手机上！"];
            [strongSelf.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"您的手机号码尚未注册！"];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
