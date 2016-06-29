#import <Foundation/Foundation.h>
#import "CommonActionStatus.h"

@class AFNetworkReachabilityManager;

typedef void(^ResultBlock)(id result, NSError *error);

typedef NS_ENUM(NSUInteger, GetAuthCodeType)
{
    GetAuthCodeTypeRegister  = 0,
    GetAuthCodeTypeGetPasswd = 1,
};

#define K_Rest_URL                     @"http://api.imyuu.com:9100/api/"        //Rest api访根地址
#define K_Image_URL_SHORT              @"http://map.imyuu.com:9100/"            //图片服务根地址
#define K_Image_URL                    @"http://map.imyuu.com:9100/images/"     //图片服务根地址
#define K_Tiles_URL                    @"http://map.imyuu.com:9100/tiles/"      //地图瓦片根地址
#define K_ACTION_HOME                  @"home/scenicquery2.do?"     //景区首页
#define K_ACTION_NEIGHBORS             @"home/neighbors.do?"        //附近景区
#define K_ACTION_DETAIL                @"detail/detail.do?"         //单个景区在线访问
#define K_ACTION_INTRO                 @"detail/intro.do?"          //景区简介
#define K_ACTION_TEANSPORT             @"detail/transport.do?"      //景区交通
#define K_ACTION_TIPS                  @"detail/tips.do?"           //景区贴士
#define K_ACTION_HOTEL                 @"thirdpart/hotel.do?"       //景区酒店
#define K_ACTION_CITYLIST              @"home/citylist.do?"         //城市列表

#define K_ACTION_HOME_DATA              @"home/citylist.do?"         //首页数据

#define K_ACTION_HOME_SEARCH           @"home/scenicquery.do?"      //搜索
#define K_ACTION_HOST_CITYLIST         @"home/hotcity.do"           //热门城市
#define K_ACTION_REGISTER              @"user/registerios.do"       //注册
#define K_ACTION_SENDSMS               @"user/sendSMSios.do?"       //获取验证码
#define K_ACTION_LOGIN                 @"user/loginios.do"          //登录
#define K_UPDATE_INFO                  @"user/updateProfilerios.do" //修改个人信息
#define K_ACTION_RESETPWD              @"user/modifyPasswordios.do" //重置密码
#define K_ACTION_FORGETPWD             @"user/forgetPasswordios.do?"//忘记密码
#define K_UPDATE_INFO                  @"user/updateProfilerios.do" //修改个人信息
#define K_ACTION_MAP                   @"map/allspot.do?"           //单个景区在线访问（map）
#define K_ACTION_MAPLINE               @"map/recommendLine.do?"     //地图路线
#define K_ACTION_SCENICCMT             @"social/querycomments.do?"  //景区留言
#define K_ACTION_SENDSCENICCMT         @"social/commentsios.do?"    //发送景区留言
#define K_ACTION_SCENICPRAISE          @"social/favor.do?"          //景区点赞
#define  K_ACTION_LAUNCH_IMAGE         @"advertImge"
#define K_ACTION_FEEDBACK              @"sys/sysmsgios.do"          //意见反馈
#define K_ACTION_FINDPWD               @"FindPwd"                   //修改密码
#define K_ACTION_MYFANS                @"Myfans"                    //我的粉丝
#define K_ACTION_TODLIST               @"TodList"                   //今日收益
#define K_ACTION_MONLIST               @"MonList"                   //近一月收益
#define K_ACTION_ALLLIST               @"AllList"                   //全部收益
#define K_ACTION_STARTMEMBERREWARDS    @"StarMemberRewards"         //星级会员收益
#define K_ACTION_LOTTERYLIST           @"LotteryList"               //转盘收益
#define K_ACTION_WITHDRAWAL            @"WithDrawal"                //申请提现
#define K_ACTION_WITHDRAWALLIST        @"WithDrawalList"            //提现纪录
#define K_ACTION_ADD_INVITER           @"Addinviter"                //添加邀请码
#define K_ACTION_MAP_MANAGE            @"map/citymap.do"            //地图接口
#define K_ACTION_UPDATEMAP             @"map/checkMap.do?"          //检查更新地图
#define K_ACTION_MAPADVERT             @"map/adverts.do?"           //地图广告
#define K_ACTION_ISPUBLISHEDINAPPSTORE @"sys/isAppStrore.do"        //是否审核期
#define K_ACTION_PUSHTOKEN             @"sys/reportDeviceToken.do?" //注册推送
#define K_ACTION_LOTTERY               @"social/lottery.do?"        //抽奖
#define K_ACTION_QUERYLOTTERY          @"social/queryLotteryios.do?"//查询我的获奖记录
#define K_ACTION_QUERYLATEST           @"social/queryLatestios.do?" //查询获奖用户列表
#define K_UPDATE_HEADIMAGE             @"image/uploadios.do"        //更改头像
#define K_ACTION_WEATHER               @"thirdpart/weather.do?"     //获取天气信息
#define K_ACTION_MYCOMMENTS            @"social/mycomments.do?"     //my comments

@interface Interface : NSObject

@property (nonatomic, strong) NSString *baseURL;

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@property (nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;


+(BOOL)isImageCached:(NSString *)imagePath;

+ (void)serialize:(NSData *)data to:(NSString *)fileName;
+ (NSData *)deserializeFrom:(NSString*)fileName;

+ (NSString *)imageUrlWithPath:(NSString *)path;

+ (NSArray *)imagesFromString:(NSString *)string;

//#pragma mark - 启动页
//+ (void)getLaunchImage:(void(^)(UIImage *image,NSError *error))result;

#pragma mark - 首页数据
+ (void)getHomeList:(NSString *)city Limit:(NSString *)limit offSet:(NSString *)offset  result:(void(^)(HomeListResponse *response, NSError *error))result;




#pragma mark - 缺省景区
+ (void)getDefaultScenicListWithLimit:(NSInteger)limit fromOffset:(NSInteger)offset result:(void (^)(HomeListResponse *, NSError *))result;

#pragma mark - 首页搜索
+ (void)searchHomeListWithKey:(NSString *)keyWord result:(void(^)(HomeListResponse *response, NSError *error))result;

#pragma mark - 附近景区
+ (void)getNeighborsList:(NSString *)lat  lng:(NSString *)lng  scope:(NSString *)scope result:(void(^)(HomeListResponse *response, NSError *error))result;

#pragma mark - 景区详情
+ (void)getScenicDetail:(NSString *)scenicId result:(void(^)(ScenicDetailResponse *response, NSError *error))result;

#pragma mark - 景区简介
+ (void)getScenicBriefIntro:(NSString *)scenicId result:(void(^)(ScenicIntorResponse *response, NSError *error))result;

#pragma mark - 景区交通
+ (void)getScenicTransport:(NSString *)scenicId result:(void(^)(ScenicTransportResponse *response, NSError *error))result;

#pragma mark - 景区贴士
+ (void)getScenicTips:(NSString *)scenicId result:(void(^)(ScenicTipsResponse *response, NSError *error))result;

#pragma mark - 景区酒店
+ (void)getScenicHotel:(NSString *)scenicId result:(void(^)(ScenicHotelResponse *response, NSError *error))result;


+ (void)getMapCityList:(void(^)(MapCityResponse *response, NSError *error))result;

#pragma mark - 城市列表
+ (void)getCityList:(void(^)(NSMutableArray *cityArr, NSError *error))result;

#pragma mark - 热门城市列表
+ (void)getHotCityList:(void(^)(NSMutableArray *hostCityArr, NSError *error))result;

#pragma mark - 登录
+ (void)loginAction:(NSString *)userId  passWard:(NSString *)passward loginName:(NSString *)loginName  ssoaccount:(NSString *)ssoaccount result:(void(^)(LoginResponse *response, NSError *error))result;

#pragma mark -  获取手机验证码
+ (void)sendVerifyCodeByPhone:(NSString *)phone result:(void(^)(VerifyCodeByPgoneResponse *response, NSError *error))result;

#pragma mark -  忘记密码
+ (void)forgetPassWord:(NSString *)phone result:(void(^)(CommonActionStatus *response, NSError *error))result;

#pragma mark - 注册
+ (void)registerAction:(NSString *)tel
                passwd:(NSString *)passwd
             loginName:(NSString *)loginName
              nickName:(NSString *)nickName
                   sex:(NSString *)sex
                   address:(NSString *)address
             ssoSource:(NSString *)ssoSource
            ssoAccount:(NSString *)ssoAccount
                result:(void (^)(CommonActionStatus *response, NSError *err))result;


#pragma mark -  修改密码
+ (void)modifyPassWord:(NSString *)phoneNum password:(NSString *)password code:(NSString *)code
                result:(void(^)(CommonActionStatus *response, NSError *error))result;  

#pragma mark = 重置密码

+ (void)resetAction:(NSString *)userId  passWard:(NSString *)passward result:(void(^)(CommonActionStatus *response, NSError *error))result;

#pragma mark - 修改头像
+ (void)updateHeadImg:(NSData *)headData result:(void(^)(CommonActionStatus *response, NSError *error))result;

#pragma mark - 获取本地头像
+ (void)getLocalHeadImg:(void(^)(NSData *image, NSError *error))result;

#pragma mark - 获取头像
+ (NSString*)getHeadImgUrl;
+ (void)getHeadImgWithResult:(void(^)(NSData *image, NSError *error))result;

#pragma mark - 修改个人信息
+ (void)updateInfoAction:(NSString *)userId  loginName:(NSString *)loginName  birth:(NSString *)birth address:(NSString *)address sex:(NSString *)sex result:(void(^)(CommonActionStatus *response, NSError *error))result;

#pragma mark -  意见反馈
+ (void)feedBack:(NSString *)userId content:(NSString *)content
          result:(void(^)(CommonActionStatus *response, NSError *error))result;


#pragma mark - 景区地图
+ (void)scenicMap:(NSString *)scenicID result:(void(^)(ScenicMapResponse *response, NSError *error))result;

#pragma mark - 路线规划
+ (void)mapLines:(NSString *)scenicID result:(void(^)(MapLineResponse * response,NSError *error))result;

#pragma mark - 添加离线地图
+ (void)addOffineMaps:(void(^)(AddMapResponse * response,NSError *error))result;

#pragma mark - 景区留言
+ (void)scenicComments:(NSString *)scenicID page:(int)page result:(void (^)(ScenicCmtResponse *, NSError *))result;

#pragma mark - 发送景区留言
+ (void)sendScenicComment:(NSString *)userid UserName:(NSString *)username Age:(NSString *)age
          ScenicID:(NSString *)scenicid Content:(NSString *)content Gender:(NSString *)gender
            result:(void(^)(SendScenicResponse * response,NSError *error))result;

#pragma mark - 景区点赞
+ (void)praiseScenic:(NSString *)scenicID UserID:(NSString *)userid
              result:(void(^)(PraiseScenicResponse * response,NSError *error))result;

#pragma mark - 获取地图最后更新时间（服务器）
+ (void)getMapLastUpdateTime:(NSString *)scenicID result:(void(^)(UpDateMapResponse *response,NSError *error))result;

#pragma mark - 地图广告
+ (void)mapAdvert:(NSString *)scenicID result:(void(^)(MapAdvertResponse *response,NSError *error))result;

#pragma mark - 是否在审核期
+ (void)isPublishedInAppStor:(void(^)(AppstoreResponse *response,NSError *error))result;


#pragma mark - 推送
+ (void)sendPushToken:(NSString *)token  recv_msg:(NSString *)recv_msg result:(void(^)(CommonActionStatus *response,NSError *error))result;

#pragma mark - 抽奖
+ (void)getLottery:(void(^)(LuckyDrawerResponse *response,NSError *error))result;

#pragma mark - 查询我的中奖纪录
+ (void)queryMyPrizeList:(void(^)(LotteryWinnerListResponse *response,NSError *error))result;

#pragma mark - 查询中奖用户列表
+ (void)queryWinnerList:(void(^)(LotteryWinnerListResponse *response,NSError *error))result;


#pragma mark - 查询天气信息
+ (void)getScenicWeather:(NSString *)scenicID result:(void(^)(ScenicWeatherResponse *response,NSError *error))result;

#pragma mark - Get my comments
+ (void)getMyComments:(NSString*)sceneId result:(void(^)(MyCommentsResponse *response,NSError *error))result;


@end
