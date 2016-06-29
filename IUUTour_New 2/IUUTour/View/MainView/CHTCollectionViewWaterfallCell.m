#import "CHTCollectionViewWaterfallCell.h"
#import "ImageSpinner.h"

@implementation CHTCollectionViewWaterfallCell

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
    {
        self.spinner = [[ImageSpinner alloc]initWithFrame:CGRectZero];
        [self addSubview:self.spinner];
        
        self.displayImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.displayImg.backgroundColor = [UIColor grayColor];
        [self addSubview:self.displayImg];
        
        self.infoView = [[UIView alloc]initWithFrame:CGRectZero];
        self.infoView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.infoView];
       
        self.adNamelbl = [[UILabel alloc]initWithFrame:CGRectZero];
        self.adNamelbl.textAlignment = NSTextAlignmentLeft;
        self.adNamelbl.backgroundColor = [UIColor clearColor];
        self.adNamelbl.textColor = [UIColor blackColor];
        self.adNamelbl.font = [UIFont systemFontOfSize:17];
        [self.infoView addSubview:self.adNamelbl];
        
//        self.adNameImg = [[UIImageView alloc]initWithFrame:CGRectZero];
//        [self.infoView addSubview:self.adNameImg];
        self.alarmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.infoView addSubview:self.alarmButton];
        
        self.levellbl = [[UILabel alloc]initWithFrame:CGRectZero];
        self.levellbl.textAlignment = NSTextAlignmentCenter;
        self.levellbl.backgroundColor = [UIColor clearColor];
        self.levellbl.textColor = [UIColor redColor];
        self.levellbl.font = [UIFont systemFontOfSize:13];
        [self.infoView addSubview:self.levellbl];
        
        self.levelCot = [[UILabel alloc]initWithFrame:CGRectZero];
        self.levelCot.textAlignment = NSTextAlignmentLeft;
        self.levelCot.backgroundColor = [UIColor clearColor];
        self.levelCot.textColor = [UIColor blackColor];
        self.levelCot.font = [UIFont systemFontOfSize:13];
        [self.infoView addSubview:self.levelCot];
        
        
        self.loveBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [self.infoView addSubview:self.loveBtn];
        
        self.loveImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self.infoView addSubview:self.loveImg];
        
        self.loveLbl = [[UILabel alloc]initWithFrame:CGRectZero];
        self.loveLbl.textAlignment = NSTextAlignmentCenter;
        self.loveLbl.backgroundColor = [UIColor clearColor];
        self.loveLbl.textColor = [UIColor grayColor];
        self.loveLbl.font = [UIFont systemFontOfSize:13];
        [self.infoView addSubview:self.loveLbl];
//        self.imgMap = [[UIImageView alloc]initWithFrame:CGRectMake(self.titleLabel.right, 5, 20, 20)];
//        self.imgMap.image = [UIImage imageNamed:@"8.png"];
//        [self.infoView addSubview:self.imgMap];
//        
        self.distanceLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        self.distanceLabel.textAlignment = NSTextAlignmentLeft;
        self.distanceLabel.backgroundColor = [UIColor clearColor];
        self.distanceLabel.textColor = [UIColor grayColor];
        self.distanceLabel.font = [UIFont systemFontOfSize:13];
        [self.infoView addSubview:self.distanceLabel];
        
        
        self.lineImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.lineImg.image = [[UIColor grayColor] image];
        [self addSubview:self.lineImg];
        
        self.lineSimg = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.lineSimg.image = [[UIColor grayColor] image];
        [self addSubview:self.lineSimg];
		
	}
	return self;
}
- (void)creatLayer
{
    CALayer * layer = [CALayer layer];
    layer.frame = CGRectMake(0, self.infoView.bottom-1, self.infoView.width, 1);
    layer.backgroundColor = [UIColor blackColor].CGColor;
    [self.infoView.layer addSublayer:layer];
}
@end
