//
//  LeftTableViewCell.m
//  IUUTour
//
//  Created by Zhang on 12/31/15.
//  Copyright © 2015 DevDiv Technology. All rights reserved.
//

#import "LeftTableViewCell.h"



@interface LeftTableViewCell()
{
    UIImageView *imageView;
    UILabel *nameString;
    UIImageView *rightImage;
    
    NSString *imageName;
    NSString *selectImageName;
    
    UILabel *numberMessage;
}

@end

@implementation LeftTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = LeftBackColor;
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(17, 9, 54, 54)];
        [self.contentView addSubview:imageView];
        
        nameString = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.size.width + imageView.frame.origin.x + 22, 29, 70, 14)];
        nameString.font = [UIFont systemFontOfSize:14.0f];
        nameString.textColor = [UIColor whiteColor];
        
        [self.contentView addSubview:nameString];
        
        rightImage = [[UIImageView alloc] initWithFrame:CGRectMake(250 - 32, 33.5, 17, 5)];
        [self.contentView addSubview:rightImage];
        
        numberMessage = [[UILabel alloc] initWithFrame:CGRectMake(250 - 32 - 12, 30, 17, 14)];
        numberMessage.font = [UIFont systemFontOfSize:12.0f];
        [numberMessage setTextColor:[UIColor redColor]];
        [self.contentView addSubview:numberMessage];
        
    }
    return self;
}

-(void)setDate:(NSString *)imagename selectImage:(NSString *)selectImage namestring:(NSString *)name rightImage:(NSString *)string select:(BOOL)selected
{
    imageName = imagename;
    selectImageName = selectImage;
    imageView.image = [UIImage imageNamed:imagename];
 
    if ([name isEqualToString:@"我的消息"]) {
        numberMessage.text = @"3";
    }
    nameString.text = name;
    rightImage.image = [UIImage imageNamed:string];
}

-(void)cellUpdate:(NSString *)selectImage
{
    imageView.image = [UIImage imageNamed:selectImage];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.backgroundColor = [UIColor clearColor];
    if (selected) {
        imageView.image = [UIImage imageNamed:selectImageName];
    }else
    {
        imageView.image = [UIImage imageNamed:imageName];
    }
}

@end
