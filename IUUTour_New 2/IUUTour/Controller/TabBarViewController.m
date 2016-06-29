#import "TabBarViewController.h"
#import "TabBarView.h"
#import "MainViewController.h"
#import "MessageCenterViewController.h"
#import "PersonCenterViewController.h"
#import "LoginViewController.h"

@interface TabBarViewController ()<UINavigationControllerDelegate>

@property (nonatomic,strong) NSMutableArray *tabControllers;
@property (nonatomic,strong) TabBarView     *tabBarView;

@end

@implementation TabBarViewController

- (id)init
{
    if (self = [super init])
    {
        _tabControllers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    
    MainViewController *mainVC      = [[MainViewController alloc] init];
    UINavigationController *mainNav = [[UINavigationController alloc] initWithRootViewController:mainVC];
    mainNav.navigationBarHidden     = YES;
    [_tabControllers addObject:mainNav];
    
    
    PersonCenterViewController *personCenterVC = [[PersonCenterViewController alloc] init];
    UINavigationController *personCenterNav    = [[UINavigationController alloc] initWithRootViewController:personCenterVC];
    personCenterNav.navigationBarHidden        = YES;
    [_tabControllers addObject:personCenterNav];

    __weak TabBarViewController *weakSelf = self;
    self.tabBarView = [TabBarView tabBarViewWithSelect:^(NSInteger index){
        __strong TabBarViewController *strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }
        
        if (index < strongSelf.tabControllers.count)
        {
            UINavigationController *vc0 = strongSelf.tabControllers[0];
            MainViewController *mainViewController = (MainViewController*)vc0.topViewController;
            
            
            UINavigationController *vc1 = strongSelf.tabControllers[1];
            PersonCenterViewController *personViewController = (PersonCenterViewController*)vc1.topViewController;

            if (index == 0)
            {
                if (mainViewController)
                {
                    [mainViewController willMove2Forground];
                }
                
                if (personViewController)
                {
                    [personViewController willMove2Background];
                }
                

                UINavigationController *vc1 = strongSelf.tabControllers[1];
                [vc1 removeFromParentViewController];
            }
            else if (index == 1)
            {
                if (mainViewController)
                {
                    [mainViewController willMove2Background];
                }
                

                if (personViewController)
                {
                    [personViewController willMove2Forground];
                }
 
                [vc0 removeFromParentViewController];
            }

            
            UINavigationController *vc = strongSelf.tabControllers[index];
            [strongSelf addChildViewController:vc];
            [strongSelf.view addSubview:vc.view];
            BaseViewController *baseVc = (BaseViewController *)vc.topViewController;
            [baseVc.view addSubview:strongSelf.tabBarView];
        }
    }];
    
    
    [self selectIndex:0];
}


-(void)selectIndex:(int)index
{
    self.tabBarView.selectIndexBlock(index);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
