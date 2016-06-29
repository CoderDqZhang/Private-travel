//
//  SceneryTableViewCell.m
//  IUUTour
//
//  Created by Zhang on 1/1/16.
//  Copyright © 2016 DevDiv Technology. All rights reserved.
//

#import "SceneryTableViewCell.h"
#import "UIImage+UIColor.h"
#import "RatingBar.h"

@interface SceneryTableViewCell()<RatingBarDelegate>
{
    UIImageView *imageView;
    UIImageView *activeImage;
    UILabel *nameLable;
    UILabel *sceneryDetail;
    UILabel *gradeView;
    UILabel *muchOld;
    UILabel *muchNow;
    RatingBar *ratingBar;
    
    UILabel *ratingLabel;
    
    UIImageView *locationView;
    
    
}

@end

@implementation SceneryTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 197)];
        [self.contentView addSubview:imageView];
        
        activeImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 23, 70, 40)];
        [self.contentView addSubview:activeImage];
        
        nameLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 69, App_Frame_Width, 23)];
        nameLable.textAlignment = NSTextAlignmentCenter;
        nameLable.textColor = [UIColor whiteColor];
        nameLable.font = [UIFont systemFontOfSize:23.0];
        [self.contentView addSubview:nameLable];
        
        
        locationView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location"]];
        [self.contentView addSubview:locationView];
        
        sceneryDetail = [[UILabel alloc] initWithFrame:CGRectMake(0, nameLable.frame.size.height + nameLable.frame.origin.y + 10, App_Frame_Width, 13)];
        sceneryDetail.textAlignment = NSTextAlignmentCenter;
        sceneryDetail.textColor = [UIColor whiteColor];
        sceneryDetail.font = [UIFont systemFontOfSize:13.0];
        [self.contentView addSubview:sceneryDetail];
        
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 197 - 47, App_Frame_Width, 47)];
        bottomView.backgroundColor = [UIColor colorWithRed:109.0/255 green:110.0/255.0 blue:110.0/255.0 alpha:0.7];
        
        ratingBar = [[RatingBar alloc] init];
        ratingBar.frame = CGRectMake(12, 17, 220, 20);
        ratingBar.isIndicator = YES;
        [ratingBar setImageDeselected:@"un-star.png" halfSelected:nil fullSelected:@"star.png" andDelegate:self];
//        ratingBar.backgroundColor = [UIColor redColor];
        
        [bottomView addSubview:ratingBar];
        
        ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(ratingBar.frame.size.width + ratingBar.frame.origin.x + 25, 17, 60, 12)];
        ratingLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:228/255.0 blue:48/255.0 alpha:1.0];
        ratingLabel.font = [UIFont systemFontOfSize:12.0f];
        [bottomView addSubview:ratingLabel];
        
        
        muchOld = [[UILabel alloc] initWithFrame:CGRectMake(App_Frame_Width - 50, 25, 60, 11)];
        muchOld.textColor = [UIColor colorWithRed:232.0/255.0 green:171/255.0 blue:28/255.0 alpha:1.0];
        muchOld.font = [UIFont systemFontOfSize:11.0f];
        [bottomView addSubview:muchOld];
        
        
        muchNow = [[UILabel alloc] initWithFrame:CGRectMake(App_Frame_Width - 120, 15, 70, 19)];
        muchNow.font = [UIFont systemFontOfSize:19.0];
        muchNow.textColor = [UIColor colorWithRed:232.0/255.0 green:171/255.0 blue:28/255.0 alpha:1.0];
        [bottomView addSubview:muchNow];
        
        [self.contentView addSubview:bottomView];
        
    }
    return self;
}

-(void)setData:(ScenicArea *)model
{
    [imageView sd_setImageWithURL:[NSURL URLWithString:model.smallImage] placeholderImage:[UIImage imageNamed:@"placeholder_common"]options:SDWebImageProgressiveDownload | SDWebImageRetryFailed];
    nameLable.text = model.scenicName;
    CGSize size4 = [[LabelSize labelsizeManger] getStringRect:[NSString stringWithFormat:@"%@",nameLable.text] MaxSize:CGSizeMake(App_Frame_Width-23, 30) FontSize:23];
    locationView.frame = CGRectMake((App_Frame_Width - size4.width)/2-23, 69, 23, 23);
    
    if (model.discountActivity == [NSString stringWithFormat:@"%@",model.discountActivity]) {
        activeImage.image = [UIImage imageNamed:@"active"];
    }
    sceneryDetail.text = model.scenicType;
    muchOld.text = [NSString stringWithFormat:@"%@元",model.originPrice];
    muchNow.text = [NSString stringWithFormat:@"%@元/人",model.price];
    ratingLabel.text = [NSString stringWithFormat:@"%@分",model.favourNum];
    [ratingBar displayRating:[model.favourNum intValue]/2];
    
}

- (void)ratingChanged:(float)newRating
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
