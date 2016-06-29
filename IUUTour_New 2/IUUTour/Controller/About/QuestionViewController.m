#import "QuestionViewController.h"

@interface QuestionViewController ()

@end

@implementation QuestionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleView.hidden = NO;
    [self initWithBackBtn];
    self.titleLabel.text  = @"功能介绍";
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleView.frame), App_Frame_Width, CGRectGetHeight(_defaultView.frame) -  CGRectGetMaxY(self.titleView.frame))];
    _scrollView.delegate        = self;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.scrollEnabled   = YES;
    [_defaultView addSubview:_scrollView];
    
    UILabel *indexL        = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, App_Frame_Width - 20, 20)];
    indexL.backgroundColor = [UIColor clearColor];
    indexL.textColor       = [UIColor blackColor];
    indexL.font            = [UIFont systemFontOfSize:16.0f];
    indexL.text            = @"1、手绘导览图";
    [_scrollView addSubview:indexL];
    
    UILabel *indexDetailL        = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(indexL.frame)+5, App_Frame_Width - 20, 35)];
    indexDetailL.backgroundColor = [UIColor clearColor];
    indexDetailL.textColor       = [UIColor blackColor];
    indexDetailL.numberOfLines   = 2;
    indexDetailL.font            = [UIFont systemFontOfSize:14.0f];
    indexDetailL.text            = @"       生动可爱的手绘卡通地图，全方位、多角度炫酷地展示景区秀美风光。";
    [_scrollView addSubview:indexDetailL];
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(indexDetailL.frame)+5, App_Frame_Width - 20, 540)];
    img.image = [UIImage imageNamed:@"load_one1.jpg"];
    [_scrollView addSubview:img];
    
    indexL                 = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(img.frame)+5, App_Frame_Width - 20, 20)];
    indexL.backgroundColor = [UIColor clearColor];
    indexL.textColor       = [UIColor blackColor];
    indexL.font            = [UIFont systemFontOfSize:16.0f];
    indexL.text            = @"2、语音讲解";
    [_scrollView addSubview:indexL];
    
    indexDetailL                 = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(indexL.frame)+5, App_Frame_Width - 20, 35)];
    indexDetailL.backgroundColor = [UIColor clearColor];
    indexDetailL.textColor       = [UIColor blackColor];
    indexDetailL.numberOfLines   = 2;
    indexDetailL.font            = [UIFont systemFontOfSize:14.0f];
    indexDetailL.text            = @"       萌萌的UU幽默、生动地讲解景区内每一个景点，景点解说由您任性选择。";
    [_scrollView addSubview:indexDetailL];
    
    img = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(indexDetailL.frame)+5, App_Frame_Width - 20, 540)];
    img.image = [UIImage imageNamed:@"load_one2.jpg"];
    [_scrollView addSubview:img];
    
    indexL                 = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(img.frame)+5, App_Frame_Width - 20, 20)];
    indexL.backgroundColor = [UIColor clearColor];
    indexL.textColor       = [UIColor blackColor];
    indexL.font            = [UIFont systemFontOfSize:16.0f];
    indexL.text            = @"3、GPS定位功能";
    [_scrollView addSubview:indexL];
    
    indexDetailL                 = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(indexL.frame)+5, App_Frame_Width - 20, 35)];
    indexDetailL.backgroundColor = [UIColor clearColor];
    indexDetailL.textColor       = [UIColor blackColor];
    indexDetailL.numberOfLines   = 2;
    indexDetailL.font            = [UIFont systemFontOfSize:14.0f];
    indexDetailL.text            = @"       新增“GPS定位”，可以在景区内实时导航，任意畅游。";
    [_scrollView addSubview:indexDetailL];
    
    img = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(indexDetailL.frame)+5, App_Frame_Width - 20, 540)];
    img.image = [UIImage imageNamed:@"load_one3.png"];
    [_scrollView addSubview:img];
    
    indexL                 = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(img.frame)+5, App_Frame_Width - 20, 20)];
    indexL.backgroundColor = [UIColor clearColor];
    indexL.textColor       = [UIColor blackColor];
    indexL.font            = [UIFont systemFontOfSize:16.0f];
    indexL.text            = @"4、景区交通和小贴士";
    [_scrollView addSubview:indexL];
    
    indexDetailL = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(indexL.frame)+5, App_Frame_Width - 20, 35)];
    indexDetailL.backgroundColor = [UIColor clearColor];
    indexDetailL.textColor = [UIColor blackColor];
    indexDetailL.numberOfLines = 2;
    indexDetailL.font = [UIFont systemFontOfSize:14.0f];
    indexDetailL.text = @"       为您提供最贴心的服务，景区的简介、交通路线、门票价格、开放时间、最佳旅游时节等相关信息应有尽有。";
    [_scrollView addSubview:indexDetailL];
    
    img = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(indexDetailL.frame)+5, App_Frame_Width - 20, 540)];
    img.image = [UIImage imageNamed:@"load_one4.png"];
    [_scrollView addSubview:img];
    
    indexL                 = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(img.frame)+5, App_Frame_Width - 20, 20)];
    indexL.backgroundColor = [UIColor clearColor];
    indexL.textColor       = [UIColor blackColor];
    indexL.font            = [UIFont systemFontOfSize:16.0f];
    indexL.text            = @"5、路线规划";
    [_scrollView addSubview:indexL];
    
    indexDetailL                 = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(indexL.frame)+5, App_Frame_Width - 20, 35)];
    indexDetailL.backgroundColor = [UIColor clearColor];
    indexDetailL.textColor       = [UIColor blackColor];
    indexDetailL.numberOfLines   = 2;
    indexDetailL.font            = [UIFont systemFontOfSize:14.0f];
    indexDetailL.text            = @"       经典、畅游、自由游览三种路线方案，您可根据自己的时间灵活、自由地选择专属路线。";
    [_scrollView addSubview:indexDetailL];
    
    img = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(indexDetailL.frame)+5, App_Frame_Width - 20, 540)];
    img.image = [UIImage imageNamed:@"load_one5.jpg"];
    [_scrollView addSubview:img];
    
    indexL                 = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(img.frame)+5, App_Frame_Width - 20, 20)];
    indexL.backgroundColor = [UIColor clearColor];
    indexL.textColor       = [UIColor blackColor];
    indexL.font            = [UIFont systemFontOfSize:16.0f];
    indexL.text            = @"6、周边美食";
    [_scrollView addSubview:indexL];
    
    indexDetailL                 = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(indexL.frame)+5, App_Frame_Width - 20, 35)];
    indexDetailL.backgroundColor = [UIColor clearColor];
    indexDetailL.textColor       = [UIColor blackColor];
    indexDetailL.numberOfLines   = 2;
    indexDetailL.font            = [UIFont systemFontOfSize:14.0f];
    indexDetailL.text            = @"       新增“周边美食”，为您推荐景区当地最赞的美食小吃，绝对是吃货们的福利。";
    [_scrollView addSubview:indexDetailL];
    
    img = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(indexDetailL.frame)+5, App_Frame_Width - 20, 540)];
    img.image = [UIImage imageNamed:@"load_one6.png"];
    [_scrollView addSubview:img];
    
    indexL                 = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(img.frame)+5, App_Frame_Width - 20, 20)];
    indexL.backgroundColor = [UIColor clearColor];
    indexL.textColor       = [UIColor blackColor];
    indexL.font            = [UIFont systemFontOfSize:16.0f];
    indexL.text            = @"7、周边酒店";
    [_scrollView addSubview:indexL];
    
    indexDetailL                 = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(indexL.frame)+5, App_Frame_Width - 20, 35)];
    indexDetailL.backgroundColor = [UIColor clearColor];
    indexDetailL.textColor       = [UIColor blackColor];
    indexDetailL.numberOfLines   = 2;
    indexDetailL.font            = [UIFont systemFontOfSize:14.0f];
    indexDetailL.text            = @"       “周边酒店”功能为您提供景区附近最优质的住所，让您愉快地游玩之后更能住的便捷、舒心。";
    [_scrollView addSubview:indexDetailL];
    
    img = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(indexDetailL.frame)+5, App_Frame_Width - 20, 540)];
    img.image = [UIImage imageNamed:@"load_one7.png"];
    [_scrollView addSubview:img];

    
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.frame),CGRectGetMaxY(img.frame) + 10);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
