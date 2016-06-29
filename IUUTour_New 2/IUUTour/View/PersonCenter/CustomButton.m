//
//  CustomButton.m
//  IUUTour
//
//  Created by Zhang on 1/5/16.
//  Copyright © 2016 DevDiv Technology. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.layer.borderColor = [[UIColor colorWithRed:73/255 green:73/255 blue:74/255 alpha:1.0] CGColor];
        self.layer.borderColor = [[UIColor grayColor] CGColor];
        self.layer.borderWidth = 1.0;
        self.imageEdgeInsets = UIEdgeInsetsMake(34,40,51,30);
        self.titleLabel.font = [UIFont systemFontOfSize:12];//title字体大小
        self.titleLabel.textAlignment = NSTextAlignmentCenter;//设置title的字体居中
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:15.0];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
//        [self setTitleColor:[UIColor colorWithRed:130/255 green:130/255 blue:130/255 alpha:1.0] forState:UIControlStateNormal];//设置title在一般情况下为白色字体
        self.titleEdgeInsets = UIEdgeInsetsMake(56, -10, -22, 10);
    }
    return self;
}

@end
