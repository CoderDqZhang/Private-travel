#import "ShareViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView * imageBackground = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, App_Frame_Width, App_Frame_Height+20)];
    [imageBackground setUserInteractionEnabled:YES];
    [imageBackground setImage:[UIImage imageNamed:@"sign_bg.png"]];
    [_defaultView addSubview:imageBackground];
    
    [self initWithXBtnShare];
    
    //分享
    UILabel * Sharelbl       = [[UILabel alloc]initWithFrame:CGRectMake(0,170, App_Frame_Width, 30)];
    Sharelbl.font            = [UIFont systemFontOfSize:15];
    Sharelbl.textAlignment   = NSTextAlignmentCenter;
    Sharelbl.textColor       = [UIColor whiteColor];
    Sharelbl.backgroundColor = [UIColor clearColor];
    Sharelbl.text            = @"分享";
    [imageBackground addSubview:Sharelbl];
    
    
    NSArray *imageArray = @[@"share_weChat.png",@"share_friend.png",@"share_sina.png",@"share_tencent.png",@"share_qq.png",@"share_zone.png",@"share_renren.png",@"share_message.png"];
    
    
    NSArray *titleArray = @[@"微信",@"微信朋友圈",@"新浪微博",@"腾讯微博",@"QQ好友",@"QQ空间",@"人人网",@"电子邮件"];
 
    CGFloat imageWith = (App_Frame_Width -100)/4;
    for (int i = 0 ; i < 8; i ++)
    {
        UIImageView * pImg = [[UIImageView alloc]initWithFrame:CGRectMake((i%4)*(imageWith +20) +20, floor(i/4)*(imageWith  + 40) + Sharelbl.bottom + 10, imageWith, imageWith)];
        pImg.userInteractionEnabled = YES;
        pImg.tag = i;
        pImg.image = [UIImage imageNamed:[imageArray objectAtIndex:i]];
        [imageBackground addSubview:pImg];
        
        UILabel * pLabelName = [[UILabel alloc]initWithFrame:CGRectMake((i%4)*(imageWith +20) +20, pImg.bottom + 5, imageWith, 20)];
        pLabelName.text            = [titleArray objectAtIndex:i];
        pLabelName.font            = [UIFont systemFontOfSize:12];
        pLabelName.textAlignment   = NSTextAlignmentCenter;
        pLabelName.textColor       = [UIColor whiteColor];
        pLabelName.backgroundColor = [UIColor clearColor];
        [imageBackground addSubview:pLabelName];
        
        UITapGestureRecognizer * pTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(HalImageClick:)];
        [pImg addGestureRecognizer:pTap];
    }
}

#pragma mark - button aciton
-(void)initWithXBtnShare
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(_defaultView.width -  44, 30.0f, 16.0f, 16.0f)];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"cancel_white.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(XPressShare) forControlEvents:UIControlEventTouchUpInside];
    [_defaultView addSubview:backBtn];
}

- (void)XPressShare
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)HalImageClick:(UITapGestureRecognizer *)tap
{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
