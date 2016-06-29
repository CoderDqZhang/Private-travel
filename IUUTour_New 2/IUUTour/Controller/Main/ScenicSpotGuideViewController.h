//
//  ScenicSpotGuideViewController.h
//  Manyou
//
//  Created by Yang Eastern on 14/12/7.
//  Copyright (c) 2014年 yangjf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "RouteView.h"
#import "BaseViewController.h"
@interface ScenicSpotGuideViewController : BaseViewController<UIActionSheetDelegate, AVAudioPlayerDelegate> {
    UILabel             * titleLabel;
    UIButton            * favoriteBtn;

    NSDictionary        * scenic;
    NSDictionary        * scenicDetail;
    NSInteger           currentRoute;
    NSString            * currentSpotId;
    NSString            * currentAudioSpotId;

    NSMutableDictionary * scenicSpots;

    UIScrollView        * mapScrollView;
    UIImageView         * mapView;
    RouteView           * routeView;
    NSMutableDictionary * spotBtns;
    NSMutableDictionary * spotTexts;
    NSMutableDictionary * spotImgs;
    UIScrollView        * routeTextScrollView;
    UIView              * balloon;
    UILabel             * balloonLabel;
    UIImageView         * uu_walk;

    float               mapWidth;
    float               mapHeight;
    float               mapMaxX;
    float               mapMaxY;
    float               mapScale;

    NSMutableArray      * hotBtns;

    AVAudioPlayer       * audioPlayer;

    float               totalTime;
    float               totalLength;
    int                 animateDotIndex;
    NSMutableArray      * dots;

    NSMutableArray      * adImgs;
    NSArray             * adDatas;
    UIImageView         * adImgView;
    UIButton            * adBtn;
    UIButton            * adCloseBtn;
    NSTimer             * adTimer;
    NSInteger           adIndex;

    NSString            * favoriteFilePath;
    NSMutableArray      * favorites;

    NSMutableArray      * uuWalkLeftImgs;
}

@property (nonatomic,strong) NSDictionary *scenic;
@property (nonatomic,strong) NSDictionary *scenicDetail;
@property (nonatomic       ) NSInteger    currentRoute;

@property (nonatomic,retain) ScenicArea   * data;



- (void)showMap;

@end
