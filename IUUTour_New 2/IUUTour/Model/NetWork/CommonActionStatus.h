#import <Foundation/Foundation.h>
#import "User.h"
#import "PrizeObject.h"
#import "PrizeWinner.h"
#import "LuckyDrawerData.h"

/**
 *  通用响应状态信息
 */
@interface CommonActionStatus : NSObject <NSCoding>

- (id)initWithJSONObject:(id)jsonObject;

@property (nonatomic, assign) int      status;
@property (nonatomic, copy)   NSString *message;
@property (nonatomic, strong) id       data;

@end

/**
 *  获取验证码响应
 */
@interface GetAuthCodeResponse : CommonActionStatus

@property (nonatomic, copy) NSString *authCode;

@end

/**
 *  登陆响应
 */
@interface LoginResponse : CommonActionStatus

@end


/**
 *  注册响应
 */
@interface RegistResponse : CommonActionStatus <NSCoding>

@end


//首页列表
@interface HomeListResponse : CommonActionStatus

@property (nonatomic, strong) NSMutableArray *homeList;
@property (nonatomic, assign) BOOL           hasNext;

@end


//景点详情
@interface ScenicDetailResponse : CommonActionStatus

@property(nonatomic,strong)ScenicArea *dataItem;

@end

//景点简介
@interface ScenicIntorResponse : CommonActionStatus

@property(nonatomic,strong)ScenicIntroduction *dataItem;

@end

//景点交通
@interface ScenicTransportResponse : CommonActionStatus

@property(nonatomic,strong)ScenicTransport *dataItem;

@end

//景点贴士
@interface ScenicTipsResponse : CommonActionStatus

@property(nonatomic,strong)ScenicTips *dataItem;

@end

//景点酒店
@interface ScenicHotelResponse : CommonActionStatus

@property(nonatomic, strong)NSMutableArray *hotelList;

@end


@interface MapCityResponse : CommonActionStatus
@property(nonatomic,strong)NSMutableArray *mapList;

@end

//城市列表
@interface CityListResponse : CommonActionStatus

@property(nonatomic, strong)NSMutableArray *cityList;

@end





//验证码
@interface VerifyCodeByPgoneResponse : CommonActionStatus

@property (nonatomic, strong) NSString *verfyCode;
@end

//消息列表
@interface MyFansListResponse : CommonActionStatus

@property (nonatomic, strong) NSMutableArray *fansList;
@property (nonatomic, assign) BOOL           hasNext;
@property (nonatomic, strong) NSString       *totalNum;
@property (nonatomic, strong) NSString       *lever;

@end

//收益列表
@interface MoneyResponse : CommonActionStatus

@property (nonatomic, strong) NSMutableArray *moenyList;
@property (nonatomic, assign) BOOL           hasNext;
@property (nonatomic, strong) NSString       *sum_money;
@property (nonatomic, strong) NSString       *read_count;
@property (nonatomic, strong) NSString       *qzone_count;
@property (nonatomic, strong) NSString       *sina_count;
@property (nonatomic, strong) NSString       *weixin_count;

@end


//收益列表
@interface SystemResponse : CommonActionStatus

@property (nonatomic, strong) NSMutableArray *systemList;
@property (nonatomic, assign) BOOL           hasNext;

@end

//收益列表
@interface WithDrawalListResponse : CommonActionStatus

@property (nonatomic, strong) NSMutableArray *withDrawalList;

@end

//单个景区地图在线
@interface ScenicMapResponse : CommonActionStatus

@property (nonatomic, strong) NSMutableArray *mapList;

@end

//地图路线
@interface MapLineResponse : CommonActionStatus

@property (nonatomic, strong) NSMutableArray *classicList;//经典
@property (nonatomic, strong) NSMutableArray *TourList;//畅游

@end

//下载地图
@interface AddMapResponse : CommonActionStatus

@property (nonatomic, strong) NSMutableArray      *mapList;
@property (nonatomic, strong) NSMutableArray      *array;
@property (nonatomic, strong) NSMutableArray      *cityArray;
@property (nonatomic, strong) NSMutableDictionary * proviceDic;
@property (nonatomic, strong) NSMutableDictionary * cityDic;
@property (nonatomic, strong) NSMutableDictionary * isOpenDic;

@end

//获取留言墙
@interface ScenicCmtResponse : CommonActionStatus

@property (nonatomic, strong) NSMutableArray *cmtList;

@end

//发送景区留言
@interface SendScenicResponse : CommonActionStatus

@end

//景区点赞
@interface PraiseScenicResponse : CommonActionStatus

@end

//更新地图提示
@interface UpDateMapResponse : CommonActionStatus
@property (nonatomic, strong) NSMutableArray *date;
@end

//景区广告
@interface MapAdvertResponse : CommonActionStatus

@property (nonatomic, strong) NSMutableArray *advertArray;

@end

//景区广告
@interface AppstoreResponse : CommonActionStatus

@property (nonatomic, assign) BOOL isAppStrore;

@end


//网络摇奖
@interface LuckyDrawerResponse : CommonActionStatus

@property (nonatomic, strong) LuckyDrawerData *luckyDrawerData;

@end


//中奖用户列表
@interface LotteryWinnerListResponse : CommonActionStatus

@property (nonatomic, strong) NSMutableArray *winnerList;

@end


//景区天气
@interface ScenicWeatherResponse : CommonActionStatus

@property (nonatomic, strong) NSMutableArray *weatherList;

@end


//My comments
@interface MyCommentsResponse : CommonActionStatus

@property (nonatomic, strong) NSMutableArray *commentsList;

@end
