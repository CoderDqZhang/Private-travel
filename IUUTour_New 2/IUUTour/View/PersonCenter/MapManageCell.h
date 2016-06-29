#import <UIKit/UIKit.h>

@interface MapManageCell : UITableViewCell
@property (nonatomic,retain) UIImageView    * image;//图片
@property (nonatomic,retain) UILabel        * title;//标题
@property (nonatomic,retain) UILabel        * sizelbl;//文件大小
@property (nonatomic,retain) UILabel        * timelbl;//下载时间
@property (nonatomic,retain) UIButton       * update;//更新按钮
@property (nonatomic,retain) UIButton       * stop;//停止按钮
@property (nonatomic,retain) UIProgressView * progress;//进度条
@end
