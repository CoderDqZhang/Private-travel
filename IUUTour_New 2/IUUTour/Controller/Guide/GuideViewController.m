#import "GuideViewController.h"

#define MAX_PAGE_NUM        4

@interface GuideViewController ()

@end

@implementation GuideViewController


-(id) init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)dealloc
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    NSInteger height = App_Frame_Height;
    NSInteger y      = 0;
    if (IsOSVersionAtLeastiOS7())
    {
        height = App_Frame_Height + 40;
        y      = -20;
    }
    CGRect rect = CGRectMake(0, y, App_Frame_Width, height);
    
    _scroll_view = [[UIScrollView alloc] initWithFrame: rect];
    _scroll_view.showsVerticalScrollIndicator   = NO;
    _scroll_view.showsHorizontalScrollIndicator = YES;
    _scroll_view.pagingEnabled                  = YES;
    _scroll_view.delegate                       = self;
    _scroll_view.bounces                        = YES;
    _scroll_view.showsHorizontalScrollIndicator = NO;
    int index = 0;
    NSArray *imgArr = @[@"guide1.png",@"guide2.png",@"guide3.png",@"guide4.png"];
    for(int i = 0 ;i < MAX_PAGE_NUM; i ++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.frame = CGRectMake(i * App_Frame_Width, 0.0, App_Frame_Width, App_Frame_Height);
        
        if (IsOSVersionAtLeastiOS7())
        {
            imageView.frame = CGRectMake(i * App_Frame_Width, 0.0, App_Frame_Width, App_Frame_Height + 20);
        }
        imageView.image = [UIImage imageNamed:imgArr[i]];
        [_scroll_view addSubview:imageView];
        index ++;
    }
    
    [self.view addSubview:_scroll_view];
    
    CGSize size = CGSizeMake(App_Frame_Width * MAX_PAGE_NUM, App_Frame_Height);
    [_scroll_view setContentSize:size];
    
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startButton.frame = CGRectMake(App_Frame_Width * (MAX_PAGE_NUM -1), 0, App_Frame_Width, App_Frame_Height);
    [startButton addTarget:self
                    action:@selector(StartButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_scroll_view addSubview:startButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return YES; // 返回NO表示要显示，返回YES将hiden
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == App_Frame_Width * 3)
    {
        UIButton *Btn = [UIButton buttonWithType:UIButtonTypeCustom];
        Btn.frame              = CGRectMake((App_Frame_Width - 90)/2, App_Frame_Height - 86, 90, 32);
        Btn.backgroundColor    = [UIColor clearColor];
        Btn.layer.cornerRadius = 5;
        Btn.layer.borderColor  = [UIColor blackColor].CGColor;
        Btn.layer.borderWidth  = 1;
        [Btn setTitle:@"点击进入" forState:UIControlStateNormal];
        [Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [Btn addTarget:self action:@selector(guideIsEndAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:Btn];
        Btn.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            Btn.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)guideIsEndAction
{
    [APP_DELEGATE setRootViewController];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)StartButtonClick
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"2" forKey:@"guideStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
