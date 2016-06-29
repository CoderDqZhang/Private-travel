#import <UIKit/UIKit.h>

#import "ImageSpinner.h"

@interface WinnerListCellUserInfo : UIView

@property (nonatomic, strong) UILabel *userName;
@property (nonatomic, strong) UILabel *userLocation;

@end

@interface WinnerListCell : UITableViewCell

@property (nonatomic, strong) ImageSpinner           *spinner;
@property (nonatomic, strong) UIImageView            *profileImg;
@property (nonatomic, strong) WinnerListCellUserInfo *userInfo;
@property (nonatomic, strong) UILabel                *prizeName;

@end
