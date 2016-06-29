#import "FoodCell.h"

@implementation FoodCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.spinner = [[ImageSpinner alloc]initWithFrame:CGRectMake(10, 10, 70, 70)];
        [self addSubview:self.spinner];
        
        self.image                     = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 70, 70)];
        self.image.layer.cornerRadius  = 5;
        self.image.layer.masksToBounds = YES;
        [self addSubview:self.image];
        
        
        self.titlelbl = [[UILabel alloc] initWithFrame:CGRectMake(self.image.right + 10, 10, App_Frame_Width- self.image.width - 25, 20)];
        self.titlelbl.font            = [UIFont systemFontOfSize:15];
        self.titlelbl.textColor       = [UIColor lightTextColor];
        self.titlelbl.backgroundColor = [UIColor clearColor];
        self.titlelbl.textAlignment   = NSTextAlignmentLeft;
        [self addSubview:self.titlelbl];
        
        
        self.StarImg = [[UIImageView alloc]initWithFrame:CGRectMake(self.image.right + 10, self.titlelbl.bottom+10, 100, 15)];
        [self addSubview:self.StarImg];
        
        self.scorelbl = [[UILabel alloc] initWithFrame:CGRectMake(self.StarImg.right + 10, self.titlelbl.bottom+10, 40, 15)];
        self.scorelbl.font            = [UIFont systemFontOfSize:12];
        self.scorelbl.textColor       = [UIColor orangeColor];
        self.scorelbl.backgroundColor = [UIColor clearColor];
        self.scorelbl.textAlignment   = NSTextAlignmentLeft;
        [self addSubview:self.scorelbl];
        
        self.pricelbl = [[UILabel alloc] initWithFrame:CGRectMake(self.scorelbl.right + 10, self.titlelbl.bottom+10, 60, 15)];
        self.pricelbl.font            = [UIFont systemFontOfSize:12];
        self.pricelbl.textColor       = [UIColor lightTextColor];
        self.pricelbl.backgroundColor = [UIColor clearColor];
        self.pricelbl.textAlignment   = NSTextAlignmentLeft;
        [self addSubview:self.pricelbl];
        
        self.distancelbl = [[UILabel alloc] initWithFrame:CGRectMake(App_Frame_Width - 70, self.pricelbl.bottom+10, 60, 15)];
        self.distancelbl.font            = [UIFont systemFontOfSize:13];
        self.distancelbl.textColor       = [UIColor grayColor];
        self.distancelbl.backgroundColor = [UIColor clearColor];
        self.distancelbl.textAlignment   = NSTextAlignmentRight;
        [self addSubview:self.distancelbl];
        
        self.addresslbl = [[UILabel alloc] initWithFrame:CGRectMake(self.image.right + 10, self.StarImg.bottom+10, self.titlelbl.width-70, 15)];
        self.addresslbl.font            = [UIFont systemFontOfSize:12];
        self.addresslbl.textColor       = [UIColor grayColor];
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
