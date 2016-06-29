//
//  MainTableView.h
//  IUUTour
//
//  Created by Zhang on 12/31/15.
//  Copyright © 2015 DevDiv Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAPageControl.h"
#import "CollectView.h"

@protocol MainViewDelegate <NSObject>

-(void)mjReloadData;
-(void)pushViewAndModel:(ScenicArea *)model;
-(void)searchText:(NSString *)city;
-(void)selectCity;

@end


@interface MainTableView : UIView<UITableViewDelegate,UITableViewDataSource,TAPageControlDelegate,UIGestureRecognizerDelegate,CollectViewDelegate>

@property (nonatomic, strong) id<MainViewDelegate> delegate;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *wrapper;

@property (nonatomic, strong) NSMutableArray *imagesData;
@property (nonatomic, strong) NSMutableArray *sceneryData;


@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) TAPageControl *pageControl;

@property (nonatomic, strong) CollectView *collectView;

@property (nonatomic, strong) NSMutableArray *tourModelArray;

@property (nonatomic, strong) NSMutableArray *cityLatLon;


@property (nonatomic, strong) NSString *currentOffSety;

-(void)reloadData;

@end
