//
//  CusAnnotationView.h
//  MAMapKit_static_demo
//
//  Created by songjian on 13-10-16.
//  Copyright (c) 2013年 songjian. All rights reserved.
//
#import <AMapNaviKit/AMapNaviKit.h>


@interface CusAnnotationView : MAAnnotationView


@property (nonatomic, retain) UIImageView *userHeadImage;
@property (nonatomic, retain) UIImageView *backgroundImage;
@property (nonatomic, copy  ) NSString    *title4Focus;

@end
