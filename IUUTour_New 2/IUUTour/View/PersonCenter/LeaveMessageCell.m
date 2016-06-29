#import "LeaveMessageCell.h"

@implementation LeaveMessageCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.titlelbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 200, 30)];
        self.titlelbl.font                   = [UIFont systemFontOfSize:12];
        self.titlelbl.backgroundColor        = [UIColor clearColor];
        self.titlelbl.userInteractionEnabled = YES;
        [self addSubview:self.titlelbl];
        
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
        self.contlbl.numberOfLines   = 0;
        [self addSubview:self.contlbl];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
