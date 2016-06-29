#import <Foundation/Foundation.h>

@interface CityModel : NSObject<NSCoding>


@property (nonatomic, strong) NSString *cityID;
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) NSString *citylat;
@property (nonatomic, strong) NSString *citylng;
@property (nonatomic, strong) NSString *cityPinYin;

@end
