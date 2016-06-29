#import "MapManageCell.h"

@implementation MapManageCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.image = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 70, 70)];
        self.image.layer.cornerRadius = 3;
        self.image.layer.masksToBounds = YES;
        [self addSubview:self.image];
        
        self.title = [[UILabel alloc]initWithFrame:CGRectMake(self.image.right +5, 10, self.width - 10 - self.image.right, 30)];
        self.title.font            = [UIFont systemFontOfSize:15];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.textAlignment   = NSTextAlignmentLeft;
        self.title.textColor       = [UIColor blackColor];
        [self addSubview:self.title];
        
        
        self.sizelbl = [[UILabel alloc]initWithFrame:CGRectMake(self.image.right + 5, self.title.bottom, 200, 20)];
        self.sizelbl.font            = [UIFont systemFontOfSize:12];
        self.sizelbl.backgroundColor = [UIColor clearColor];
        self.sizelbl.textAlignment   = NSTextAlignmentLeft;
        self.sizelbl.textColor       = [UIColor blackColor];
        [self addSubview:self.sizelbl];
        
        
        self.timelbl = [[UILabel alloc]initWithFrame:CGRectMake(self.image.right + 5, self.sizelbl.bottom, 200, 20)];
        self.timelbl.font            = [UIFont systemFontOfSize:12];
        self.timelbl.backgroundColor = [UIColor clearColor];
        self.timelbl.textAlignment   = NSTextAlignmentLeft;
        self.timelbl.textColor       = [UIColor blackColor];
        [self addSubview:self.timelbl];
        

        self.update = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [self.update.layer setCornerRadius:3];
        [self.update.layer setMasksToBounds:YES];
        [self.update.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [self.update setFrame:CGRectMake(App_Frame_Width - 10 - 50, self.title.bottom - 5, 50, 25)];
        [self.update setBackgroundColor:FontColorA];
        [self.update setTitle:@"更新地图" forState:(UIControlStateNormal)];
        [self.update setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [self.update setHidden:YES];
        [self addSubview:self.update];
        
        
//        self.progress = [[UIProgressView alloc]initWithProgressViewStyle:(UIProgressViewStyleBar)];
//        self.progress.progressTintColor = [UIColor redColor];
//        self.progress.trackTintColor    = [UIColor grayColor];
//        self.progress.hidden = YES;
//        [self addSubview:self.progress];
//        
//        
//        
//        self.stop = [UIButton buttonWithType:(UIButtonTypeCustom)];
//        [self.stop.layer setCornerRadius:3];
//        [self.stop.layer setMasksToBounds:YES];
//        [self.stop.titleLabel setFont:[UIFont systemFontOfSize:10]];
//        [self.stop setTitle:@"停止更新" forState:(UIControlStateNormal)];
//        [self.stop setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
//        [self.stop setHidden:YES];
//        [self addSubview:self.stop];
        
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
