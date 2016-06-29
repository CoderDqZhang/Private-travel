#import "CommonActionStatus.h"

#define kEncodedObjectPath_Login ([[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"login"])

@implementation CommonActionStatus

- (id)initWithJSONObject:(id)jsonObject
{
    self = [super init];
    if(self)
    {
        NSNumber *status = [jsonObject objectForKey:@"status"];
        _status          = status.boolValue;
        _message         = [jsonObject objectForKey:@"msg"];
        _data            = jsonObject;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.status  = [aDecoder decodeBoolForKey:@"status"];
        self.message = [aDecoder decodeObjectForKey:@"msg"];
        self.data    = [aDecoder decodeObjectForKey:@"data"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:self.status forKey:@"status"];
    [aCoder encodeObject:self.message forKey:@"msg"];
    [aCoder encodeObject:self.data forKey:@"data"];
}

@end

@implementation GetAuthCodeResponse

@end

@implementation LoginResponse


@end

@implementation RegistResponse

@end

@implementation HomeListResponse

@end

@implementation VerifyCodeByPgoneResponse

@end

@implementation MyFansListResponse

@end

@implementation MoneyResponse

@end

@implementation SystemResponse

@end

@implementation WithDrawalListResponse

@end

@implementation ScenicDetailResponse

@end

@implementation ScenicIntorResponse

@end

@implementation ScenicTransportResponse

@end

@implementation ScenicTipsResponse

@end

@implementation ScenicHotelResponse

@end

@implementation MapCityResponse



@end

@implementation CityListResponse

@end

@implementation ScenicMapResponse

@end

@implementation MapLineResponse

@end

@implementation AddMapResponse

@end

@implementation ScenicCmtResponse

@end

@implementation SendScenicResponse

@end

@implementation PraiseScenicResponse

@end

@implementation UpDateMapResponse

@end

@implementation MapAdvertResponse

@end

@implementation AppstoreResponse

@end

@implementation LotteryWinnerListResponse

@end

@implementation LuckyDrawerResponse
@end

@implementation ScenicWeatherResponse
@end

@implementation MyCommentsResponse
@end
