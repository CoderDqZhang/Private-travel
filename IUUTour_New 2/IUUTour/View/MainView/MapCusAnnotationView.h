//
//  CusAnnotationView.h
//  MAMapKit_static_demo
//
//  Created by songjian on 13-10-16.
//  Copyright (c) 2013年 songjian. All rights reserved.
//
#import <AMapNaviKit/AMapNaviKit.h>


@interface MapCusAnnotationView : MAAnnotationView

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) UIImage *portrait;

@property (nonatomic, strong) UIView *calloutView;

@property (nonatomic, strong) UILabel *nameText;

@property (nonatomic, strong) UIButton    *closeBtn;
@property (nonatomic, strong) UIButton    *voiceBtn;
@property (nonatomic, strong) UIImageView *voiceImg;
@property (nonatomic, strong) UILabel     *voiceLbl;
@property (nonatomic, strong) UIButton    *comeHereBtn;
@property (nonatomic, strong) UIImageView *comeHereImg;
@property (nonatomic, strong) UILabel     *comeHereLbl;

@property (nonatomic)BOOL isCallOnAvailable;

@end
