#import "HotelCell.h"

@implementation HotelCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.spinner = [[ImageSpinner alloc]initWithFrame:CGRectMake(10, 10, 50, 50)];
        [self addSubview:self.spinner];
        
        self.image = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 50, 50)];
        self.image.layer.cornerRadius  = 5;
        self.image.layer.masksToBounds = YES;
        [self addSubview:self.image];
        
        
        self.titlelbl = [[UILabel alloc] initWithFrame:CGRectMake(self.image.right + 5, 10, App_Frame_Width- self.image.width - 25, 20)];
        self.titlelbl.font            = [UIFont systemFontOfSize:15];
        self.titlelbl.textColor       = [UIColor blackColor];
        self.titlelbl.backgroundColor = [UIColor clearColor];
        self.titlelbl.textAlignment   = NSTextAlignmentLeft;
        [self addSubview:self.titlelbl];
        
        
        self.StarImg = [[UIImageView alloc]initWithFrame:CGRectMake(self.image.right + 5, self.titlelbl.bottom, 100, 15)];
        [self addSubview:self.StarImg];
        
        self.distancelbl = [[UILabel alloc] initWithFrame:CGRectMake(self.StarImg.right + 5, self.titlelbl.bottom, 60, 15)];
        self.distancelbl.font            = [UIFont systemFontOfSize:13];
        self.distancelbl.textColor       = [UIColor blackColor];
        self.distancelbl.backgroundColor = [UIColor clearColor];
        self.distancelbl.textAlignment   = NSTextAlignmentRight;
        [self addSubview:self.distancelbl];
        
        self.pricelbl = [[UILabel alloc] initWithFrame:CGRectMake(App_Frame_Width - 70, self.titlelbl.bottom, 60, 15)];
        self.pricelbl.font            = [UIFont systemFontOfSize:15];
        self.pricelbl.textColor       = [UIColor redColor];
        self.pricelbl.backgroundColor = [UIColor clearColor];
        self.pricelbl.textAlignment   = NSTextAlignmentRight;
        [self addSubview:self.pricelbl];
        
        self.addresslbl = [[UILabel alloc] initWithFrame:CGRectMake(self.image.right + 5, self.StarImg.bottom, self.titlelbl.width, 15)];
        self.addresslbl.font            = [UIFont systemFontOfSize:12];
        self.addresslbl.textColor       = [UIColor blackColor];
        self.addresslbl.backgroundColor = [UIColor clearColor];
        self.addresslbl.textAlignment   = NSTextAlignmentLeft;
        [self addSubview:self.addresslbl];
        
        
    }
    return self;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
