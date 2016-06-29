#import "WinnerListCell.h"


@implementation WinnerListCellUserInfo

@end

@implementation WinnerListCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.spinner    = [[ImageSpinner alloc]initWithFrame:CGRectZero];
        [self addSubview:self.spinner];

        self.profileImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self addSubview:self.profileImg];

        self.userInfo   = [[WinnerListCellUserInfo alloc]initWithFrame:CGRectZero];
        self.userInfo.userName = [[UILabel alloc]initWithFrame:CGRectZero];
        self.userInfo.userName .font    = [UIFont systemFontOfSize:15];
        [self.userInfo addSubview:self.userInfo.userName];
        self.userInfo.userLocation      = [[UILabel alloc]initWithFrame:CGRectZero];
        self.userInfo.userLocation.font = [UIFont systemFontOfSize:12];
        [self.userInfo addSubview:self.userInfo.userLocation];
        [self addSubview:self.userInfo];

        self.prizeName      = [[UILabel alloc] initWithFrame:CGRectZero];
        self.prizeName.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.prizeName];
    }
    
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
