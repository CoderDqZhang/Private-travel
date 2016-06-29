#import "BaseViewController.h"

@protocol PersonCenterViewDelegate <NSObject>

-(void)loginOut;

@end

@interface PersonCenterViewController : BaseViewController
{
    UIImageView *_image;
}

@property (nonatomic,retain) UITableView * pPersonTable;
@property (nonatomic,retain) UIView      * personInfoView;
@property (nonatomic,strong) id<PersonCenterViewDelegate> delegate;

- (void)willMove2Background;
- (void)willMove2Forground;

@end
