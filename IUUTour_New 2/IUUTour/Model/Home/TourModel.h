//
//  TourModel.h
//  IUUTour
//
//  Created by Zhang on 1/1/16.
//  Copyright © 2016 DevDiv Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TourModel : NSObject

@property (nonatomic, strong) NSString *sceneryImage;
@property (nonatomic, strong) NSString *sceneryName;
@property (nonatomic, strong) NSString *muchNow;
@property (nonatomic, strong) NSString *muchOld;
@property (nonatomic, strong) NSString *distances;


@property (nonatomic, strong) NSString *scenryDetail;
@property (nonatomic, strong) NSString *grade;
@property (nonatomic) BOOL *isActive;


@end
