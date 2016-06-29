//
//  RouteView.h
//  Manyou
//
//  Created by Yang Eastern on 14/12/15.
//  Copyright (c) 2014年 yangjf. All rights reserved.
//
//
//  Comment by Vincent on Sep 4 2015
//  It's used in ScenicSpotGuideViewController only

#import <UIKit/UIKit.h>

@interface RouteView : UIView {
    NSArray      * lines;
    NSDictionary * scenicSpots;

    float        mapScale;

    float        maxMapX;
    float        maxMapY;
}

@property(nonatomic, strong) NSArray *lines;
@property(nonatomic, strong) NSDictionary *scenicSpots;

@property(nonatomic) float mapScale;

@property(nonatomic) float maxMapX;
@property(nonatomic) float maxMapY;

@end
