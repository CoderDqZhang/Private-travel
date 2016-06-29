#import "BaseViewController.h"

@interface MyShareViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_shareListArr;
}
@property (nonatomic,retain) UITableView *tableView;

@end
