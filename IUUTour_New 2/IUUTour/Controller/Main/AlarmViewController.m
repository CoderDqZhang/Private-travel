#import "AlarmViewController.h"
#import "WeatherModel.h"

@interface AlarmViewController ()<UIScrollViewDelegate>
{
    UIImageView  * bgImage;
    UIScrollView * weatherScroll;
    UIView       * basciInfoView;
    UILabel      * trafficTitle;
    UILabel      * emergencyTitle;
}
@end

@implementation AlarmViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    [self initWithBackBtn];
    
    self.titleLabel.text  = @"景区预警";
    self.titleView.hidden = NO;
    
    bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.titleView.bottom, App_Frame_Width, App_Frame_Height)];
    bgImage.image = [UIImage imageNamed:@"sign_bg"];

    [self.view addSubview:bgImage];
    
    [self initWeatherFramework];
}


- (int)getLevel1FontSize
{
    CGSize titleMaxSize = [[LabelSize labelsizeManger] getStringRect:self.data.scenicName MaxSize:CGSizeMake(App_Frame_Width, 30) FontSize:24];
    if (titleMaxSize.width < App_Frame_Width - 20)
    {
        return 24;
    }

    titleMaxSize = [[LabelSize labelsizeManger] getStringRect:self.data.scenicName MaxSize:CGSizeMake(App_Frame_Width, 30) FontSize:20];
    if (titleMaxSize.width < App_Frame_Width - 20)
    {
        return 20;
    }
    
    return 18;
}

- (void)updateBasicInfoUI
{
    int level3FontSize = 12;
    
    NSString *trafficDetailInfo = self.data.traffic;
    if ([trafficDetailInfo length] == 0)
    {
        trafficDetailInfo = @"暂无流量统计";
    }
    
    CGSize trafficDetailSize = [[LabelSize labelsizeManger] getStringRect:trafficDetailInfo MaxSize:CGSizeMake(App_Frame_Width, 1000) FontSize:level3FontSize];
    UILabel *trafficDetail = [[UILabel alloc] initWithFrame:CGRectMake(20, trafficTitle.bottom + 10, App_Frame_Width - 30, trafficDetailSize.height)];
    trafficDetail.numberOfLines = 0;
    [trafficDetail setFont:[UIFont systemFontOfSize:level3FontSize]];
    [trafficDetail setTextAlignment:NSTextAlignmentLeft];
    [trafficDetail setText:trafficDetailInfo];
    [trafficDetail setBackgroundColor:[UIColor clearColor]];
    [trafficDetail setTextColor:[UIColor blackColor]];
    [basciInfoView addSubview:trafficDetail];

    NSString *emergencyDetailInfo = self.data.emergency;
    if ([emergencyDetailInfo length] == 0)
    {
        emergencyDetailInfo = @"无突发事件";
    }
    CGSize emergencyDetailSize = [[LabelSize labelsizeManger] getStringRect:emergencyDetailInfo MaxSize:CGSizeMake(App_Frame_Width - 30, 1000) FontSize:level3FontSize];
    
    UILabel *emergencyDetail = [[UILabel alloc] initWithFrame:CGRectMake(20, emergencyTitle.bottom + 10, App_Frame_Width - 30, emergencyDetailSize.height)];
    emergencyDetail.numberOfLines = 0;
    [emergencyDetail setFont:[UIFont systemFontOfSize:level3FontSize]];
    [emergencyDetail setTextAlignment:NSTextAlignmentLeft];
    [emergencyDetail setText:emergencyDetailInfo];
    [emergencyDetail setBackgroundColor:[UIColor clearColor]];
    [emergencyDetail setTextColor:[UIColor blackColor]];
    [basciInfoView addSubview:emergencyDetail];
}

- (void)initWeatherFramework
{
    if (basciInfoView)
    {
        for (UIView *subView in basciInfoView.subviews)
        {
            [subView removeFromSuperview];
        }
    }
    
    basciInfoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, App_Frame_Height)];
    int level1FontSize = [self getLevel1FontSize];
    
    UILabel *scenicName = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, App_Frame_Width -20, 50)];
    [scenicName setFont:[UIFont systemFontOfSize:level1FontSize]];
    [scenicName setTextAlignment:NSTextAlignmentCenter];
    [scenicName setText:self.data.scenicName];
    [scenicName setBackgroundColor:[UIColor clearColor]];
    [scenicName setTextColor:[UIColor blackColor]];
    
    [basciInfoView addSubview:scenicName];
    
    
    int remainingHeight = App_Frame_Height - self.titleView.height - scenicName.height;
    
    
    int level2FontSize = level1FontSize - 4;

    
    trafficTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, scenicName.bottom + 10, App_Frame_Width -20, 30)];
    [trafficTitle setFont:[UIFont systemFontOfSize:level2FontSize]];
    [trafficTitle setTextAlignment:NSTextAlignmentLeft];
    [trafficTitle setText:@"景区流量"];
    [trafficTitle setBackgroundColor:[UIColor clearColor]];
    [trafficTitle setTextColor:[UIColor blackColor]];
    [basciInfoView addSubview:trafficTitle];
    
    

    UILabel *weatherTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, scenicName.bottom + remainingHeight / 4, App_Frame_Width -20, 30)];
    [weatherTitle setFont:[UIFont systemFontOfSize:level2FontSize]];
    [weatherTitle setTextAlignment:NSTextAlignmentLeft];
    [weatherTitle setText:@"景区天气"];
    [weatherTitle setBackgroundColor:[UIColor clearColor]];
    [weatherTitle setTextColor:[UIColor blackColor]];
    [basciInfoView addSubview:weatherTitle];
    
    weatherScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(10, weatherTitle.bottom, App_Frame_Width - 20, 110)];
    weatherScroll.delegate = self;
    [basciInfoView addSubview:weatherScroll];
    
    
    emergencyTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, scenicName.bottom + remainingHeight * 2 / 3, App_Frame_Width - 20, 30)];
    [emergencyTitle setFont:[UIFont systemFontOfSize:level2FontSize]];
    [emergencyTitle setTextAlignment:NSTextAlignmentLeft];
    [emergencyTitle setText:@"景区突发事件"];
    [emergencyTitle setBackgroundColor:[UIColor clearColor]];
    [emergencyTitle setTextColor:[UIColor blackColor]];
    [basciInfoView addSubview:emergencyTitle];
    
    
    
    [bgImage addSubview:basciInfoView];
}


- (NSString*)getImageNameForWeather:(NSString*)weather
{
    NSArray *weatherArray = [NSArray arrayWithObjects:
                             @"晴",
                             @"多云",
                             @"多云转晴",
                             @"阴转多云",
                             @"阴",
                             @"阵雨",
                             @"雷阵雨伴有冰雹",
                             @"雨夹雪",
                             @"小雨",
                             @"中雨",
                             @"大雨",
                             @"大暴雨",
                             @"特大暴雨",
                             @"阵雪",
                             @"小雪",
                             @"中雪",
                             @"大雪",
                             @"暴雪",
                             @"雾",
                             @"小雨转中雨",
                             @"大雨转暴雨",
                             @"暴雨转大暴雨",
                             @"大暴雨转特大暴雨",
                             @"中雪转大雪",
                             @"小雪转中雪",
                             @"大雪转暴雪",
                             @"浮尘",
                             @"扬沙",
                             @"强沙尘暴",
                             @"霾",
                             nil];
    
    NSArray *iconArray = [NSArray arrayWithObjects:
                          @"weather07",
                          @"weather29",
                          @"weather29",
                          @"weather03",
                          @"weather31",
                          @"weather31",
                          @"weather33",
                          @"weather21",
                          @"weather21",
                          @"weather21",
                          @"weather25",
                          @"weather33",
                          @"weather33",
                          @"weather21",
                          @"weather23",
                          @"weather17",
                          @"weather11",
                          @"weather11",
                          @"weather27",
                          @"weather11",
                          @"weather11",
                          @"weather11",
                          @"weather11",
                          @"weather11",
                          @"weather11",
                          @"weather11",
                          @"weather27",
                          @"weather27",
                          @"weather27",
                          @"weather27",
                          nil];
    
    NSUInteger index = [weatherArray  indexOfObject:weather];
  
    if (index < [iconArray count])
    {
        return iconArray[index];
    }
    
    return iconArray[0];
}


- (void)createWeatherUIFromList:(NSArray*)weatherList fontSize:(int)fontSize
{
    if (!weatherList || [weatherList count] <= 0)
    {
        UILabel *errorLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
        [errorLabel setTextAlignment:NSTextAlignmentCenter];
        [errorLabel setFont:[UIFont systemFontOfSize:fontSize]];
        [errorLabel setBackgroundColor:[UIColor clearColor]];
        [errorLabel setTextColor:[UIColor blackColor]];
        [errorLabel setText:@"获取天气信息失败，请稍候重试！"];
        [weatherScroll addSubview:errorLabel];
        
        weatherScroll.scrollEnabled = YES;
        [weatherScroll setContentSize:CGSizeMake(200, 120)];
        
        return;
    }
    
    
    for (UIView *subView in weatherScroll.subviews)
    {
        [subView removeFromSuperview];
    }
    

    int itemWidth = App_Frame_Width / 4 - 5;
    

    for (int i = 0; i < [weatherList count]; i ++)
    {
        WeatherModel *weatherModel = weatherList[i];
        UIView *itemView = [[UIView alloc]initWithFrame:CGRectMake(i * itemWidth, 0, itemWidth, 120)];
        
        UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, itemWidth, 30)];
        [dateLabel setTextAlignment:NSTextAlignmentCenter];
        [dateLabel setFont:[UIFont systemFontOfSize:fontSize]];
        [dateLabel setBackgroundColor:[UIColor clearColor]];
        [dateLabel setTextColor:[UIColor blackColor]];
        [dateLabel setText:weatherModel.date];
        [itemView addSubview:dateLabel];

        NSString *iconName = [self getImageNameForWeather:weatherModel.weather];
        UIImageView *weatherImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, itemWidth, itemWidth)];

        [weatherImageView setImage:[UIImage imageNamed:iconName]];
        [weatherImageView setContentMode:UIViewContentModeCenter];
        [itemView addSubview:weatherImageView];
        
        UILabel *weatherLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, itemWidth, 30)];
        [weatherLabel setTextAlignment:NSTextAlignmentCenter];
        [weatherLabel setFont:[UIFont systemFontOfSize:fontSize]];
        [weatherLabel setBackgroundColor:[UIColor clearColor]];
        [weatherLabel setTextColor:[UIColor blackColor]];
        [weatherLabel setText:weatherModel.weather];
        [itemView addSubview:weatherLabel];

        
        
        UILabel *tempertureLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 80, App_Frame_Width / 4, 30)];
        [tempertureLabel setTextAlignment:NSTextAlignmentCenter];
        [tempertureLabel setFont:[UIFont systemFontOfSize:fontSize]];
        [tempertureLabel setBackgroundColor:[UIColor clearColor]];
        [tempertureLabel setTextColor:[UIColor blackColor]];
        [tempertureLabel setText:weatherModel.tempertureOfDay];
        [itemView addSubview:tempertureLabel];
        
        [weatherScroll addSubview:itemView];
    }
    
    weatherScroll.scrollEnabled = YES;
    [weatherScroll setContentSize:CGSizeMake(itemWidth * [weatherList count], 120)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [SVProgressHUD showWithOwner:@"AlarmViewController"];

    
    [self updateBasicInfoUI];
    
    __weak __typeof(self)weakSelf = self;
    [Interface getScenicWeather:self.data.scenicId result:^(ScenicWeatherResponse *response, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }
        
        [SVProgressHUD dismissFromOwner:@"AlarmViewController"];
        
        [self createWeatherUIFromList:response.weatherList fontSize:12];
    }];

}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
