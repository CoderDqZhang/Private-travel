#import <UIKit/UIKit.h>
#import "ImageSpinner.h"

@interface CHTCollectionViewWaterfallCell : UICollectionViewCell
@property (nonatomic, retain) ImageSpinner *spinner;      //spinner
@property (nonatomic, retain) UIImageView *displayImg;      //背景图片
@property (nonatomic, retain) UIView      *infoView;        //信息背景
@property (nonatomic, retain) UIButton *alarmButton;        //景区预警按钮
//@property (nonatomic, retain) UIImageView *adNameImg;       //名称图片
@property (nonatomic, retain) UILabel     *adNamelbl;       //名称
@property (nonatomic, retain) UILabel     *distanceLabel;   //距离
@property (nonatomic, retain) UILabel     *levellbl;        //等级
@property (nonatomic, retain) UILabel     *levelCot;        //等级描述
@property (nonatomic, retain) UIButton    *loveBtn;         //点赞按钮
@property (nonatomic, retain) UILabel     *loveLbl;         //点赞
@property (nonatomic, retain) UIImageView *loveImg;         //点赞图标
@property (nonatomic, retain) UIImageView *lineImg;         //横线
@property (nonatomic, retain) UIImageView *lineSimg;        //竖线
- (void)creatLayer;

@end
