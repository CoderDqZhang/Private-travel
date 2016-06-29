#import "LuckyViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "math.h"
#import "WebViewController.h"
#import "WinnerListViewController.h"


int RelativeDegreeForPrizeLevel[10] = {36*8, 0, 36*5, 36, 36*2, 36*9, 36*6, 36*3, 36*7, 36*4};
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface LuckyViewController ()
{
    NSString    *luckyPrizeName;
    int         luckyPrizeLevel;
    int         luckyPrizeDrawingCount;
    
    UIImageView *circleImg;
    
    UIView      *congratulationBg;
    
    UIImageView *drawerButton;
}
@end

@implementation LuckyViewController

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    luckyDrawingPtrOrign  = 0;

    congratulationBg      = nil;


    self.titleLabel.text  = @"抽奖";
    self.titleView.hidden = NO;
    [self initWithBackBtn];
    

    UIImage *bgImg = [UIImage imageNamed:@"me_luckydrawer_bg.png"];


    float bgWidth  = bgImg.size.width / [UIScreen mainScreen].scale;
    float bgHeight = bgImg.size.height / [UIScreen mainScreen].scale;;
    

    float scale = App_Frame_Width / bgWidth;
    
    float renderedHeight = bgHeight * scale;
    

    UIImageView * imageBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.titleView.bottom, App_Frame_Width, renderedHeight)];
    imageBG.image       = bgImg;
    imageBG.contentMode = UIViewContentModeScaleAspectFill;
    [imageBG.layer setMasksToBounds:YES];
    [self.view addSubview:imageBG];
    
 
    float circleWidth        = 628 / [UIScreen mainScreen].scale;


    float pixelOffsite2Bg    = 336;

    float pointOffsite2Bg    = pixelOffsite2Bg / [UIScreen mainScreen].scale;
    float renderedOffsite2Bg = pointOffsite2Bg * scale;
    float expectedY          = self.titleView.bottom + renderedOffsite2Bg;
    

    float renderedCircleDiameter = circleWidth * scale;
    

    circleImg = [[UIImageView alloc] initWithFrame:CGRectMake((App_Frame_Width - renderedCircleDiameter) / 2 , expectedY, renderedCircleDiameter, renderedCircleDiameter)];
    circleImg.image = [UIImage imageNamed:@"me_luckydrawer_plane_circle"];
    circleImg.userInteractionEnabled= YES;
    [self.view addSubview:circleImg];
    

    float rotatingWidth = 530 / [UIScreen mainScreen].scale;

    
    float renderedRotatingDiameter = rotatingWidth * scale;
    
    float planeX = (renderedCircleDiameter - renderedRotatingDiameter) / 2;
    float planeY = (renderedCircleDiameter - renderedRotatingDiameter) / 2;
    

    UIImageView * planeImg = [[UIImageView alloc] initWithFrame:CGRectMake(planeX, planeY, renderedRotatingDiameter, renderedRotatingDiameter)];
    planeImg.image = [UIImage imageNamed:@"me_luckydrawer_plane"];
    planeImg.userInteractionEnabled = YES;
    
    [circleImg addSubview:planeImg];
    
    
    image2Rotate = planeImg;


    float drawerButtonWidth  = 179 / [UIScreen mainScreen].scale;
    float drawerButtonHeight = 242 / [UIScreen mainScreen].scale;
    

    float renderedDrawerButtonWidth  = drawerButtonWidth * scale;
    float renderedDrawerButtonHeight = drawerButtonHeight * scale;
    
    float drawerButtonX = (renderedCircleDiameter - renderedDrawerButtonWidth) / 2;
    float drawerButtonY = (renderedCircleDiameter - renderedDrawerButtonHeight) / 2;
    
    drawerButton = [[UIImageView alloc] initWithFrame:CGRectMake(drawerButtonX, drawerButtonY, renderedDrawerButtonWidth, renderedDrawerButtonHeight)];
    drawerButton.image = [UIImage imageNamed:@"me_luckydrawer_button"];
    drawerButton.userInteractionEnabled = YES;
    [circleImg addSubview:drawerButton];
    

    float remainingHeight      = APP_Screen_Height - circleImg.bottom;
    float expectedButtonHeight = 30;
    float expectedButtonWidth  = 70;
    BOOL isButtonOnEdge        = NO;
    if (remainingHeight < expectedButtonHeight)
    {
        isButtonOnEdge = YES;
    }
    UIButton *ruleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (!isButtonOnEdge)
    {
        ruleBtn.frame = CGRectMake(App_Frame_Width / 2 - expectedButtonWidth - 20, APP_Screen_Height - 36, expectedButtonWidth, expectedButtonHeight);
    }
    else
    {
        ruleBtn.frame = CGRectMake(5, APP_Screen_Height - 36, expectedButtonWidth, expectedButtonHeight);
    }
    
    ruleBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2f];
    [ruleBtn setTitle:@"获奖规则>" forState:UIControlStateNormal];
    ruleBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    [ruleBtn.layer setCornerRadius:5];
    [ruleBtn addTarget:self action:@selector(ruleBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ruleBtn];
    
    
    UIButton *winnerListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (!isButtonOnEdge)
    {
        winnerListBtn.frame = CGRectMake(App_Frame_Width / 2 + 20, APP_Screen_Height - 36, expectedButtonWidth, expectedButtonHeight);
    }
    else
    {
        winnerListBtn.frame = CGRectMake(App_Frame_Width - expectedButtonWidth - 5, APP_Screen_Height - 36, expectedButtonWidth, expectedButtonHeight);
    }
    winnerListBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2f];
    [winnerListBtn setTitle:@"获奖记录>" forState:UIControlStateNormal];
    winnerListBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    [winnerListBtn.layer setCornerRadius:5];
    [winnerListBtn addTarget:self action:@selector(winnerBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:winnerListBtn];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [drawerButton addGestureRecognizer:tap];
}


- (void)winnerBtnAction
{
    WinnerListViewController *vc = [[WinnerListViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)ruleBtnAction
{
    NSString *mainBundleDirectory = [[NSBundle mainBundle] bundlePath];
    NSString *ruleFileName = [NSString stringWithFormat:@"lucky_drawer_rule.html"];
    NSString *ruleFilePath = [mainBundleDirectory stringByAppendingPathComponent:ruleFileName];
    
    
    WebViewController *vc = [[WebViewController alloc] init];
    vc.titles             = @"获奖规则";
    vc.loadLocalHtmlPath  = ruleFilePath;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)handleWinning
{
    if (!congratulationBg)
    {
        congratulationBg = [[UIView alloc]initWithFrame:CGRectMake(0, self.titleView.bottom, App_Frame_Width, APP_Screen_Height)];
        
        congratulationBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
 
        UIImage *winImage     = [UIImage imageNamed:@"me_luckydrawer_win"];
        CGSize imageSize      = winImage.size;

        float congWidthPt     = imageSize.width / [UIScreen mainScreen].scale;
        float congHeightPt    = imageSize.height / [UIScreen mainScreen].scale;

        float scale           = App_Frame_Width / congWidthPt;

        float renderredHeight = congHeightPt * scale;
        
        UIImageView *congratulationImageView = [[UIImageView alloc]initWithImage:winImage];

        [congratulationImageView setFrame:CGRectMake(0, 0, App_Frame_Width, renderredHeight)];
        
        [congratulationBg addSubview:congratulationImageView];


        float closeBtnPtX    = 666 / [UIScreen mainScreen].scale;
        float closeBtnPtY    = 402 / [UIScreen mainScreen].scale;
        float renderedPointX = closeBtnPtX * scale;
        float renderedPointY = closeBtnPtY * scale;
        

        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setFrame:CGRectMake(renderedPointX - 20, renderedPointY - 20, 40, 40)];
        [closeButton setBackgroundColor:[UIColor clearColor]];

        [closeButton addTarget:self action:@selector(closeBtnAction) forControlEvents:UIControlEventTouchUpInside];
        
        [congratulationBg addSubview:closeButton];

        

        float prizeLblPtY = 580 / [UIScreen mainScreen].scale;
        float renderedPrizeLblPtY = prizeLblPtY * scale;
        
        UILabel *prizeLbl  = [[UILabel alloc]initWithFrame:CGRectMake(0, renderedPrizeLblPtY, App_Frame_Width, 30)];
        prizeLbl.text      = [NSString stringWithFormat:@"%@%@", @"奖品:  ", luckyPrizeName];
        prizeLbl.textColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
        [prizeLbl setTextAlignment:NSTextAlignmentCenter];
        [prizeLbl setFont:[UIFont systemFontOfSize:18]];
        
        [congratulationBg addSubview:prizeLbl];

        
        [self.view addSubview:congratulationBg];
    }
}

- (void)closeBtnAction
{
    [self removeCongratulation];
    [self enableDrawerButton];
}

- (void)removeCongratulation
{
    if (congratulationBg)
    {
        [congratulationBg removeFromSuperview];
        congratulationBg = nil;
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tap
{
    drawerButton.userInteractionEnabled = NO;
    
    
    luckyPrizeName          = nil;
    luckyPrizeLevel         = -1;
    luckyPrizeDrawingCount  = 0;
    
    if (![User sharedInstance].userid || [User sharedInstance].userid.length <= 0)
    {
        [UWindowHud hudWithType:kToastType withContentString:@"尚未登陆，不能参与！"];
        
        drawerButton.userInteractionEnabled = YES;
        
        return;
    }
    
    __weak __typeof(self) weakSelf = self;
    [SVProgressHUD showWithOwner:@"LuckyViewController_drawing"];
    [Interface getLottery:^(LuckyDrawerResponse *response, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
              
        if (response.status == 0)
        {
             if (response.luckyDrawerData            &&
                response.luckyDrawerData.prizeName   &&
                response.luckyDrawerData.prizeLevel  &&
                ![response.luckyDrawerData.prizeName isKindOfClass:[NSNull class]] &&
                ![response.luckyDrawerData.prizeLevel isKindOfClass:[NSNull class]])
            {
                [SVProgressHUD dismissFromOwner:@"LuckyViewController_drawing"];
                
                strongSelf->luckyPrizeName         = [NSString stringWithString:response.luckyDrawerData.prizeName];
                strongSelf->luckyPrizeLevel        = [response.luckyDrawerData.prizeLevel intValue];
                strongSelf->luckyPrizeDrawingCount = [response.luckyDrawerData.remainNum intValue];
                
                if (strongSelf->luckyPrizeLevel > 0 && strongSelf->luckyPrizeLevel <= 10)
                {
                    [self rotateCirclePanelToPrizeLevel:strongSelf->luckyPrizeLevel];
                }
                else
                {
                    [UWindowHud hudWithType:kToastType withContentString:@"未知错误，请稍候重试"];
                    
                    strongSelf->drawerButton.userInteractionEnabled = YES;
                }
            }
            else
            {
                [SVProgressHUD dismissFromOwner:@"LuckyViewController_drawing"];
                [UWindowHud hudWithType:kToastType withContentString:@"未知错误，请稍候重试"];
                
                strongSelf->drawerButton.userInteractionEnabled = YES;

            }
        }
        else if (response.status == 1)
        {
            [SVProgressHUD dismissFromOwner:@"LuckyViewController_drawing"];
            [UWindowHud hudWithType:kToastType withContentString:@"网络连接失败，请稍候重试！"];
            
            strongSelf->drawerButton.userInteractionEnabled = YES;

            
            return;
        }
        else
        {
            if ([response.luckyDrawerData.prizeName isKindOfClass:[NSNull class]])
            {
                int i = 0;
                i = 1;
            }
            
            [SVProgressHUD dismissFromOwner:@"LuckyViewController_drawing"];
            
            strongSelf->drawerButton.userInteractionEnabled = YES;
            
            if (response.message && ![response.message isKindOfClass:[NSNull class]])
            {
                [UWindowHud hudWithType:kToastType withContentString:response.message];
            }
            else
            {
                [UWindowHud hudWithType:kToastType withContentString:@"未知错误，请稍候重试"];
            }
        }
    }];
}


- (void)rotateCirclePanelToPrizeLevel:(int)prizeLevel
{
    if (prizeLevel > 10 || prizeLevel < 0)
    {
        return;
    }
    
    int addtionalAngle     = RelativeDegreeForPrizeLevel[prizeLevel - 1];
    float additionalDegree = DEGREES_TO_RADIANS(addtionalAngle) + (2.0 * M_PI - luckyDrawingPtrOrign);

    CABasicAnimation *spin = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [spin setFromValue:[NSNumber numberWithFloat:luckyDrawingPtrOrign]];
    [spin setToValue:[NSNumber numberWithFloat: (4.0 * M_PI + additionalDegree + luckyDrawingPtrOrign)]];
    [spin setDuration:2];
    [spin setDelegate:self];

    [spin setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

    [[image2Rotate layer] addAnimation:spin forKey:nil];

    image2Rotate.transform = CGAffineTransformMakeRotation(4.0 * M_PI + additionalDegree + luckyDrawingPtrOrign);

    luckyDrawingPtrOrign   = additionalDegree + luckyDrawingPtrOrign;
    luckyDrawingPtrOrign   = fmodf(luckyDrawingPtrOrign, 2.0 * M_PI);
}


/**
 * 动画开始时
 */
- (void)animationDidStart:(CAAnimation *)theAnimation
{
    NSLog(@"begin");
}

/**
 * 动画结束时
 */
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    [self performSelector:@selector(handleWinning) withObject:nil afterDelay:0.5];
}

- (void)enableDrawerButton
{
    drawerButton.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
