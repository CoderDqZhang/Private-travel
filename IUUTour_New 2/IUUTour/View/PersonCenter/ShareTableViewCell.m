#import "ShareTableViewCell.h"

@implementation ShareTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.timelbl = [[UILabel alloc]initWithFrame:CGRectMake(App_Frame_Width - 130, 5, 120, 30)];
        self.timelbl.font            = [UIFont systemFontOfSize:12];
        self.timelbl.backgroundColor = [UIColor clearColor];
        self.timelbl.textColor       = [UIColor grayColor];
        self.timelbl.textAlignment   = NSTextAlignmentRight;
        [self addSubview:self.timelbl];
        
        self.contlbl = [[UILabel alloc]initWithFrame:CGRectZero];
        self.contlbl.font            = [UIFont systemFontOfSize:13];
        self.contlbl.backgroundColor = [UIColor clearColor];
        self.contlbl.textColor       = [UIColor blackColor];
        self.contlbl.numberOfLines   = 2;
        [self addSubview:self.contlbl];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
