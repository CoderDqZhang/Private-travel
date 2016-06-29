#import "VerifyViewController.h"
#import "RegisterViewController.h"
@interface VerifyViewController ()
{
    UILabel * showlbl;
    NSString *strVercode;
}
@end

@implementation VerifyViewController

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
    [self initWithBackBtn];
    self.titleLabel.text  = @"验证手机号";
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(self.titleView.width - 60, 14.5, 54.0f, 25.0f)];
    [rightBtn setTitle:@"下一步" forState:(UIControlStateNormal)];
    [rightBtn setBackgroundColor:[UIColor colorWithRed:20/255. green:140/255. blue:203/255. alpha:1]];
    [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    rightBtn.layer.cornerRadius = 5.0f;
    rightBtn.clipsToBounds      = YES;
    [rightBtn addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:rightBtn];
    
    _phoneTF = [[UITextField alloc] initWithFrame:CGRectMake(10, self.titleView.bottom + 15, App_Frame_Width - 20, 40)];
    _phoneTF.placeholder     = @"您的手机号码";
    _phoneTF.backgroundColor = [UIColor clearColor];
    _phoneTF.delegate        = self;
    _phoneTF.textColor       = [UIColor blackColor];
    _phoneTF.borderStyle     = UITextBorderStyleNone;
    _phoneTF.keyboardType    = UIKeyboardTypePhonePad;
    [_defaultView addSubview:_phoneTF];
    
    CALayer *layer        = [CALayer layer];
    layer.frame           = CGRectMake(0, _phoneTF.height - .5f, App_Frame_Width, .5f);
    layer.backgroundColor = [UIColor grayColor].CGColor;
    [_phoneTF.layer addSublayer:layer];
    
    _verifyNumTF = [[UITextField alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_phoneTF.frame) + 0.0f, App_Frame_Width - 120, 40)];
    _verifyNumTF.borderStyle     = UITextBorderStyleNone;
    _verifyNumTF.placeholder     = @"请输入短信验证码";
    _verifyNumTF.delegate        = self;
    _verifyNumTF.backgroundColor = [UIColor clearColor];
    _verifyNumTF.borderStyle     = UITextBorderStyleNone;
    _verifyNumTF.keyboardType    = UIKeyboardTypePhonePad;
    [_defaultView addSubview:_verifyNumTF];
    
    CALayer *layer1        = [CALayer layer];
    layer1.frame           = CGRectMake(0, _verifyNumTF.height - .5f, App_Frame_Width, .5f);
    layer1.backgroundColor = [UIColor grayColor].CGColor;
    [_verifyNumTF.layer addSublayer:layer1];
    
    UIButton *pbutton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [pbutton setFrame:CGRectMake(CGRectGetMaxX(_verifyNumTF.frame) , CGRectGetMinY(_verifyNumTF.frame)+ 5, 100, 30)];
    [pbutton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [pbutton setTitleColor:FontColorA forState:(UIControlStateNormal)];
    [pbutton setBackgroundColor:[UIColor whiteColor]];
    [pbutton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [pbutton.layer setBorderColor:[UIColor grayColor].CGColor];
    [pbutton.layer setBorderWidth:0.5f];
    pbutton.layer.contentsScale = 5.0f;
    [pbutton addTarget:self action:@selector(verifyBtn) forControlEvents:(UIControlEventTouchUpInside)];
    [_defaultView addSubview:pbutton];
    
    showlbl = [[UILabel alloc]initWithFrame:CGRectMake(10, _verifyNumTF.bottom, App_Frame_Width - 10, 50)];
    showlbl.font = [UIFont systemFontOfSize:12];
    showlbl.textAlignment   = NSTextAlignmentLeft;
    showlbl.backgroundColor = [UIColor clearColor];
    showlbl.textColor       = [UIColor blackColor];
    showlbl.numberOfLines   = 0;
    [_defaultView addSubview:showlbl];
}

- ( void)textFieldResignFirstResponder
{
    if (_phoneTF.becomeFirstResponder)
    {
        [_phoneTF resignFirstResponder];
    }
    if (_verifyNumTF.becomeFirstResponder)
    {
        [_verifyNumTF resignFirstResponder];
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
    [Interface sendVerifyCodeByPhone:_phoneTF.text result:^(VerifyCodeByPgoneResponse *response, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }
        
        if (response.status)
        {
            if (!strongSelf)
            {
                return;
            }
            
            strongSelf->showlbl.text = [NSString stringWithFormat:@"验证码已经通过短信的形式发送到你的手机：%@，请注意查收。",strongSelf->_phoneTF.text];
            strongSelf->strVercode = response.verfyCode;
            [SVProgressHUD dismiss];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"手机号码已经注册！"];
        }
    }];
}

//  Add new map
- (void)rightAction
{
    if (_phoneTF.text.length!=11) {
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:nil message:@"请输有效的手机号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
        return;
    }
    if (_verifyNumTF.text.length == 0) {
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:nil message:@"请输验证码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
        return;
    }
    RegisterViewController * vc = [[RegisterViewController alloc]init];
    vc.phone = _phoneTF.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
