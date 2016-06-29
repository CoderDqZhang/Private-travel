#import "FeedBackViewController.h"
#import "UIImage+UIColor.h"


#define FeedBackPlaceHolder1 @"请输入你的建议"
#define FeedBackPlaceHolder2 @"建议您留下联系方式，如电话、微信等。"

@interface FeedBackViewController ()
{
    UITextView  * txtSuggest;
    UITextField * tfPhone;
}
@end

@implementation FeedBackViewController

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleView.hidden = NO;
    [self initWithBackBtn];
    self.titleLabel.text  = @"意见反馈";

    
    //  Submit button
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(App_Frame_Width - 15.0f - 40.f, 10, 50.0f, 30.0f)];
    [rightBtn setBackgroundColor:[UIColor colorWithRed:20/255. green:140/255. blue:203/255. alpha:1]];
    [rightBtn setTitle:@"提交" forState:UIControlStateNormal];
    rightBtn.layer.cornerRadius = 5.0f;
    rightBtn.titleLabel.font    = [UIFont systemFontOfSize:14.];
    [rightBtn addTarget:self action:@selector(rightPress) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:rightBtn];

    
    int  spac           = 10;
    txtSuggest          = [[UITextView alloc] initWithFrame:CGRectMake(spac, CGRectGetMaxY(self.titleView.frame)+10, App_Frame_Width-spac*2, 120)];
    txtSuggest.text     = FeedBackPlaceHolder1;
    txtSuggest.delegate = self;
    [_defaultView addSubview:txtSuggest];
    
    
    UILabel *lineV        = [[UILabel alloc] initWithFrame:CGRectMake(spac, CGRectGetMaxY(txtSuggest.frame), App_Frame_Width-spac, .5)];
    lineV.backgroundColor = [UIColor grayColor];
    [_defaultView addSubview:lineV];

    tfPhone               = [[UITextField alloc] initWithFrame:CGRectMake(spac, CGRectGetMaxY(txtSuggest.frame), App_Frame_Width-spac*2, 50)];
    tfPhone.placeholder   = FeedBackPlaceHolder2;
    [_defaultView addSubview:tfPhone];

    lineV                 = [[UILabel alloc] initWithFrame:CGRectMake(spac, CGRectGetMaxY(tfPhone.frame), App_Frame_Width-spac, .5)];
    lineV.backgroundColor = [UIColor grayColor];
    [_defaultView addSubview:lineV];
    
    
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:FeedBackPlaceHolder1])
    {
        textView.text = @"";
    }
}


- (void)rightPress
{
    [self.view endEditing:YES];
    
    NSString *transString =  (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)txtSuggest.text, NULL, NULL,  kCFStringEncodingUTF8 ));
    
    if (!transString ||
        [transString length] == 0 ||
        [txtSuggest.text compare:FeedBackPlaceHolder1] == NSOrderedSame)
    {
        [UWindowHud hudWithType:kToastType withContentString:@"内容不能为空！"];

        
        return;
    }
    
    [SVProgressHUD showWithOwner:@"FeedBackViewController"];
    [Interface feedBack:[User sharedInstance].userid content:transString result:^(CommonActionStatus *response, NSError *error) {
        [SVProgressHUD dismissFromOwner:@"FeedBackViewController"];
        //  Attention, the server return 0 if request succeeds
        if (response && response.status == 0)
        {
            [UWindowHud hudWithType:kToastType withContentString:@"提交成功，非常感谢！"];

        }
        else
        {
            [UWindowHud hudWithType:kToastType withContentString:@"提交失败，请检查网络后重试！"];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
