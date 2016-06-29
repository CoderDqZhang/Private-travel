//
//  LeftView.h
//  IUUTour
//
//  Created by Zhang on 12/31/15.
//  Copyright © 2015 DevDiv Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol leftTableDelegate <NSObject>

-(void)tableViewSelect:(NSIndexPath *)indexPath;

@end

@interface LeftView : UIView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) User *user;

@property (nonatomic, strong) id<leftTableDelegate> delegate;

@property (nonatomic, readwrite, copy) NSMutableArray *nameArray;
@property (nonatomic, readwrite, copy) NSMutableArray *leftImageArray;
@property (nonatomic, readwrite, copy) NSMutableArray *selectImageArray;

@property (strong, nonatomic) UITableView *mainTable;
//@property (strong, nonatomic) 


@end
