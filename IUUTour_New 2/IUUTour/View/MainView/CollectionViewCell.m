//
//  CollectionViewCell.m
//  IUUTour
//
//  Created by Zhang on 1/1/16.
//  Copyright © 2016 DevDiv Technology. All rights reserved.
//

#import "CollectionViewCell.h"
#import "LabelSize.h"

@interface CollectionViewCell()
{
    UIImageView *sceneryImage;
    UIImageView *activeImage;
    UILabel *sceneryName;
    UILabel *muchNow;
    UILabel *muchOld;
    UILabel *distanceLable;
}

@end


@implementation CollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        sceneryImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 100)];
        [self.contentView addSubview:sceneryImage];
        
        activeImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 12, 70, 40)];
        [self.contentView addSubview:activeImage];
        
        sceneryName = [[UILabel alloc] initWithFrame:CGRectMake(10, sceneryImage.frame.size.height + 8.5, self.frame.size.width, 13)];
        sceneryName.textColor = CollectionCellFont1;
        sceneryName.font = [UIFont systemFontOfSize:13.0f];
        [self.contentView addSubview:sceneryName];
        
        muchNow = [[UILabel alloc] initWithFrame:CGRectMake(10, sceneryName.frame.size.height + sceneryName.frame.origin.y + 10, 100, 14)];
        muchNow.textColor = CollectionCellFont;
        muchNow.font = [UIFont systemFontOfSize:14.0];
        [self.contentView addSubview:muchNow];
        
        muchOld = [[UILabel alloc] initWithFrame:CGRectMake(70, sceneryName.frame.size.height + sceneryName.frame.origin.y + 15, 100, 11)];
        muchOld.textColor = CollectionCellFont;
        muchOld.font = [UIFont systemFontOfSize:12.0];
        [self.contentView addSubview:muchOld];
        
        
        
        distanceLable = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 100, sceneryName.frame.size.height + sceneryName.frame.origin.y + 15, 90, 9)];
        distanceLable.textAlignment = NSTextAlignmentRight;
        distanceLable.textColor = [UIColor whiteColor];
        distanceLable.font = [UIFont systemFontOfSize:12.0];
        [self.contentView addSubview:distanceLable];
        
    }
    return self;
}

-(void)setData:(ScenicArea *)model distance:(NSString *)distance
{
    [sceneryImage sd_setImageWithURL:[NSURL URLWithString:model.smallImage] placeholderImage:[UIImage imageNamed:@"placeholder_common"]options:SDWebImageProgressiveDownload | SDWebImageRetryFailed];
    sceneryName.text = model.scenicName;
    if (model.discountActivity == [NSString stringWithFormat:@"%@",model.discountActivity]) {
        activeImage.image = [UIImage imageNamed:@"active"];
    }
    muchOld.text = [NSString stringWithFormat:@"%@元",model.originPrice];
    muchNow.text = [NSString stringWithFormat:@"%@元",model.price];
    if ([distance isEqualToString:@"未知"]) {
        CGSize size4 = [[LabelSize labelsizeManger] getStringRect:[NSString stringWithFormat:@"%dkm",[distance intValue] / 1000] MaxSize:CGSizeMake(200, 30) FontSize:13];
        [distanceLable setFrame:CGRectMake(self.frame.size.width - size4.width,sceneryName.frame.size.height + sceneryName.frame.origin.y + 15, size4.width, size4.height)];
        [distanceLable setText:[NSString stringWithFormat:@"%dkm",[distance intValue] / 1000]];
    }
    
    
}

@end
