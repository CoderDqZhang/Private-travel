#import <UIKit/UIKit.h>
#import "ImageSpinner.h"

@interface FoodCell : UITableViewCell
@property (nonatomic,retain) ImageSpinner *spinner;
@property (nonatomic,retain) UIImageView * image;//图片
@property (nonatomic,retain) UIImageView * StarImg;//星级图片
@property (nonatomic,retain) UILabel     * titlelbl;//名称
@property (nonatomic,retain) UILabel     * pricelbl;//价格
@property (nonatomic,retain) UILabel     * scorelbl;//评分
@property (nonatomic,retain) UILabel     * addresslbl;//地点
@property (nonatomic,retain) UILabel     * distancelbl;//距离
@end
