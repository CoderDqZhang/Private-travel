#import <Foundation/Foundation.h>

@interface ScenicArea : NSObject

@property (nonatomic,strong) NSString       *city;
@property (nonatomic,strong) NSString       *commentsNum;
@property (nonatomic,strong) NSString       *favourNum;
@property (nonatomic,strong) NSString       *imageUrl;
@property (nonatomic,strong) NSString       *lat;
@property (nonatomic,strong) NSString       *lng;
@property (nonatomic,strong) NSString       *rightLat;
@property (nonatomic,strong) NSString       *rightLon;
@property (nonatomic,strong) NSString       *location;
@property (nonatomic,strong) NSString       *scenicId;
@property (nonatomic,strong) NSString       *scenicLevel;//5A 4A 等,写入值为：1-5
@property (nonatomic,strong) NSString       *scenicLocation;
@property (nonatomic,strong) NSString       *scenicName;
@property (nonatomic,strong) NSString       *scenicType;//自然风景区
@property (nonatomic,strong) NSString       *smallImage;
@property (nonatomic,strong) NSString       *warning;//1 绿色 2：蓝色 3：橙色 4：黄色 5：红色预警
@property (nonatomic,strong) NSString       *traffic;
@property (nonatomic,strong) NSString       *emergency;
@property (nonatomic,strong) NSString       *solution;
@property (nonatomic,strong) NSString       *ceaseTime;
@property (nonatomic,strong) NSString       *desc;
@property (nonatomic,strong) NSString       *mapSize;
@property (nonatomic,strong) NSString       *mapZoom;
@property (nonatomic,strong) NSString       *canNavi;
@property (nonatomic,strong) NSString       *voiceDistance;

@property (nonatomic,strong) NSString       *price;
@property (nonatomic,strong) NSString       *originPrice;
@property (nonatomic,strong) NSString       *discountActivity;


@property (nonatomic,strong) NSMutableArray *gameList;
@property (nonatomic,strong) NSMutableArray *recommendScenicList;
@property (nonatomic,strong) NSMutableArray *souvenirList;

@end

@interface UpDateData : NSObject
@property(nonatomic,strong)NSString *scenicId;
@property(nonatomic,strong)NSString *mapVersion;
@end

@interface MapAdvertData : NSObject
@property(nonatomic,strong)NSString *scenicId;
@property(nonatomic,strong)NSString *scenicName;
@property(nonatomic,strong)NSString *advertPic;

@end