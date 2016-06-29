//
//  LeftViewController.m
//  IUUTour
//
//  Created by Zhang on 12/31/15.
//  Copyright © 2015 DevDiv Technology. All rights reserved.
//

#import "LeftViewController.h"
#import "LeftView.h"
#import "MFSideMenu.h"
#import "User.h"
#import "LoginViewController.h"
#import "PersonCenterViewController.h"
#import "MessageCenterViewController.h"
#import "SetViewController.h"
#import "MainViewController.h"

@interface LeftViewController ()<leftTableDelegate,PersonCenterViewDelegate>


@property (nonatomic, strong) NSArray *leftArray;
@property (nonatomic, strong) NSArray *leftImageArray;
@property (nonatomic, strong) NSArray *selectLeftImageArray;

@property (nonatomic, strong) LeftView *leftView;
@property (nonatomic, strong) User *user;


@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = LeftBackColor;
    
        // Do any additional setup after loading the view.
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![User isLoggedIn]) {
        [self setupLoginBt];
    }else{
        _user = [User sharedInstance];
        [self setUpArray];
        [self.view addSubview:[self createTableView]];
 
    }
}

-(void)setUpArray
{
    self.leftArray = @[@"首页",@"个人中心",@"我的消息",@"设置",@"帮助中心"];
    self.leftImageArray = @[@"home_unpressed",@"user_unpressed",@"mass_unpressed",@"set_unpressed",@"help_unpressed"];
    self.selectLeftImageArray = @[@"home_pressed",@"user_pressed",@"mass_pressed",@"set_pressed",@"help_pressed"];
}

-(void)loginOut
{
    if (_leftView != nil) {
        _leftView.hidden = YES;
    }
    [self setupLoginBt];
}

-(UIView *)createTableView
{
    _leftView = [[LeftView alloc] initWithFrame:CGRectMake(0, 0, 250, APP_Screen_Height)];
    
    _leftView.nameArray = [self.leftArray copy];
    _leftView.leftImageArray = [self.leftImageArray copy];
    _leftView.selectImageArray = [self.selectLeftImageArray copy];
    _leftView.delegate = self;
    [_leftView.mainTable reloadData];
    return _leftView;
}

-(void)setupLoginBt
{
    UIButton *login = [UIButton buttonWithType:UIButtonTypeCustom];
    [login setTitle:@"登录" forState:UIControlStateNormal];
    [login setFrame:CGRectMake(0, 100, 250, 40)];
    [login addTarget:self action:@selector(loginBtPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:login];
}

-(void)loginBtPress:(UIButton *)sender
{
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    [self presentViewController:[[LoginViewController alloc] init] animated:YES completion:nil];
}

-(void)tableViewSelect:(NSIndexPath *)indexPath
{
     [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    
    if (indexPath.row == 0 ) {
        BaseNavigationController *baseNav = [[BaseNavigationController alloc] initWithRootViewController:[[MainViewController alloc]init]];
        self.menuContainerViewController.centerViewController = baseNav;
    }else if (indexPath.row == 1){
        PersonCenterViewController *controller = [[PersonCenterViewController alloc]init];
        controller.delegate = self;
        BaseNavigationController *baseNav = [[BaseNavigationController alloc] initWithRootViewController:controller];
        
        self.menuContainerViewController.centerViewController = baseNav;
    }else if (indexPath.row == 2){
        BaseNavigationController *baseNav = [[BaseNavigationController alloc] initWithRootViewController:[[MessageCenterViewController alloc]init]];
        self.menuContainerViewController.centerViewController = baseNav;
    }else if (indexPath.row == 3){
         BaseNavigationController *baseNav = [[BaseNavigationController alloc] initWithRootViewController:[[SetViewController alloc]init]];
        self.menuContainerViewController.centerViewController = baseNav;
    }else if (indexPath.row == 4){
        BaseNavigationController *baseNav = [[BaseNavigationController alloc] initWithRootViewController:[[SetViewController alloc]init]];
        self.menuContainerViewController.centerViewController = baseNav;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
