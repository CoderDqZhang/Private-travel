//
//  CollectView.h
//  IUUTour
//
//  Created by Zhang on 12/31/15.
//  Copyright © 2015 DevDiv Technology. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CollectViewDelegate <NSObject>

-(void)mainTableDelegate:(ScenicArea *)model;
-(void)searchText:(NSString *)city;

@end


@interface CollectView : UIView<UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate>


@property (nonatomic, strong) id<CollectViewDelegate> delegate;

@property (nonatomic, strong) UICollectionView *collectView;

@property (nonatomic, strong) NSMutableArray *tourModelArray;
@property (nonatomic, strong) NSMutableArray *cityLatLon;

@end
