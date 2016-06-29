#import "BaseViewController.h"

@interface MoreViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView * _tableView;
    NSArray     * _cellNameArr;
    NSArray     * _cellImgArr;
    UIView      * bgView;
}


@end
