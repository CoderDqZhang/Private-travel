#import "PeopleInfoViewController.h"
#import "ShareViewController.h"
@interface PeopleInfoViewController ()

@end

@implementation PeopleInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView * imageBackground = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, App_Frame_Width, App_Frame_Height+20)];
    [imageBackground setUserInteractionEnabled:YES];
    [imageBackground setImage:[UIImage imageNamed:@"sign_bg.png"]];
    [_defaultView addSubview:imageBackground];
    
    //头像
    UIImageView * headImg = [[UIImageView alloc]initWithFrame:CGRectMake(App_Frame_Width/2 - 51, 170, 102, 102)];
    headImg.image         = [UIImage imageNamed:@"sign_logo.png"];
    [imageBackground addSubview:headImg];

    //姓名
    UILabel * namelbl       = [[UILabel alloc]initWithFrame:CGRectMake(0,headImg.bottom + 10, App_Frame_Width, 30)];
    namelbl.font            = [UIFont systemFontOfSize:15];
    namelbl.textAlignment   = NSTextAlignmentCenter;
    namelbl.textColor       = [UIColor whiteColor];
    namelbl.backgroundColor = [UIColor clearColor];
    namelbl.text            = @"李开复";
    [imageBackground addSubview:namelbl];
    
    CGSize nameSize =[[LabelSize labelsizeManger]getStringRect:@"李开复" MaxSize:CGSizeMake(App_Frame_Width, 30) FontSize:15];

    //性别
    UIImageView * sexImg = [[UIImageView alloc]initWithFrame:CGRectMake(imageBackground.width/2 + nameSize.width/2 +5, namelbl.top + 9, 7, 12)];
    sexImg.image         = [UIImage imageNamed:@"me_man.png"];
    [imageBackground addSubview:sexImg];
    
    //年龄 地址
    UILabel * agelbl       = [[UILabel alloc]initWithFrame:CGRectMake(0, namelbl.bottom, imageBackground.width, 20)];
    agelbl.font            = [UIFont systemFontOfSize:15];
    agelbl.textAlignment   = NSTextAlignmentCenter;
    agelbl.textColor       = [UIColor whiteColor];
    agelbl.backgroundColor = [UIColor clearColor];
    agelbl.text            = @"28岁、山东青岛";
    [imageBackground addSubview:agelbl];
    
    //打招呼
    UIButton *helloBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    helloBtn.layer.cornerRadius = 15.0f;
    helloBtn.layer.borderWidth  = 1;
    helloBtn.titleLabel.font    = [UIFont systemFontOfSize:13];
    [helloBtn setFrame:CGRectMake(imageBackground.width/2 -  100, agelbl.bottom + 70, 200.0f, 30.0f)];
    [helloBtn setBackgroundColor:[UIColor whiteColor]];
    [helloBtn setTitle:@"打招呼" forState:(UIControlStateNormal)];
    [helloBtn setTitleColor:FontColorA forState:(UIControlStateNormal)];
    [helloBtn addTarget:self action:@selector(helloAction) forControlEvents:UIControlEventTouchUpInside];
    [imageBackground addSubview:helloBtn];
    
    [self initWithXBtnInfo];
}

-(void)initWithXBtnInfo
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(_defaultView.width -  44, 30.0f, 16.0f, 16.0f)];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"cancel_white.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(XPressInfo) forControlEvents:UIControlEventTouchUpInside];
    [_defaultView addSubview:backBtn];
}

- (void)XPressInfo
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)helloAction
{
    ShareViewController * vc = [[ShareViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
