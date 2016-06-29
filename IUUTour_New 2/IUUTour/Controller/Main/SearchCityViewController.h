#import "BaseViewController.h"
#import "CityModel.h"
#import <UIKit/UIKit.h>

@interface SearchCityViewController : UIViewController

@property (nonatomic, strong) NSString *selectCity;

@property (nonatomic, copy) void(^selectCityBlock)(CityModel * cityModel);

- (void)selectCityAction:(void(^)(CityModel *cityModel))city;

@end
