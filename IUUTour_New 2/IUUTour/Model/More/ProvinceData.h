//
//  MapCity.h
//  IUUTour
//
//  Created by sun pan on 15-7-4.
//  Copyright (c) 2015 iuu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProvinceData : NSObject

@property (nonatomic,strong) NSString *province;
@property (nonatomic,strong) NSString *provinceMapSize;
@property (nonatomic,strong) NSArray  *cityListArr;
@end

@interface CityData : NSObject

@property (nonatomic,strong) NSString *cityname;
@property (nonatomic,strong) NSString *cityMapSize;
@property (nonatomic,strong) NSArray  *sceneListArr;


@end

@interface ScenicData : NSObject
@property(nonatomic,strong)NSString *scenicID;
@property(nonatomic,strong)NSString *scenicName;
@property(nonatomic,strong)NSString *canNav;
@property(nonatomic,strong)NSString *scenicMapSize;
@property(nonatomic,strong)NSString *scenicImage;

@end