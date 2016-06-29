#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

@synthesize titleView;
@synthesize titleLabel;
@synthesize defaultView = _defaultView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage createImageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage createImageWithColor:[UIColor clearColor]]];
//    UIView *proView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, App_Frame_Height)];
//    [proView setBackgroundColor:PerSonBgColor];
//    [self.view addSubview:proView];
    if (!_defaultView)
    {
        _defaultView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, App_Frame_Height)];
        _defaultView.backgroundColor = PerSonBgColor;
    }
//    _defaultView.frame = CGRectMake(0, 0,App_Frame_Width, CGRectGetHeight(self.view.frame));
    
    
    [self.view addSubview:_defaultView];
    
    NSInteger height = 0;
    if (IsOSVersionAtLeastiOS7())
    {
        height = 20;
        UIView *aidView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 20)];
        aidView.backgroundColor = [UIColor colorWithRed:32/255 green:32/255 blue:35/255 alpha:1.0];
        aidView.backgroundColor = [UIColor clearColor];
        aidView.tag = 0xf5;
        [_defaultView addSubview:aidView];
    }
    
    if (!titleView)
    {
        titleView = [[UIView alloc] initWithFrame:CGRectMake(0, height, App_Frame_Width, 44.0f)];
        titleView.backgroundColor = [UIColor colorWithRed:32/255 green:32/255 blue:35/255 alpha:1.0];
        titleView.backgroundColor =  [UIColor clearColor];
        titleView.hidden = YES;
    }
    
    [_defaultView addSubview:titleView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 44.0f)];
//    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleView addSubview:titleLabel];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5f, App_Frame_Width, 0.5F)];
    line.backgroundColor = [UIColor grayColor];
    [titleView addSubview:line];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)initWithBackBtn
{
//    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [backBtn setFrame:CGRectMake(0.0f, 2.0f, 50.0f, 40.0f)];
//    [backBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
//    [backBtn addTarget:self action:@selector(backPress) forControlEvents:UIControlEventTouchUpInside];
//    [self.titleView addSubview:backBtn];
}

-(void)backPress
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initWithXBtn
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(11.0f, 11.0f, 22.0f, 22.0f)];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(XPress) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:backBtn];
}

-(void)XPress
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end
