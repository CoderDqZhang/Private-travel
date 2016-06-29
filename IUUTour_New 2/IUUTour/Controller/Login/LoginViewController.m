#import "LoginViewController.h"
#import "PhoneLoginViewController.h"
#import "UMSocialSnsPlatformManager.h"
#import "UMSocialAccountManager.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    UIImageView * imageBackground = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, App_Frame_Width, App_Frame_Height+20)];
    [imageBackground setImage:[UIImage imageNamed:@"sign_bg.png"]];
    [_defaultView addSubview:imageBackground];
    
    UIImageView * iconImg = [[UIImageView alloc]initWithFrame:CGRectMake(App_Frame_Width/2 - 51, 100, 102, 102)];
    iconImg.image = [UIImage imageNamed:@"sign_logo.png"];
    [_defaultView addSubview:iconImg];
    
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(iconImg.frame) + 10, App_Frame_Width, 20.0f)];
    [titleL setBackgroundColor:[UIColor clearColor]];
    [titleL setFont:[UIFont systemFontOfSize:18.0f]];
    [titleL setTextColor:[UIColor whiteColor]];
    titleL.text = @"IUU旅行";
    [titleL setTextAlignment:NSTextAlignmentCenter];
    [_defaultView addSubview:titleL];
    
    [self initWithXBtnLogin];
    
    
    NSArray *titleArr   = [[NSArray alloc]initWithObjects:@"手机号登录",@"微信登录",@"新浪微博登录",@"QQ账号登录", nil];
    NSArray *norIConArr = [[NSArray alloc]initWithObjects:@"sign_phoneNor.png",@"sign_weChatNor.png",@"sign_sinaNor.png",@"sign_qqNor.png", nil];
    NSArray *selIConArr = [[NSArray alloc]initWithObjects:@"sign_phoneSel.png",@"sign_weChatSel.png",@"sign_sinaSel.png",@"sign_qqSel.png", nil];
    for (int i = 0; i < 4; i++)
    {
        UIButton *loginBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [loginBtn setFrame: CGRectMake(10, (imageBackground.height -210) + i * 40 , App_Frame_Width - 20, 30)];
        [loginBtn setBackgroundColor:[UIColor whiteColor]];
        [loginBtn setImage:[UIImage imageNamed:norIConArr[i]] forState:(UIControlStateNormal)];
        [loginBtn setImage:[UIImage imageNamed:selIConArr[i]] forState:(UIControlStateHighlighted)];
        [loginBtn setTag:i];
        [loginBtn setTitleColor:FontColorA forState:(UIControlStateNormal)];
        [loginBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateHighlighted)];
        [loginBtn setTitle:titleArr[i] forState:(UIControlStateNormal)];
        [loginBtn.layer setCornerRadius:15];
        [loginBtn.layer setMasksToBounds:YES];
        [loginBtn setBackgroundImage:[UIColor whiteColor].image forState:UIControlStateNormal];
        [loginBtn setBackgroundImage:FontColorA.image forState:UIControlStateHighlighted];
        [loginBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [loginBtn addTarget:self action:@selector(loginAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [self->_defaultView addSubview:loginBtn];
        
        if (i != 0)
        {
            RAC(loginBtn, hidden) = [RACObserve(APP_DELEGATE, appPublished) map:^id(NSNumber *published) {
                if ([published boolValue])
                {
                    return @NO;
                }
                else
                {
                    return @YES;
                }
            }];
        }
    }
}

-(void)sendAuthRequest
{
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        if (response.responseCode == UMSResponseCodeSuccess)
        {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary]valueForKey:UMShareToWechatSession];
            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            
            
            [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToWechatSession  completion:^(UMSocialResponseEntity *response){
                NSLog(@"SnsInformation is %@",response.data);
                UMSocialCustomAccount *customAccount = [[UMSocialCustomAccount alloc] initWithUserName:snsAccount.userName];
                [UMSocialAccountManager postCustomAccount:customAccount completion:^(UMSocialResponseEntity *response){ NSLog(@" login user is %@",response); }];
                
                User *user     = [User sharedInstance] ;
                user.userid    = snsAccount.usid ;
                user.loginName = snsAccount.userName;
                user.nickname  = snsAccount.userName;
                user.userpic   = snsAccount.iconURL;
                if ([response.data[@"gender"] integerValue] == 1)
                {
                    user.sex = @"男";
                }
                else
                {
                    user.sex = @"女";
                }
                
                user.address = response.data[@"location"];
                
                [User synchronize];
                [self regist:snsAccount withType:UMShareToWechatSession];
            }];
            [self dismissVC];
        }
    });
}

-(void)sendSinaAuth
{
    NSString *platformName = [UMSocialSnsPlatformManager getSnsPlatformString:UMSocialSnsTypeSina];
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        NSLog(@"login response is %@",response);
    
        
        if (response.responseCode == UMSResponseCodeSuccess)
        {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:platformName];
            User *user     = [User sharedInstance] ;
            user.userid    = snsAccount.usid;
            user.loginName = snsAccount.userName;
            user.nickname  = snsAccount.userName;
            user.userpic   = snsAccount.iconURL;
            [User synchronize];
            
            [self regist:snsAccount withType:UMShareToSina];
            [self dismissVC];
        }
    });
}

-(void)sendQQAuth
{
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
       
        NSLog(@"login response is %@",response.data);
        
        if (response.responseCode == UMSResponseCodeSuccess)
        {
           
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
            User *user     = [User sharedInstance] ;
            user.userid    = snsAccount.usid ;
            user.loginName = snsAccount.userName;
            user.nickname  = snsAccount.userName;
            user.userpic   = snsAccount.iconURL;
            [User synchronize];
            
            if (snsAccount.isFirstOauth)
            {
                [self regist:snsAccount withType:UMShareToQQ];
            }
            else
            {
                [Interface loginAction:[User sharedInstance].userid passWard:@"" loginName:snsAccount.userName ssoaccount:@"3" result:^(LoginResponse *response, NSError *error) {
                    
                }];
            }
            [self dismissVC];
        }
        
    });
}


- (void)regist:(UMSocialAccountEntity *)snsAccount  withType:(NSString *)type
{
    [Interface  registerAction:@"" passwd:@"000000" loginName:snsAccount.usid nickName:[User sharedInstance].nickname sex:[User sharedInstance].sex address:[User sharedInstance].address ssoSource:@"3" ssoAccount:snsAccount.userName result:^(CommonActionStatus *response, NSError *err) {
        NSLog(@"%@",response);
    }];
}

#pragma mark - button action 
- (void)loginAction:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedInFromPhone) name:@"LoggedInFromPhone" object:nil];
    switch (sender.tag)
    {
        case 0:
        {
            PhoneLoginViewController *vc = [[PhoneLoginViewController alloc]init];
            UINavigationController *phoneLoginNav = [[UINavigationController alloc] initWithRootViewController:vc];
            phoneLoginNav.navigationBarHidden = YES;
            [self presentViewController:phoneLoginNav animated:YES completion:^{
                
            }];
        }
            break;
            case 1:
        {
            [self sendAuthRequest];
        }
            break;
         case 2:
        {
            [self sendSinaAuth];
        }
            break;
        case 3:
        {
            [self sendQQAuth];
        }
            break;
        default:
            break;
    }
}

- (void)loggedInFromPhone
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"LoggedInFromLoginViewController" object:nil];
    }];
}


- (void)dismissVC
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)initWithXBtnLogin
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(_defaultView.width -  44, 30.0f, 40.0f, 40.0f)];
    [backBtn setImage:[UIImage imageNamed:@"cancel_white.png"] forState:UIControlStateNormal];
    [backBtn setBackgroundColor:[UIColor clearColor]];
    [backBtn setContentMode:UIViewContentModeCenter];
    [backBtn addTarget:self action:@selector(XPressLogin) forControlEvents:UIControlEventTouchUpInside];
    [_defaultView addSubview:backBtn];
}

-(void)XPressLogin
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
