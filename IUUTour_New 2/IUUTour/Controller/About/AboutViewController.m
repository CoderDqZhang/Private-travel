#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleView.hidden = NO;
    [self initWithBackBtn];
    self.titleLabel.text  = @"关于我们";
    
    UIImageView *iuuIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(self.titleView.frame) + 10, 60, 60)];
    iuuIcon.image = [UIImage imageNamed:@"about_logo"];
    [_defaultView addSubview:iuuIcon];
    
    UILabel *iUU = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(iuuIcon.frame) + 10, CGRectGetMinY(iuuIcon.frame)+10, 100, 20)];
    iUU.backgroundColor = [UIColor clearColor];
    iUU.textAlignment   = NSTextAlignmentLeft;
    iUU.text            = @"IUU旅行";
    iUU.font            = [UIFont systemFontOfSize:14.0f];
    iUU.textColor       = [UIColor blackColor];
    [_defaultView addSubview:iUU];
   
    UILabel *uboxVersion = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(iuuIcon.frame) +10, CGRectGetMaxY(iUU.frame), 100, 20)];
    uboxVersion.backgroundColor = [UIColor clearColor];
    uboxVersion.textAlignment = NSTextAlignmentLeft;
    uboxVersion.text          = [NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    uboxVersion.font          = [UIFont systemFontOfSize:12.0f];
    uboxVersion.textColor     = [UIColor grayColor];
    [_defaultView addSubview:uboxVersion];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(iuuIcon.frame) + 10, App_Frame_Width, 0.5F)];
    line.backgroundColor = [UIColor grayColor];
    [_defaultView addSubview:line];
    
    UILabel *iUUAbout        = [[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(line.frame) + 10, 260, 16)];
    iUUAbout.backgroundColor = [UIColor clearColor];
    iUUAbout.text            = @"“IUU旅行”APP介绍";
    iUUAbout.font            = [UIFont systemFontOfSize:14.0f];
    iUUAbout.textColor       = [UIColor blackColor];
    [_defaultView addSubview:iUUAbout];
    
    UILabel *iuuAbout = [[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(iUUAbout.frame), App_Frame_Width - 30, 90)];
    iuuAbout.backgroundColor = [UIColor clearColor];
    iuuAbout.numberOfLines = 6;
    iuuAbout.text = @"“IUU旅行”APP是一款专注服务于景区内部导览的旅游软件，采用形象有趣的卡通手绘地图进行景区内实时导航，运用幽默动听的UU语音讲解景点故事，拥有人性化的路线规划推荐，也可进行景区人流量与天气的预警，更能帮您推荐周边服务设施等。“IUU旅行”在手，让您行的更远更自由！";
    iuuAbout.font = [UIFont systemFontOfSize:12.0f];
    iuuAbout.textColor = [UIColor blackColor];
    [_defaultView addSubview:iuuAbout];
    
    UILabel *versonL        = [[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(iuuAbout.frame), App_Frame_Width - 30,20)];
    versonL.backgroundColor = [UIColor clearColor];
    NSString *versionText   = [NSString stringWithFormat:@"版本号：iOS版本：%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    versonL.text            = versionText;//@"版本号：iOS版本：2.0.3";
    versonL.font            = [UIFont systemFontOfSize:12.0f];
    versonL.textColor       = [UIColor blackColor];
    [_defaultView addSubview:versonL];
    
    UILabel *phoneL = [[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(versonL.frame), App_Frame_Width - 30,20)];
    phoneL.backgroundColor = [UIColor clearColor];
    phoneL.text = @"客服热线：4000396868";
    phoneL.font = [UIFont systemFontOfSize:12.0f];
    phoneL.textColor = [UIColor blackColor];
    [_defaultView addSubview:phoneL];
    
    UILabel *websitL         = [[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(phoneL.frame), App_Frame_Width - 30,20)];
    websitL.backgroundColor  = [UIColor clearColor];
    websitL.text             = @"官方网住：http://www.imyuu.com/";
    websitL.font             = [UIFont systemFontOfSize:12.0f];
    websitL.textColor        = [UIColor blackColor];
    [_defaultView addSubview:websitL];

    UILabel *weichatL        = [[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(websitL.frame), App_Frame_Width - 30,20)];
    weichatL.backgroundColor = [UIColor clearColor];
    weichatL.text            = @"官方微信服务号：hxtx1960";
    weichatL.font            = [UIFont systemFontOfSize:12.0f];
    weichatL.textColor       = [UIColor blackColor];
    [_defaultView addSubview:weichatL];
}


@end
