#import <Foundation/Foundation.h>

//景区介绍模型
@interface ScenicIntroduction : NSObject

@property(nonatomic,strong)NSString *desc;
@property(nonatomic,strong)NSString *scenicId;
@property(nonatomic,strong)NSString *scenicLevel;
@property(nonatomic,strong)NSString *scenicType;
@property(nonatomic,strong)NSMutableArray *imageList;

@end

//景区交通
@interface ScenicTransport : NSObject

@property(nonatomic,strong)NSString *desc;
@property(nonatomic,strong)NSString *scenicId;
@property(nonatomic,strong)NSString *imageURL;

@end


//景区贴士
@interface ScenicTips : NSObject

@property(nonatomic,strong)NSString *desc;
@property(nonatomic,strong)NSString *scenicId;
@property(nonatomic,strong)NSString *imageURL;

@end

//景区酒店
@interface ScenicHotel : NSObject

@property(nonatomic,strong)NSString *desc;
@property(nonatomic,strong)NSString *scenicId;
@property(nonatomic,strong)NSString *imageURL;

@end

//景区地图
@interface ScenicMap : NSObject

@property (nonatomic,retain)NSString *lat;
@property (nonatomic,retain)NSString *lon;
@property (nonatomic,retain)NSString *rightLat;
@property (nonatomic,retain)NSString *rightLon;
@property (nonatomic,retain)NSString *mapID;
@property (nonatomic,retain)NSString *name;
@property (nonatomic,retain)NSString *audio;
@property (nonatomic,retain)NSString *spotType;
@property (nonatomic,retain)NSString *scenicID;
@end

//路线规划
@interface MapLine : NSObject

@property (nonatomic,retain)NSString *spotid;
@property (nonatomic,retain)NSString *lineId;
@property (nonatomic,retain)NSString *spotName;
@property (nonatomic,retain)NSString *lat;
@property (nonatomic,retain)NSString *lng;
@property (nonatomic,retain)NSString *spotType;
@property (nonatomic,retain)NSString *order;

@end

//添加离线地图
@interface AddOffineMap : NSObject

@property(nonatomic,strong)NSString *scenicID;
@property(nonatomic,strong)NSString *scenicName;
@property(nonatomic,strong)NSString *provice;
@property(nonatomic,strong)NSString *imageURL;
@property(nonatomic,strong)NSString *pageSize;
@property(nonatomic,strong)NSString *city;
@end

//景区留言墙
@interface ScenicCmts : NSObject

@property (nonatomic,strong)NSString *age;
@property (nonatomic,strong)NSString *commentTime;
@property (nonatomic,strong)NSString *content;
@property (nonatomic,strong)NSString *gender;
@property (nonatomic,strong)NSString *userId;
@property (nonatomic,strong)NSString *userName;
@property (nonatomic,strong)NSString *commentId;
@end
