#import "MoreViewController.h"
#import "AboutViewController.h"
#import "FeedBackViewController.h"
#import "WebViewController.h"
#import "QuestionViewController.h"
#import "EventConsumingBgView.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleView.hidden = NO;
    [self initWithBackBtn];
    
    _cellNameArr = @[@"关于IUU",@"到App Store给IUU打分或评论",@"意见反馈",@"常见问题",@"功能介绍",@"客服电话",@"软件许可与服务协议"];
    _cellImgArr  = @[@"about0.png",@"about1.png",@"about2.png",@"about3.png",@"about4.png",@"about5.png",@"about6.png"];

    _tableView   = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, App_Frame_Width, CGRectGetHeight(_defaultView.frame)-60)];
    _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource      = self;
    _tableView.delegate        = self;
    [_defaultView addSubview:_tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)initWithXBtnAbout
{
    UIButton *xBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [xBtn setFrame:CGRectMake(_defaultView.width -  44, 30.0f, 16.0f, 16.0f)];
    [xBtn setBackgroundImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
    [xBtn addTarget:self action:@selector(XPressAbout) forControlEvents:UIControlEventTouchUpInside];
    [_defaultView addSubview:xBtn];
}

-(void)XPressAbout
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cellNameArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identfire = @"PersonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identfire];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identfire];
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    
    UIImageView *cellImg = [[UIImageView alloc] init];
    cellImg.frame = CGRectMake(10, 11.5, 20, 21);
    cellImg.image = [UIImage imageNamed:_cellImgArr[indexPath.row]];
    [cell.contentView addSubview:cellImg];
    
    UILabel *cellNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 4, 200, 36)];
    cellNameLabel.backgroundColor = [UIColor clearColor];
    cellNameLabel.font = [UIFont systemFontOfSize:14.0f];
    [cell.contentView addSubview:cellNameLabel];
    if (indexPath.row == 5)
    {
        UILabel *servicePhone        = [[UILabel alloc] initWithFrame:CGRectMake(App_Frame_Width-110, 4, 100, 36)];
        servicePhone.textColor       = [UIColor colorWithRed:20/255. green:140/255. blue:203/255. alpha:1];
        servicePhone.backgroundColor = [UIColor clearColor];
        servicePhone.font            = [UIFont systemFontOfSize:14.0f];
        [cell.contentView addSubview:servicePhone];
        servicePhone.text =@"4000396868";
    }
    cellNameLabel.text = _cellNameArr[indexPath.row];
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(40, 43.5, App_Frame_Width-40, 0.5)];
    line.backgroundColor = [UIColor grayColor];
    [cell.contentView addSubview:line];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *filename ;
    if (indexPath.row == 4)
    {
        filename = @"function.plist";
    }

    switch (indexPath.row)
    {
        case 0: //关于我们
        {
            AboutViewController *vc = [[AboutViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1://评论
        {
            NSString *url = @"https://itunes.apple.com/cn/app/iuu-lu-xing/id955692460?mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
            break;
        case 2://意见反馈
        {
            FeedBackViewController *vc = [[FeedBackViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3://常见问题
        {
            NSString *mainBundleDirectory = [[NSBundle mainBundle] bundlePath];
            NSString *fileName = [NSString stringWithFormat:@"question.html"];
            NSString *localPath = [mainBundleDirectory stringByAppendingPathComponent:fileName];
            WebViewController *vc = [[WebViewController alloc] init];
            vc.titles = @"常见问题";
            vc.loadLocalHtmlPath = localPath;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 4://功能介绍
        {
            QuestionViewController *vc = [[QuestionViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
          
        }
            break;
        case 5://客服电话
        {
            [self telServicePhoneAction];
        }
            break;
        case 6://软件许可与服务协议
        {
            NSString *mainBundleDirectory = [[NSBundle mainBundle] bundlePath];
            NSString *fileName = [NSString stringWithFormat:@"agreement.html"];
            NSString *localPath = [mainBundleDirectory stringByAppendingPathComponent:fileName];
            WebViewController *vc = [[WebViewController alloc] init];
            vc.titles = @"软件许可与服务协议";
            vc.loadLocalHtmlPath = localPath;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}


- (void)telServicePhoneAction
{
    //self.view is the root view of rootViewController
    bgView                 = [[EventConsumingBgView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, App_Frame_Height)];
    bgView.backgroundColor = [UIColor lightGrayColor];
    bgView.alpha           = .6f;
    [self.view addSubview:bgView];
    

    UIView *telView = [[UIView alloc] initWithFrame: CGRectMake(0, App_Frame_Height - 160, App_Frame_Width,160)];
    telView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:telView];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, App_Frame_Width, 20)];
    lblTitle.text = @"您确定要拨打客服电话";
    [telView addSubview:lblTitle];
    lblTitle.font = [UIFont systemFontOfSize:14];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    
    UILabel *lblPhone = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lblTitle.frame)+5, App_Frame_Width, 20)];
    lblPhone.text = @"4000396868";
    lblPhone.font = [UIFont systemFontOfSize:22];
    [telView addSubview:lblPhone];
    lblPhone.textAlignment = NSTextAlignmentCenter;
    
    UIButton *callBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(lblPhone.frame)+10, App_Frame_Width-20*2, 50)];
    
    [callBtn setTitle:@"立即拨打" forState:UIControlStateNormal];
    [callBtn addTarget:self action:@selector(telPhone) forControlEvents:UIControlEventTouchUpInside];
    [telView addSubview:callBtn];
    [callBtn.layer setCornerRadius:15.0];
    [callBtn setBackgroundColor:ButtonColorA];
    [callBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIButton *cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(callBtn.frame)+5, App_Frame_Width-20*2, 50)];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [telView addSubview:cancleBtn];
    [cancleBtn addTarget:self action:@selector(canclePhone:) forControlEvents:UIControlEventTouchUpInside];
    [cancleBtn setBackgroundColor:[UIColor whiteColor]];
    
    [cancleBtn.layer setMasksToBounds:YES];
    [cancleBtn.layer setBorderColor:[UIColor colorWithRed:226/255. green:226/255. blue:226/255. alpha:1].CGColor];//边框颜色
    [cancleBtn.layer setCornerRadius:15.0]; //设置矩形四个圆角半径
    [cancleBtn.layer setBorderWidth:1.0]; //边框宽度
    [cancleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}


- (void)telPhone
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://4000396868"]]];
}

- (void)canclePhone:(UIButton *)sender
{
    UIView *supV = (UIView *)[sender superview];
    [supV removeFromSuperview];
    [bgView removeFromSuperview];
}

@end
