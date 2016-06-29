#import "Interface.h"
#import "AFNetworking.h"
#import "CityModel.h"
#import "PrizeObject.h"
#import "PrizeWinner.h"
#import "WeatherModel.h"
#import "MyComment.h"


@implementation Interface

+(BOOL)isImageCached:(NSString *)imagePath
{
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    BOOL exists = [fileManager fileExistsAtPath:imagePath];
    
    return exists;
}

+ (void)serialize:(NSData *)data to:(NSString *)fileName
{
    NSArray * paths     = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString * path     = [paths  objectAtIndex:0];
    NSString * filePath = [path stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath] &&
        [fileManager isDeletableFileAtPath:filePath])
    {
        NSError *error;
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (!success)
        {
            NSLog(@"Error removing file at path: %@", error.localizedDescription);
        }
    }
    
    if (data)
    {
        [fileManager createFileAtPath:filePath contents:data attributes:nil];
    }
}

+ (NSData *)deserializeFrom:(NSString*)fileName
{
    NSArray * paths     = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString * path     = [paths  objectAtIndex:0];
    NSString * filePath = [path stringByAppendingPathComponent:fileName];

    
    NSData *data = [[NSData alloc]initWithContentsOfFile:filePath options:0 error:nil];
    
    return data;
}


- (id)init
{
    self = [super init];
    if(self)
    {
        //正式服务器环境
        _baseURL = K_Rest_URL;
        _operationQueue = [[NSOperationQueue alloc] init];
        _reachabilityManager = [AFNetworkReachabilityManager sharedManager];
        __weak Interface *weakSelf = self;
        [_reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            __strong Interface *strongSelf = weakSelf;
            if (!strongSelf)
            {
                return;
            }
            
            switch (status)
            {
                case AFNetworkReachabilityStatusReachableViaWiFi:
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    [strongSelf.operationQueue setSuspended:NO];
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                default:
                    [strongSelf.operationQueue setSuspended:YES];
                    break;
            }
        }];
        [_reachabilityManager startMonitoring];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static Interface *single = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        single = [[Interface alloc] init];
    });
    return single;
}

+ (NSString *)imageUrlWithPath:(NSString *)path
{
    return [NSString stringWithFormat:@"%@", path];
}

+ (NSArray *)imagesFromString:(NSString *)string
{
    NSMutableArray *images = [[NSMutableArray alloc] init];
    NSArray *paths         = [string componentsSeparatedByString:@","];
    for(NSString *path in paths)
    {
        NSString *fullPath = [Interface imageUrlWithPath:path];
        [images addObject:fullPath];
    }
    return images;
}

+ (NSMutableURLRequest *)urlRequestWithAicton:(NSString *)actionName parameters:(NSString *)parameters
{
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",[Interface sharedInstance].baseURL,actionName];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSLog(@"REQUEST_URL %@",url);

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    request.HTTPMethod = @"POST";
 

    NSMutableData *postBody = [NSMutableData data];
    
    NSLog(@"REQUEST_parameters %@",parameters);

    [postBody appendData:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postBody];
    return request;
}


+ (NSMutableURLRequest *)method:(NSString *)method requestWithparameters:(NSString *)parameters
{
    NSArray *methods = @[@"POST",@"GET"];
    if (![methods containsObject:method] || !parameters)
    {
        return nil;
    }
    BOOL isGet = [method isEqualToString:@"GET"];
    NSString *getPara = nil;
    if (![parameters hasPrefix:@"?"])
    {
        getPara = [NSString stringWithFormat:@"%@",parameters];
    }
    else
    {
        getPara = [NSString stringWithFormat:@"%@",parameters];
    }
    if (!isGet)
    {
        getPara = @"";
    }
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",[Interface sharedInstance].baseURL,getPara];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSLog(@"REquestURL %@",strUrl);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    request.HTTPMethod = method;
    NSMutableData *postBody = [NSMutableData data];
    if (!isGet)
    {
        [postBody appendData:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postBody];
    }
    NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
    return request;
}

#pragma mark - 注册
/*
 [UserInfoJson]{userId，password,loginName, ssoaccount,ssosource}[0:账号，1：微信，2微博 3：qq]
 */

//#pragma mark - 启动页
//+ (void)getLaunchImage:(void (^)(UIImage *, NSError *))result
//{
//    NSString *strUrl = [NSString stringWithFormat:@"%@",K_Image_URL];
////    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
////    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
////    
////    NSString *strUrl = [NSString stringWithFormat:@"telno=%@",telno];
////    
//    
//    
//    NSMutableURLRequest *request = [Interface urlRequestWithAicton:K_ACTION_REGISTER parameters:strUrl];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//         NSArray *jsonArr = [operation.responseData objectFromJSONData];
//         
//         
//         result(nil, nil);
//     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//         
//         result (nil, error);
//         
//     }];
//    [[NSOperationQueue mainQueue] addOperation:operation];
//
//}

#pragma mark - 首页信息的获取
+ (void)getHomeList:(NSString *)city Limit:(NSString *)limit offSet:(NSString *)offset result:(void (^)(HomeListResponse *, NSError *))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@keyword=%@&limit=%@&offset=%@",K_ACTION_HOME,city,limit,offset];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];

         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         
         [jsonObject setObject:jsonArr forKey:@"data"];
         [jsonObject setObject:@"成功" forKey:@"msg"];
         [jsonObject setObject:@"1" forKey:@"status"];
         
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
         
         [self serialize:jsonData to:city];
         
         result([Interface homeJson2HomeResponse:jsonObject], nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSMutableDictionary *jsonObject = nil;
         NSData *serializedData = [self deserializeFrom:city];
         
         if (serializedData)
         {
             jsonObject = [NSJSONSerialization JSONObjectWithData:serializedData
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
         }
        
         
         if (!jsonObject)
         {
             jsonObject = [[NSMutableDictionary alloc] init];
             [jsonObject setObject:[[NSArray alloc]init] forKey:@"data"];
             [jsonObject setObject:@"失败" forKey:@"msg"];
             [jsonObject setObject:@"0" forKey:@"status"];
         }
         result ([Interface homeJson2HomeResponse:jsonObject], nil);
         
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}


#pragma mark - 缺省景区
+ (void)getDefaultScenicListWithLimit:(NSInteger)limit fromOffset:(NSInteger)offset result:(void (^)(HomeListResponse *, NSError *))result
{
    NSString *keyWord = [NSString stringWithFormat:@"defaultScenicList_%ld_%ld", (long)limit, (long)offset];
    NSString *strUrl = [NSString stringWithFormat:@"%@limit=%ld&offset=%ld",@"home/pagelist.do?",(long)limit, (long)offset];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         
         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         
         [jsonObject setObject:jsonArr forKey:@"data"];
         [jsonObject setObject:@"成功" forKey:@"msg"];
         [jsonObject setObject:@"1" forKey:@"status"];
         
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
         

         [self serialize:jsonData to:keyWord];
         
         
         result([Interface homeJson2HomeResponse:jsonObject], nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSMutableDictionary *jsonObject = nil;
         NSData *serializedData = [self deserializeFrom:keyWord];
         
         if (serializedData)
         {
             jsonObject = [NSJSONSerialization JSONObjectWithData:serializedData
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
         }
         
         
         if (!jsonObject)
         {
             jsonObject = [[NSMutableDictionary alloc] init];
             [jsonObject setObject:[[NSArray alloc]init] forKey:@"data"];
             [jsonObject setObject:@"失败" forKey:@"msg"];
             [jsonObject setObject:@"0" forKey:@"status"];
         }
         
         result ([Interface homeJson2HomeResponse:jsonObject], nil);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}


#pragma mark - 首页搜索
+ (void)searchHomeListWithKey:(NSString *)keyWord result:(void (^)(HomeListResponse *, NSError *))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@keyword=%@",K_ACTION_HOME_SEARCH,keyWord];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"operation.responseData");
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         
         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         
         [jsonObject setObject:jsonArr forKey:@"data"];
         [jsonObject setObject:@"成功" forKey:@"msg"];
         [jsonObject setObject:@"1" forKey:@"status"];
         
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
         
         [self serialize:jsonData to:keyWord];
         
         
         result([Interface homeJson2HomeResponse:jsonObject], nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSMutableDictionary *jsonObject = nil;
         NSData *serializedData = [self deserializeFrom:keyWord];
         
         if (serializedData)
         {
             jsonObject = [NSJSONSerialization JSONObjectWithData:serializedData
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
         }
         
         
         if (!jsonObject)
         {
             jsonObject = [[NSMutableDictionary alloc] init];
             [jsonObject setObject:[[NSArray alloc]init] forKey:@"data"];
             [jsonObject setObject:@"失败" forKey:@"msg"];
             [jsonObject setObject:@"0" forKey:@"status"];
         }
         
         result ([Interface homeJson2HomeResponse:jsonObject], nil);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

+(HomeListResponse *)homeJson2HomeResponse:(NSMutableDictionary *)jsonObject
{
    if (!jsonObject)
    {
        return nil;
    }
    
    HomeListResponse *response = [[HomeListResponse alloc] initWithJSONObject:jsonObject];
    if (!response)
    {
        return nil;
    }
    response.message      = [jsonObject objectForKey:@"msg"];
    response.status       = [[jsonObject objectForKey:@"status"] boolValue];
    NSMutableArray *array = [[NSMutableArray alloc] init];

    for(NSDictionary *json in [jsonObject objectForKey:@"data"])
    {
        if (!json)
        {
            continue;
        }
        ScenicArea *datatemp    = [[ScenicArea alloc] init];
        datatemp.city           = [json objectForKey:@"city"];
        datatemp.commentsNum    = [[json objectForKey:@"commentsNum"] description];
        datatemp.favourNum      = [[json objectForKey:@"favourNum"] description];
        datatemp.imageUrl       = [NSString stringWithFormat:@"%@%@",K_Image_URL,[json objectForKey:@"imageUrl"]];
        datatemp.lat            = [json objectForKey:@"lat"];
        datatemp.lng            = [json objectForKey:@"lng"];
        datatemp.location       = [json objectForKey:@"location"];
        datatemp.scenicId       = [[json objectForKey:@"scenicId"] description];
        datatemp.scenicLevel    = [json objectForKey:@"scenicLevel"];
        datatemp.scenicLocation = [json objectForKey:@"scenicLocation"];
        datatemp.scenicName     = [json objectForKey:@"scenicName"];
        datatemp.scenicType     = [json objectForKey:@"scenicType"];
        datatemp.mapSize        = [json objectForKey:@"mapSize"];
        datatemp.canNavi        = [json objectForKey:@"canNavi"];
        datatemp.smallImage     = [NSString stringWithFormat:@"%@%@",K_Image_URL,[json objectForKey:@"smallImage"]];
        datatemp.warning        = [json objectForKey:@"warning"];
        datatemp.traffic        = [json objectForKey:@"traffic"];
        datatemp.emergency      = [json objectForKey:@"emergency"];
        datatemp.solution       = [json objectForKey:@"solution"];
        datatemp.ceaseTime      = [json objectForKey:@"ceaseTime"];
        datatemp.voiceDistance  = [json objectForKey:@"voiceDistance"];
        
        datatemp.price  = [json objectForKey:@"price"];
        datatemp.originPrice  = [json objectForKey:@"originPrice"];
        datatemp.discountActivity  = [json objectForKey:@"discountActivity"];
        
        
        [array addObject:datatemp];
    }
    response.homeList = array;
    return response;
}

#pragma mark - 附近景区
+ (void)getNeighborsList:(NSString *)lat  lng:(NSString *)lng  scope:(NSString *)scope result:(void(^)(HomeListResponse *response, NSError *error))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@lat=%@&lng=%@&scope=%@",K_ACTION_NEIGHBORS,lat,lng,scope];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         [jsonObject setObject:jsonArr forKey:@"data"];
         [jsonObject setObject:@"成功" forKey:@"msg"];
         [jsonObject setObject:@"1" forKey:@"status"];
 
         NSString *keyWord = [NSString stringWithFormat:@"scenicNearby%@%@.plist",lat, lng];
         NSData *jsonData  = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
         
         [self serialize:jsonData to:keyWord];
         
         
         HomeListResponse *response = [self neighborJson2NeighborResponse:jsonObject];
         result(response, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSString *keyWord = [NSString stringWithFormat:@"scenicNearby%@%@.plist",lat, lng];

         NSMutableDictionary *jsonObject = nil;
         NSData *serializedData = [self deserializeFrom:keyWord];
         
         if (serializedData)
         {
             jsonObject = [NSJSONSerialization JSONObjectWithData:serializedData
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
         }
         
         if (!jsonObject)
         {
             jsonObject = [[NSMutableDictionary alloc] init];
             [jsonObject setObject:@"失败" forKey:@"msg"];
             [jsonObject setObject:@"0" forKey:@"status"];
         }

         HomeListResponse *response = [self neighborJson2NeighborResponse:jsonObject];
         
         result(response, error);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

+ (HomeListResponse*)neighborJson2NeighborResponse:(NSMutableDictionary *)jsonObject
{
    if (!jsonObject)
    {
        return nil;
    }
    
    HomeListResponse *response = [[HomeListResponse alloc] initWithJSONObject:jsonObject];
    if (!response)
    {
        return nil;
    }
    response.message = [jsonObject objectForKey:@"msg"];
    response.status  = [[jsonObject objectForKey:@"status"] boolValue];
    
    
    NSDictionary *dic = [jsonObject objectForKey:@"data"];

    if (dic)
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for(NSDictionary *json in dic)
        {
            if (!json)
            {
                continue;
            }
            
            ScenicArea *datatemp    = [[ScenicArea alloc] init];
            datatemp.city           = [json objectForKey:@"city"];
            if ([json objectForKey:@"commentsNum"])
            {
            datatemp.commentsNum    = [[json objectForKey:@"commentsNum"] description];
            }
            if ([json objectForKey:@"favourNum"])
            {
            datatemp.favourNum      = [[json objectForKey:@"favourNum"] description];
            }
            datatemp.imageUrl       = [NSString stringWithFormat:@"%@%@",K_Image_URL,[json objectForKey:@"imageUrl"]];
            datatemp.lat            = [json objectForKey:@"lat"];
            datatemp.lng            = [json objectForKey:@"lng"];
            datatemp.location       = [json objectForKey:@"location"];
            if ([json objectForKey:@"scenicId"])
            {
            datatemp.scenicId       = [[json objectForKey:@"scenicId"] description];
            }
            datatemp.scenicLevel    = [json objectForKey:@"scenicLevel"];
            datatemp.scenicLocation = [json objectForKey:@"scenicLocation"];
            datatemp.scenicName     = [json objectForKey:@"scenicName"];
            datatemp.scenicType     = [json objectForKey:@"scenicType"];
            datatemp.smallImage     = [NSString stringWithFormat:@"%@%@",K_Image_URL,[json objectForKey:@"smallImage"]];
            datatemp.warning        = [json objectForKey:@"warning"];
            
            [array addObject:datatemp];
        }
        
        response.homeList = array;
    }
    
    return response;
}

#pragma mark - 景区详情
+ (void)getScenicDetail:(NSString *)scenicId result:(void(^)(ScenicDetailResponse *response, NSError *error))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@scenicId=%@",K_ACTION_DETAIL,scenicId];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         [jsonObject setObject:jsonArr forKey:@"data"];
         [jsonObject setObject:@"成功" forKey:@"msg"];
         [jsonObject setObject:@"1" forKey:@"status"];
     
         NSString *keyWord = [NSString stringWithFormat:@"scenicDet%@.plist",scenicId];
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
         
         [self serialize:jsonData to:keyWord];
         
         
         result([Interface detailJson2DetailResponse:jsonObject], nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSString *keyWord = [NSString stringWithFormat:@"scenicDet%@.plist",scenicId];
         
         NSMutableDictionary *jsonObject = nil;
         NSData *serializedData = [self deserializeFrom:keyWord];
         
         if (serializedData)
         {
             jsonObject = [NSJSONSerialization JSONObjectWithData:serializedData
                                             options:NSJSONReadingAllowFragments
                                               error:nil];
         }

         
         if (!jsonObject)
         {
             jsonObject = [[NSMutableDictionary alloc] init];
             [jsonObject setObject:@"失败" forKey:@"msg"];
             [jsonObject setObject:@"0" forKey:@"status"];
         }
         result([Interface detailJson2DetailResponse:jsonObject], nil);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

+ (ScenicDetailResponse *)detailJson2DetailResponse:(NSMutableDictionary *)jsonObject
{
    if (!jsonObject)
    {
        return nil;
    }
    
    ScenicDetailResponse *response = [[ScenicDetailResponse alloc] initWithJSONObject:jsonObject];
    if (!response)
    {
        return nil;
    }
    
    response.message = [jsonObject objectForKey:@"msg"];
    response.status  = [[jsonObject objectForKey:@"status"] boolValue];
    ScenicArea *datatemp = [[ScenicArea alloc] init];
    
    NSDictionary *dic = [jsonObject objectForKey:@"data"];
    if (dic)
    {
        datatemp.canNavi = [dic objectForKey:@"canNavi"];
        datatemp.city    = [dic objectForKey:@"city"];
        if ([dic objectForKey:@"commentsNum"])
        {
            datatemp.commentsNum = [[dic objectForKey:@"commentsNum"] description];
        }
        if ([dic objectForKey:@"favourNum"])
        {
            datatemp.favourNum = [[dic objectForKey:@"favourNum"] description];
        }
        datatemp.imageUrl = [NSString stringWithFormat:@"%@%@",K_Image_URL,[dic objectForKey:@"imageUrl"]];
        datatemp.lat      = [dic objectForKey:@"lat"];
        datatemp.lng      = [dic objectForKey:@"lng"];
        datatemp.location = [dic objectForKey:@"location"];
        if ([dic objectForKey:@"scenicId"])
        {
            datatemp.scenicId = [[dic objectForKey:@"scenicId"] description];
        }
        datatemp.scenicLevel    = [dic objectForKey:@"scenicLevel"];
        datatemp.scenicLocation = [dic objectForKey:@"scenicLocation"];
        datatemp.scenicName     = [dic objectForKey:@"scenicName"];
        datatemp.scenicType     = [dic objectForKey:@"scenicType"];
        datatemp.smallImage     = [NSString stringWithFormat:@"%@%@",K_Image_URL,[dic objectForKey:@"smallImage"]];
        datatemp.warning        = [dic objectForKey:@"warning"];
        datatemp.rightLat       = [dic objectForKey:@"right_lat"];
        datatemp.rightLon       = [dic objectForKey:@"right_lng"];
        datatemp.mapSize        = [dic objectForKey:@"mapSize"];
        datatemp.mapZoom        = [dic objectForKey:@"mapZoom"];
        datatemp.voiceDistance  = [dic objectForKey:@"voiceDistance"];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for(NSDictionary *json in [dic objectForKey:@"recommendScenicList"])
        {
            if (!json)
            {
                continue;
            }
            Recommend *recommend = [[Recommend alloc] init];
            recommend.name       = [json objectForKey:@"name"];
            recommend.imageUrl   = [NSString stringWithFormat:@"%@%@",K_Image_URL,[json objectForKey:@"imageUrl"]];
            recommend.intentLink = [json objectForKey:@"intentLink"];
            recommend.scenicID   = [json objectForKey:@"recommendId"];
            [array addObject:recommend];
        }
        datatemp.recommendScenicList = array;
        response.dataItem = datatemp;
    }
    
    return response;
}

#pragma mark - 景区简介
+ (void)getScenicBriefIntro:(NSString *)scenicId result:(void(^)(ScenicIntorResponse *response, NSError *error))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@scenicId=%@",K_ACTION_INTRO,scenicId];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         

         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         
         [jsonObject setObject:jsonArr forKey:@"data"];
         [jsonObject setObject:@"成功" forKey:@"msg"];
         [jsonObject setObject:@"1" forKey:@"status"];
         
         ScenicIntorResponse *response = [self briefJson2BriefResponse:jsonObject];
         
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
         

         [self serialize:jsonData to:[NSString stringWithFormat:@"scenicBrief%@.plist",scenicId]];

         result(response, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSString *keyWord = [NSString stringWithFormat:@"scenicBrief%@.plist",scenicId];
         NSMutableDictionary *jsonObject = nil;
         NSData *serializedData = [self deserializeFrom:keyWord];
         
         if (serializedData)
         {
             jsonObject = [NSJSONSerialization JSONObjectWithData:serializedData
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
         }
         
         
         if (!jsonObject)
         {
             jsonObject = [[NSMutableDictionary alloc] init];
             [jsonObject setObject:@"失败" forKey:@"msg"];
             [jsonObject setObject:@"0" forKey:@"status"];
         }
         
         ScenicIntorResponse *response = [self briefJson2BriefResponse:jsonObject];
         
         result(response, error);
     }];
    
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

+ (ScenicIntorResponse*)briefJson2BriefResponse:(NSMutableDictionary*)jsonObject
{
    if (!jsonObject)
    {
        return nil;
    }
    
    ScenicIntorResponse *response = [[ScenicIntorResponse alloc] initWithJSONObject:jsonObject];
    if (!response)
    {
        return nil;
    }
    response.message = [jsonObject objectForKey:@"msg"];
    response.status  = [[jsonObject objectForKey:@"status"] boolValue];
    
    NSDictionary *dic = [jsonObject objectForKey:@"data"];

    if (dic)
    {
        ScenicIntroduction *datatemp = [[ScenicIntroduction alloc] init];
        datatemp.desc = [dic objectForKey:@"desc"];
        if ([dic objectForKey:@"scenicId"])
        {
            datatemp.scenicId = [[dic objectForKey:@"scenicId"] description];
        }
        datatemp.scenicLevel  = [dic objectForKey:@"scenicLevel"];
        datatemp.scenicType   = [dic objectForKey:@"scenicType"];

        NSMutableArray *array = [[NSMutableArray alloc] init];
        for(NSDictionary *json in [dic objectForKey:@"imageList"])
        {
            if (!json)
            {
                continue;
            }
            
            Recommend *recommend = [[Recommend alloc] init];
            recommend.name       = [json objectForKey:@"name"];
            recommend.imageUrl   = [NSString stringWithFormat:@"%@%@",K_Image_URL,[json objectForKey:@"imageUrl"]];
            recommend.intentLink = [json objectForKey:@"intentLink"];
            [array addObject:recommend];
        }
        
        datatemp.imageList = array;
        response.dataItem = datatemp;
    }
    
    return response;
}

#pragma mark - 景区交通
+ (void)getScenicTransport:(NSString *)scenicId result:(void(^)(ScenicTransportResponse *response, NSError *error))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@scenicId=%@",K_ACTION_TEANSPORT,scenicId];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         [jsonObject setObject:jsonArr forKey:@"data"];
         [jsonObject setObject:@"成功" forKey:@"msg"];
         [jsonObject setObject:@"1" forKey:@"status"];
         
         NSString *keyWord = [NSString stringWithFormat:@"ScenicTransport%@", scenicId];

         NSData *jsonData  = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
         
         [self serialize:jsonData to:keyWord];
         
         ScenicTransportResponse *response = [self scenicTransportJson2ScenicTransportResponse:jsonObject];
 
         result(response, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSString *keyWord = [NSString stringWithFormat:@"ScenicTransport%@", scenicId];
 
         NSMutableDictionary *jsonObject = nil;
         NSData *serializedData = [self deserializeFrom:keyWord];
         
         if (serializedData)
         {
             jsonObject = [NSJSONSerialization JSONObjectWithData:serializedData
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
         }
         
         
         if (!jsonObject)
         {
             jsonObject = [[NSMutableDictionary alloc] init];
             [jsonObject setObject:[[NSArray alloc]init] forKey:@"data"];
             [jsonObject setObject:@"失败" forKey:@"msg"];
             [jsonObject setObject:@"0" forKey:@"status"];
         }

         ScenicTransportResponse *response = [self scenicTransportJson2ScenicTransportResponse:jsonObject];

         result(response, error);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

+ (ScenicTransportResponse*)scenicTransportJson2ScenicTransportResponse:(NSMutableDictionary *)jsonObject
{
    if (!jsonObject)
    {
        return nil;
    }
    
    ScenicTransportResponse *response = [[ScenicTransportResponse alloc] initWithJSONObject:jsonObject];
    response.message = [jsonObject objectForKey:@"msg"];
    response.status  = [[jsonObject objectForKey:@"status"] boolValue];
    ScenicTransport *datatemp = [[ScenicTransport alloc] init];
    
    NSDictionary *dic = [jsonObject objectForKey:@"data"];
    if (dic && [dic count] > 0)
    {
        datatemp.desc     = [dic objectForKey:@"desc"];
        datatemp.scenicId = [[dic objectForKey:@"scenicId"] description];
        datatemp.imageURL = [NSString stringWithFormat:@"%@%@",K_Image_URL,[dic objectForKey:@"imageURL"]];
    }
    response.dataItem = datatemp;
    
    return response;
}


#pragma mark - 景区贴士
+ (void)getScenicTips:(NSString *)scenicId result:(void(^)(ScenicTipsResponse *response, NSError *error))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@scenicId=%@",K_ACTION_TIPS,scenicId];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         [jsonObject setObject:jsonArr forKey:@"data"];
         [jsonObject setObject:@"成功" forKey:@"msg"];
         [jsonObject setObject:@"1" forKey:@"status"];

         NSString *keyWord = [NSString stringWithFormat:@"ScenicTip%@", scenicId];

         NSData *jsonData  = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
         
         [self serialize:jsonData to:keyWord];
         
         
         ScenicTipsResponse *response = [self scenicTipsJson2ScenicTipsResponse:jsonObject];
         result(response, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSString *keyWord = [NSString stringWithFormat:@"ScenicTip%@", scenicId];
         

         NSMutableDictionary *jsonObject = nil;
         NSData *serializedData = [self deserializeFrom:keyWord];
         
         if (serializedData)
         {
             jsonObject = [NSJSONSerialization JSONObjectWithData:serializedData
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
         }
         
         if (!jsonObject)
         {
             jsonObject = [[NSMutableDictionary alloc] init];
             [jsonObject setObject:[[NSArray alloc]init] forKey:@"data"];
             [jsonObject setObject:@"失败" forKey:@"msg"];
             [jsonObject setObject:@"0" forKey:@"status"];
         }

         ScenicTipsResponse *response = [self scenicTipsJson2ScenicTipsResponse:jsonObject];
         
         result(response, error);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

+ (ScenicTipsResponse*)scenicTipsJson2ScenicTipsResponse:(NSMutableDictionary *)jsonObject
{
    if (!jsonObject)
    {
        return nil;
    }
    
    ScenicTipsResponse *response = [[ScenicTipsResponse alloc] initWithJSONObject:jsonObject];
    if (!response)
    {
        return nil;
    }
    
    response.message = [jsonObject objectForKey:@"msg"];
    if ([jsonObject objectForKey:@"status"])
    {
        response.status = [[jsonObject objectForKey:@"status"] boolValue];
    }
    ScenicTips *datatemp = [[ScenicTips alloc] init];
    
    NSDictionary *dic = [jsonObject objectForKey:@"data"];
    if (dic && [dic count] > 0)
    {
        datatemp.desc = [dic objectForKey:@"desc"];
        datatemp.scenicId = [[dic objectForKey:@"scenicId"] description];
        datatemp.imageURL = [NSString stringWithFormat:@"%@%@",K_Image_URL,[dic objectForKey:@"imageURL"]];
    }
    response.dataItem = datatemp;
    
    return response;
}

#pragma mark - 景区酒店
+ (void)getScenicHotel:(NSString *)scenicId result:(void(^)(ScenicHotelResponse *response, NSError *error))result
{
}

#pragma mark - 添加地图
+ (void)getMapCityList:(void(^)(MapCityResponse *response, NSError *error))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@",K_ACTION_MAP_MANAGE];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         [jsonObject setObject:jsonArr forKey:@"data"];
         [jsonObject setObject:@"成功" forKey:@"msg"];
         [jsonObject setObject:@"1" forKey:@"status"];
         
         NSString *keyWord = @"AvailableOfflineMapList";
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
         [self serialize:jsonData to:keyWord];
         
         MapCityResponse *response = [self scenicMapListJson2MapListResponse:jsonObject];
         result(response, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         NSString *keyWord = @"AvailableOfflineMapList";
         

         NSMutableDictionary *jsonObject = nil;
         NSData *serializedData = [self deserializeFrom:keyWord];
         
         if (serializedData)
         {
             jsonObject = [NSJSONSerialization JSONObjectWithData:serializedData
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
         }

         
         if (!jsonObject)
         {
             jsonObject = [[NSMutableDictionary alloc] init];
             [jsonObject setObject:[[NSArray alloc]init] forKey:@"data"];
             [jsonObject setObject:@"失败" forKey:@"msg"];
             [jsonObject setObject:@"0" forKey:@"status"];
         }
         
         MapCityResponse *response = [self scenicMapListJson2MapListResponse:jsonObject];

         result(response, error);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}


+ (MapCityResponse*)scenicMapListJson2MapListResponse:(NSMutableDictionary *)jsonObject
{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    
    for(NSDictionary *json in [jsonObject objectForKey:@"data"] )
    {
        ProvinceData *proviceData = [[ProvinceData alloc] init];
        proviceData.province = json[@"province"];
        proviceData.provinceMapSize = json[@"mapSize"];
        NSMutableArray *cityArr = [[NSMutableArray alloc] init];
        for (NSDictionary *cityDic in json[@"cityList"]) {
            CityData *cityD = [[CityData alloc] init];
            cityD.cityname = cityDic[@"cityName"];
            cityD.cityMapSize = cityDic[@"mapSize"];
            NSMutableArray *scenicArr = [[NSMutableArray alloc] init];
            for (NSDictionary *scenicDict in cityDic[@"sceneList"]) {
                ScenicData *scenicD = [[ScenicData alloc] init];
                scenicD.scenicName = scenicDict[@"scenicName"];
                scenicD.scenicID = scenicDict[@"scenicId"];
                scenicD.scenicMapSize = scenicDict[@"mapSize"];
                scenicD.canNav = [scenicDict[@"canNav"] description];
                scenicD.scenicImage = [NSString stringWithFormat:@"%@%@",K_Image_URL,scenicDict[@"smallImage"]];
                [scenicArr addObject:scenicD];
            }
            cityD.sceneListArr = scenicArr;
            [cityArr addObject:cityD];
        }
        proviceData.cityListArr = cityArr;
        [resultArr addObject:proviceData];
    }

    MapCityResponse *response = [[MapCityResponse alloc] initWithJSONObject:jsonObject];
    response.mapList = resultArr;

    return response;
}

#pragma mark - 城市列表
+ (void)getCityList:(void(^)(NSMutableArray *cityArr, NSError *error))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@",K_ACTION_CITYLIST];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         NSMutableArray *cArr = [[NSMutableArray alloc] init];
         for (int i = 0 ; i < jsonArr.count ; i++) {
             NSDictionary *dic = jsonArr[i];
             CityModel *mm = [[CityModel alloc] init];
             mm.cityID = [NSString stringWithFormat:@"%@",dic[@"cityid"]];
             mm.cityName = dic[@"cityname"];
             mm.citylat = dic[@"lat"];
             mm.citylng = dic[@"lng"];
             mm.cityPinYin = [NSString stringWithFormat:@"%@",dic[@"pinyin"]];
             
             [cArr addObject:mm];
         }
         
         NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cArr];
         [self serialize:data to:@"CityList"];
         
         result(cArr, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSData *data = [self deserializeFrom:@"CityList"];
         
         NSMutableArray *cArr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
         result(cArr, nil);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

#pragma mark - 热门城市
+ (void)getHotCityList:(void (^)(NSMutableArray *, NSError *))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@",K_ACTION_HOST_CITYLIST];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         NSMutableArray *cArr = [[NSMutableArray alloc] init];
         for (int i = 0 ; i < jsonArr.count ; i++) {
             NSDictionary *dic = jsonArr[i];
             CityModel *mm = [[CityModel alloc] init];
             mm.cityID = [NSString stringWithFormat:@"%@",dic[@"cityid"]];
             mm.cityName = dic[@"cityname"];
             mm.citylat = dic[@"lat"];
             mm.citylng = dic[@"lng"];
             [cArr addObject:mm];
         }
         
         NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cArr];
         [self serialize:data to:@"HotCityList"];

         result(cArr, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSData *data = [self deserializeFrom:@"HotCityList"];
         
         NSMutableArray *cArr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
         result(cArr, error);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

#pragma mark -  获取手机验证码
+ (void)sendVerifyCodeByPhone:(NSString *)telno result:(void(^)(VerifyCodeByPgoneResponse *response, NSError *error))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@telno=%@",K_ACTION_SENDSMS,telno];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:nil];

         VerifyCodeByPgoneResponse *response = [[VerifyCodeByPgoneResponse alloc] initWithJSONObject:jsonObject];
         response.message = [jsonObject objectForKey:@"serviceMsg"];
         response.status = [[[jsonObject objectForKey:@"stateCode"] description] isEqualToString:@"0"];
         if (response.status)
         {
             response.verfyCode = [[jsonObject objectForKey:@"data"] objectForKey:@"code"];
         }
         result(response, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         result(nil, error);
     }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}


#pragma mark -  忘记密码
+ (void)forgetPassWord:(NSString *)phone result:(void(^)(CommonActionStatus *response, NSError *error))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@telno=%@",K_ACTION_FORGETPWD,phone];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:nil];
         //NSDictionary *jsonObject = [operation.responseData objectFromJSONData];
         CommonActionStatus *response = [[CommonActionStatus alloc] initWithJSONObject:jsonObject];
         response.message = [jsonObject objectForKey:@"serviceMsg"];
         response.status = ([[jsonObject objectForKey:@"stateCode"] integerValue] == 0 ? 1 : 0);
         if (response.status)
         {
//             response.verfyCode = [[jsonObject objectForKey:@"data"] objectForKey:@"code"];
         }
         result(response, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         result(nil, error);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}


+ (void)registerAction:(NSString *)tel
                passwd:(NSString *)passwd
             loginName:(NSString *)loginName
              nickName:(NSString *)nickName
                   sex:(NSString *)sex
               address:(NSString *)address
             ssoSource:(NSString *)ssoSource
             ssoAccount:(NSString *)ssoAccount
                result:(void (^)(CommonActionStatus *response, NSError *err))result
{
    NSString *strUrl = [NSString stringWithFormat:@"tel=%@&password=%@&loginName=%@&platform=1&imageUrl=%@&nickName=%@&address=%@&city=%@&gender=%@&birthday=%@&desc=%@&level=%@&email=%@&verifyCode=%@&ssoSource=%@&ssoAccount=%@&lat=%@&lng=%@&age=%@",tel,passwd,loginName,@"",nickName,address,@"",sex,@"",@"",@"",@"",@"",ssoSource,ssoAccount,@"",@"",@""];
    
    NSMutableURLRequest *request = [Interface urlRequestWithAicton:K_ACTION_REGISTER parameters:strUrl];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:nil];

         VerifyCodeByPgoneResponse *response = [[VerifyCodeByPgoneResponse alloc] initWithJSONObject:jsonObject];
         response.message = [jsonObject objectForKey:@"msg"];
         response.status = [[jsonObject objectForKey:@"status"] boolValue];
         if (response.status)
         {
             response.verfyCode = [[jsonObject objectForKey:@"data"] objectForKey:@"code"];
         } 
         result(response, nil);
         User *us  = [User sharedInstance];
         us.userid = jsonObject[@"serviceMsg"];
         [User synchronize];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         result(nil, error);
     }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

#pragma mark = 修改个人信息

+ (void)updateInfoAction:(NSString *)userId  loginName:(NSString *)loginName  birth:(NSString *)birth address:(NSString *)address sex:(NSString *)sex result:(void(^)(CommonActionStatus *response, NSError *error))result
{
    NSString *strUrl = [NSString stringWithFormat:@"userId=%@&loginName=%@&birthday=%@&address=%@&gender=%@",userId,loginName,birth,address,sex];
    
    NSMutableURLRequest *request = [Interface urlRequestWithAicton:K_UPDATE_INFO parameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         
         //NSDictionary *jsonObject = [operation.responseData objectFromJSONData];
         
         CommonActionStatus *response = [[CommonActionStatus alloc] initWithJSONObject:jsonObject];
         
         
         User *us = [User sharedInstance];
         us.loginName = loginName;
         us.birthday = birth;
         us.address = address;
         us.sex = sex;
         [User synchronize];;
         
         result(response,nil);
     }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"%@%@",K_ACTION_RESETPWD,error);
         result(nil, error);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}


#pragma mark = 更新头像
+ (void)updateHeadImg:(NSData *)headData result:(void(^)(CommonActionStatus *response, NSError *error))result
{
    if (!headData)
    {
        return;
    }
    
    NSString *base64Image = [headData base64EncodedStringWithOptions:0];

    NSString *strUrl = [NSString stringWithFormat:@"userId=%@&path=head&head=%@",[User sharedInstance].userid,base64Image];
    
    NSMutableURLRequest *request = [Interface urlRequestWithAicton:K_UPDATE_HEADIMAGE parameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:nil];

         CommonActionStatus *response = [[CommonActionStatus alloc] initWithJSONObject:jsonObject];
         
         result(response,nil);
     }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"%@%@",K_UPDATE_HEADIMAGE,error);
         result(nil, error);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}


#pragma mark = 获取本地头像
+ (void)getLocalHeadImg:(void(^)(NSData *image, NSError *error))result
{
    if (![User sharedInstance].userid)
    {
        return;
    }

    NSString *key = [NSString stringWithFormat:@"userId=%@&path=head", [User sharedInstance].userid];
    
    NSData *headData = [self deserializeFrom:key];
    
    result(headData, nil);
}

#pragma mark = 获取头像

+ (NSString*)getHeadImgUrl
{
    if (![User sharedInstance].userid)
    {
        nil;
    }

    NSString *strUrl = [NSString stringWithFormat:@"%@user/%@.jpeg",K_Image_URL, [User sharedInstance].userid];
    
    return strUrl;
}

//  iuu server does NOT support any Cache-Control policy
//  but iuu server supports Last-Modified, so do NOT use this interface because it depends on cache-control
+ (void)getHeadImgWithResult:(void(^)(NSData *image, NSError *error))result
{
    if (![User sharedInstance].userid)
    {
        return;
    }
    
    //  cache to Documents folder first
    NSString *key = [NSString stringWithFormat:@"userId=%@&path=head", [User sharedInstance].userid];
 
    NSString *strUrl = [NSString stringWithFormat:@"%@user/%@.jpeg",K_Image_URL, [User sharedInstance].userid];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    
    
    request.HTTPMethod = @"GET";
 
    NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSData * headData = operation.responseData;
         
         [self serialize:headData to:key];
         
         result(headData, nil);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSData *headData = [self deserializeFrom:key];
         
         result(headData, nil);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}


#pragma mark = 重置密码

+ (void)resetAction:(NSString *)userId  passWard:(NSString *)passward result:(void(^)(CommonActionStatus *response, NSError *error))result
{
    NSString *strUrl = [NSString stringWithFormat:@"userId=%@&password=%@",userId,passward];

    NSMutableURLRequest *request = [Interface urlRequestWithAicton:K_ACTION_RESETPWD parameters:strUrl];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:nil];
         
         NSLog(@"%@",responseObject);
         CommonActionStatus *response = [[CommonActionStatus alloc] initWithJSONObject:jsonObject];
         
         result(response,nil);
     }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"%@%@",K_ACTION_RESETPWD,error);
         result(nil, error);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

#pragma mark - 登录
+ (void)loginAction:(NSString *)userId  passWard:(NSString *)passward loginName:(NSString *)loginName  ssoaccount:(NSString *)ssoaccount result:(void(^)(LoginResponse *response, NSError *error))result
{
    NSString *strUrl = [NSString stringWithFormat:@"userId=%@&password=%@&loginName=%@&ssoAccount=%@&ssoSource=%@",userId,passward,loginName,ssoaccount,ssoaccount];
    
    NSMutableURLRequest *request = [Interface urlRequestWithAicton:K_ACTION_LOGIN parameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:nil];
         //NSDictionary *jsonObject = [operation.responseData objectFromJSONData];
         
         LoginResponse *response = [[LoginResponse alloc] initWithJSONObject:jsonObject];
         response.message = [jsonObject objectForKey:@"serviceMsg"];
         response.status = [[jsonObject objectForKey:@"userId"] boolValue];
         NSLog(@"login:  %@",jsonObject);
         if (response.status)
         {
             User *user             = [User sharedInstance] ;
             NSDictionary *userDict = jsonObject ;
             user.userid            = [[userDict objectForKey:@"userId"] description];
             user.tel               = [NSString stringWithFormat:@"%@", [userDict objectForKey:@"tel"] ];//认证状态
             user.loginName         = [[userDict objectForKey:@"loginName"] description];
             user.nickname          = [[userDict objectForKey:@"nickName"] description];
             user.sex               = [[userDict objectForKey:@"gender"] description];
             user.userpic           = [[userDict objectForKey:@"imageUrl"] description];
             user.level             = [[userDict objectForKey:@"level"] description];
             user.birthday          = [[userDict objectForKey:@"birthday"] description];
             
             // Format "1989-12-31"
             // Calculate user age
             // Current year
             NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
             
             NSInteger currentYear = [components year];
             
             NSArray *birthArray = [user.birthday componentsSeparatedByString:@"-"];
             if (birthArray.count > 0)
             {
                 user.age = [NSString stringWithFormat:@"%d", (int)currentYear - [birthArray[0] intValue]];
             }
             else
             {
                 user.age               = [[userDict objectForKey:@"age"] description];
             }
             
             user.city              = [[userDict objectForKey:@"city"] description];
             user.credits           = [[userDict objectForKey:@"credits"] description];
             user.desc              = [[userDict objectForKey:@"desc"] description];
             user.email             = [[userDict objectForKey:@"email"] description];
             user.address           = [[userDict objectForKey:@"address"] description];
             user.password          = [[userDict objectForKey:@"password"] description];
             [User synchronize];
         }
         result(response, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         result(nil, error);
     }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

/*
 me_Icon
 参数为：userId，message
*/
#pragma mark -  意见反馈
+ (void)feedBack:(NSString *)userId content:(NSString *)content
          result:(void(^)(CommonActionStatus *response, NSError *error))result
{
    NSString *strUrl = [NSString stringWithFormat:@"userId=%@&message=%@",userId.length==0?@"":userId,content];
    NSLog(@"feedback %@",strUrl);
    NSMutableURLRequest *request = [Interface urlRequestWithAicton:K_ACTION_FEEDBACK parameters:strUrl]; 
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:nil];
         //NSDictionary *jsonObject = [operation.responseData objectFromJSONData];
         VerifyCodeByPgoneResponse *response = [[VerifyCodeByPgoneResponse alloc] initWithJSONObject:jsonObject];
         response.message = [jsonObject objectForKey:@"msg"];
         response.status = [[jsonObject objectForKey:@"status"] boolValue];
         
         NSLog(@"-----%@",jsonObject);
         result(response, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         result(nil, error);
     }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

#pragma mark -  修改密码
+ (void)modifyPassWord:(NSString *)phoneNum password:(NSString *)password code:(NSString *)code
                result:(void(^)(CommonActionStatus *response, NSError *error))result
{
    NSString *strUrl = [NSString stringWithFormat:@"mobile=%@&password=%@&code=%@",phoneNum,password,code];
    NSMutableURLRequest *request = [Interface urlRequestWithAicton:K_ACTION_FINDPWD parameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                                             options:NSJSONReadingAllowFragments
                                                                                               error:nil];

         VerifyCodeByPgoneResponse *response = [[VerifyCodeByPgoneResponse alloc] initWithJSONObject:jsonObject];
         response.message = [jsonObject objectForKey:@"msg"];
         response.status = [[jsonObject objectForKey:@"status"] boolValue];
         if (response.status)
         {
             
         }
         result(response, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         result(nil, error);
     }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}


#pragma mark - 景区地图
+ (void)scenicMap:(NSString *)scenicID result:(void (^)(ScenicMapResponse * response, NSError * error))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@scenicId=%@",K_ACTION_MAP,scenicID];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         

         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         [jsonObject setObject:jsonArr forKey:@"data"];
         [jsonObject setObject:@"成功" forKey:@"msg"];
         [jsonObject setObject:@"1" forKey:@"status"];


         NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
         NSString * path = [paths  objectAtIndex:0];
         NSString * filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"MapNavData%@.plist",scenicID]];
         [jsonObject writeToFile:filePath atomically:YES];


        result([Interface initWithMapNav:jsonObject], nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
         NSString * path = [paths  objectAtIndex:0];
         NSString * filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"MapNavData%@.plist",scenicID]];
         
         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
         result([Interface initWithMapNav:jsonObject], nil);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}
+(ScenicMapResponse *)initWithMapNav:(NSMutableDictionary *)jsonObject
{
    ScenicMapResponse *response = [[ScenicMapResponse alloc] initWithJSONObject:jsonObject];
    response.message = [jsonObject objectForKey:@"msg"];
    response.status = [[jsonObject objectForKey:@"status"] boolValue];
    
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(NSDictionary *json in [jsonObject objectForKey:@"data"])
    {
        ScenicMap *datatemp = [[ScenicMap alloc] init];
        datatemp.lat        = [json objectForKey:@"lat"];
        datatemp.lon        = [json objectForKey:@"lng"];
        datatemp.name       = [json objectForKey:@"scenicPointName"];
        datatemp.mapID      = [json objectForKey:@"id"];
        datatemp.spotType   = [json objectForKey:@"spotType"];
        datatemp.scenicID   = [json objectForKey:@"scenicId"];
        datatemp.audio      = [NSString stringWithFormat:@"%@%@",K_Image_URL,[json objectForKey:@"audioUrl"]];
        [array addObject:datatemp];
    }
    response.mapList = array;

    return response;
}
#pragma mark - 路线规划
+ (void)mapLines:(NSString *)scenicID result:(void (^)(MapLineResponse *, NSError *))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@scenicId=%@",K_ACTION_MAPLINE,scenicID];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         

         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         [jsonObject setObject:jsonArr forKey:@"data"];
         [jsonObject setObject:@"成功" forKey:@"msg"];
         [jsonObject setObject:@"1" forKey:@"status"];
         
         NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
         NSString * path = [paths  objectAtIndex:0];
         NSString * filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"MapNavLine%@.plist",scenicID]];
         [jsonObject writeToFile:filePath atomically:YES];
         
         result([Interface initWithMapNavLine:jsonObject], nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
         NSString * path = [paths  objectAtIndex:0];
         NSString * filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"MapNavLine%@.plist",scenicID]];
         
         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
         result([Interface initWithMapNavLine:jsonObject], nil);     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}
+(MapLineResponse *)initWithMapNavLine:(NSMutableDictionary *)jsonObject{
    MapLineResponse *response = [[MapLineResponse alloc] initWithJSONObject:jsonObject];
    response.message = [jsonObject objectForKey:@"msg"];
    response.status = [[jsonObject objectForKey:@"status"] boolValue];
    

    for(NSDictionary *json in [jsonObject objectForKey:@"data"])
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        for (NSDictionary * dataIn in [json objectForKey:@"lineSectionList"]) {
            MapLine * datetamp = [[MapLine alloc] init];
            datetamp.lineId    = [dataIn objectForKey:@"lineId"];
            datetamp.lat       = [dataIn objectForKey:@"lat"];
            datetamp.lng       = [dataIn objectForKey:@"lng"];
            datetamp.order     = [dataIn objectForKey:@"order"];
            datetamp.spotid    = [dataIn objectForKey:@"spotid"];
            datetamp.spotType  = [dataIn objectForKey:@"spotType"];
            datetamp.spotName  = [dataIn objectForKey:@"spotName"];
            [array addObject:datetamp];
        }
        NSLog(@"%@",[json objectForKey:@"lineName"]);
        if ([[json objectForKey:@"lineName"] isEqualToString:@"畅游路线"]) {
            response.TourList = array;
        }
        
        if ([[json objectForKey:@"lineName"] isEqualToString:@"经典路线"]) {
            response.classicList = array;
        }
    }
    
    return response;
}
#pragma mark - 添加离线地图
+ (void)addOffineMaps:(void (^)(AddMapResponse *, NSError *))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@limit=999&offset=0",K_ACTION_HOME];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         
         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         [jsonObject setObject:jsonArr forKey:@"data"];
         [jsonObject setObject:@"成功" forKey:@"msg"];
         [jsonObject setObject:@"1" forKey:@"status"];
         AddMapResponse *response = [[AddMapResponse alloc] initWithJSONObject:jsonObject];
         response.message = [jsonObject objectForKey:@"msg"];
         response.status = [[jsonObject objectForKey:@"status"] boolValue];
         

         NSMutableArray *array = [[NSMutableArray alloc] init];
         for(NSDictionary *json in [jsonObject objectForKey:@"data"])
         {
             [array addObject:[json objectForKey:@"province"]];
         }
         
         NSMutableArray * cityArray = [[NSMutableArray alloc] init];
         for (NSDictionary *json in [jsonObject objectForKey:@"data"])
         {
             [cityArray addObject:[json objectForKey:@"city"]];
         }
         
         NSSet *set     = [NSSet setWithArray:array];
         NSSet *setCity = [NSSet setWithArray:cityArray];
         
         
         NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
         NSMutableDictionary * isOpenDic = [[NSMutableDictionary alloc] init];
         for (int i = 0; i < [[set allObjects] count]; i++)
         {
             NSMutableArray * proviceArray = [[NSMutableArray alloc] init];
             NSMutableArray * isOpenArray = [[NSMutableArray alloc] init];
              for (NSDictionary * json in [jsonObject objectForKey:@"data"])
              {
                  if ([[[set allObjects] objectAtIndex:i] isEqualToString:[json objectForKey:@"province"]])
                  {
                      [proviceArray addObject:[json objectForKey:@"city"]];
                      [isOpenArray addObject:@"1"];
                  }
              }
             NSSet * proSet = [NSSet setWithArray:proviceArray];
             NSSet * isOpenSet = [NSSet setWithArray:isOpenArray];
             [isOpenDic setObject:[isOpenSet allObjects] forKey:[[set allObjects] objectAtIndex:i]];
             [dic setObject:[proSet allObjects] forKey:[[set allObjects] objectAtIndex:i]];
         }
         
         NSMutableDictionary * scenicDic = [[NSMutableDictionary alloc] init];
         for (int i = 0; i < [[setCity allObjects] count]; i++)
         {
             NSMutableArray * sceniceArr = [[NSMutableArray alloc] init];
             for (NSDictionary * json in [jsonObject objectForKey:@"data"])
             {
                 if ([[[setCity allObjects] objectAtIndex:i] isEqualToString:[json objectForKey:@"city"]])
                 {
                      AddOffineMap * datetamp = [[AddOffineMap alloc] init];
                      datetamp.scenicID       = [json objectForKey:@"scenicId"];
                      datetamp.scenicName     = [json objectForKey:@"scenicName"];
                      datetamp.provice        = [json objectForKey:@"province"];
                      datetamp.pageSize       = [json objectForKey:@"mapSize"];
                      datetamp.city           = [json objectForKey:@"city"];
                     [sceniceArr addObject:datetamp];
                 }
                 
             }
             [scenicDic setObject:sceniceArr forKey:[[setCity allObjects] objectAtIndex:i]];
         }
       
         response.isOpenDic = isOpenDic;
         response.proviceDic = dic;
         response.cityDic = scenicDic;
         result(response, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         result(nil, error);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];

}
#pragma mark - 景区留言
+ (void)scenicComments:(NSString *)scenicID page:(int)page result:(void (^)(ScenicCmtResponse *, NSError *))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@scenicId=%@&limit=100&offset=%d",K_ACTION_SCENICCMT,scenicID,page*10];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         

         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         [jsonObject setObject:jsonArr forKey:@"data"];
         [jsonObject setObject:@"成功" forKey:@"msg"];
         [jsonObject setObject:@"1" forKey:@"status"];
         
         ScenicCmtResponse *response = [self scenicJson2ScenicResponse:jsonObject scenicID:scenicID page:page];
 
         result(response, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSString *keyWord = [NSString stringWithFormat:@"ScenicComment%@%d", scenicID, page];

         NSMutableDictionary *jsonObject = nil;
         NSData *serializedData = [self deserializeFrom:keyWord];
         
         if (serializedData)
         {
             jsonObject = [NSJSONSerialization JSONObjectWithData:serializedData
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
         }

         
         if (!jsonObject)
         {
             jsonObject = [[NSMutableDictionary alloc] init];
             [jsonObject setObject:[[NSArray alloc]init] forKey:@"data"];
             [jsonObject setObject:@"失败" forKey:@"msg"];
             [jsonObject setObject:@"0" forKey:@"status"];
         }
         
         ScenicCmtResponse *response = [self scenicJson2ScenicResponse:jsonObject scenicID:scenicID page:page];
         
         result(response, error);
     }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

+ (ScenicCmtResponse*)scenicJson2ScenicResponse:(NSMutableDictionary *)jsonObject scenicID: (NSString*)scenicID page: (int)page
{
    if (!jsonObject)
    {
        return nil;
    }
    
    ScenicCmtResponse *response = [[ScenicCmtResponse alloc] initWithJSONObject:jsonObject];
    if (!response)
    {
        return nil;
    }
    response.message = [jsonObject objectForKey:@"msg"];
    response.status = [[jsonObject objectForKey:@"status"] boolValue];
    
    
    NSString *keyWord = [NSString stringWithFormat:@"ScenicComment%@%d", scenicID, page];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    
    [self serialize:jsonData to:keyWord];
    
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for(NSDictionary *json in [jsonObject objectForKey:@"data"])
    {
        if (!json)
        {
            continue;
        }
        
        ScenicCmts * datetamp = [[ScenicCmts alloc] init];
        datetamp.age          = [json objectForKey:@"age"];
        
        NSDateFormatter *decodeFormatter = [[NSDateFormatter alloc] init];
        [decodeFormatter setDateFormat: @"yyyyMMddHHmmss"];
        NSDate *decodedDate = [decodeFormatter dateFromString:[json objectForKey:@"commentTime"]];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"MM月dd日 HH:mm"];
        datetamp.commentTime = [formatter stringFromDate:decodedDate];

        
        
        datetamp.content      = [json objectForKey:@"content"];
        datetamp.gender       = [json objectForKey:@"gender"];
        datetamp.userId       = [json objectForKey:@"userId"];
        datetamp.userName     = [json objectForKey:@"userName"];
        datetamp.commentId    = [json objectForKey:@"commentId"];
        [array addObject:datetamp];
    }
    
    response.cmtList = array;
    
    return response;
}

#pragma mark - 发送景区留言
+ (void)sendScenicComment:(NSString *)userid UserName:(NSString *)username Age:(NSString *)age ScenicID:(NSString *)scenicid Content:(NSString *)content Gender:(NSString *)gender result:(void (^)(SendScenicResponse *, NSError *))result
{
    NSString *strUrl = [NSString stringWithFormat:@"userId=%@&scenicId=%@&content=%@&gender=%@&userName=%@&age=%@",userid,scenicid,content,gender,username,age];
    
    NSMutableURLRequest *request =[Interface urlRequestWithAicton:K_ACTION_SENDSCENICCMT parameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         
         
         SendScenicResponse *response = [[SendScenicResponse alloc] initWithJSONObject:jsonObject];
         response.message             = [jsonObject objectForKey:@"serviceMsg"];
         response.status              = ![[jsonObject objectForKey:@"stateCode"] boolValue];
         NSLog(@"login:  %@",jsonObject);
         result(response, nil);
         
         NSLog(@"%@%@",K_ACTION_SENDSCENICCMT,jsonObject);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"%@%@",K_ACTION_SENDSCENICCMT,error);
         result(nil, error);
     }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}
#pragma mark - 景区点赞
+ (void)praiseScenic:(NSString *)scenicID UserID:(NSString *)userid result:(void (^)(PraiseScenicResponse *, NSError *))result
{
    NSString *keyWord = [NSString stringWithFormat:@"ScenicPraise%@%@", userid, scenicID];
    NSData *data = [self deserializeFrom:keyWord];

    if (data)
    {
        PraiseScenicResponse *response = [[PraiseScenicResponse alloc] init];
        response.message = @"已经点过赞";
        response.status = 0;

        result(response, nil);
        
        return;
    }
    
    NSString *strUrl = [NSString stringWithFormat:@"userId=%@&scenicId=%@",userid,scenicID];
    
    NSMutableURLRequest *request =[Interface urlRequestWithAicton:K_ACTION_SCENICPRAISE parameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         
         
         PraiseScenicResponse *response = [[PraiseScenicResponse alloc] initWithJSONObject:jsonObject];
         response.message = [jsonObject objectForKey:@"serviceMsg"];
         response.status = ![[jsonObject objectForKey:@"stateCode"] boolValue];
         

         if (response.status == 1)
         {
             NSString *keyWord = [NSString stringWithFormat:@"ScenicPraise%@%@", userid, scenicID];
             
             NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                                options:NSJSONWritingPrettyPrinted
                                                                  error:nil];
             
             [self serialize:jsonData to:keyWord];
         }
         
         result(response, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         PraiseScenicResponse *response = [[PraiseScenicResponse alloc] init];
         response.message = @"Network Failure";
         response.status = 2;
         
         NSLog(@"%@%@",K_ACTION_SCENICPRAISE,error);
         result(response, error);
     }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

#pragma mark - 获取地图最后更新时间（服务器）
+ (void)getMapLastUpdateTime:(NSString *)scenicID result:(void(^)(UpDateMapResponse *response,NSError *error))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@scenicIds=%@",K_ACTION_UPDATEMAP,scenicID];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         

         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         [jsonObject setObject:jsonArr forKey:@"data"];
         [jsonObject setObject:@"成功" forKey:@"msg"];
         [jsonObject setObject:@"1" forKey:@"status"];
         UpDateMapResponse *response = [[UpDateMapResponse alloc] initWithJSONObject:jsonObject];
         response.message = [jsonObject objectForKey:@"msg"];
         response.status = [[jsonObject objectForKey:@"status"] boolValue];
         
         NSMutableArray *array = [[NSMutableArray alloc] init];
         
         for(NSDictionary *json in [jsonObject objectForKey:@"data"])
         {
             UpDateData * datetemp = [[UpDateData alloc] init];
             datetemp.scenicId     = [json objectForKey:@"scenicId"];
             datetemp.mapVersion   = [[json objectForKey:@"mapVersion"] description];
             [array addObject:datetemp];
         }
         response.date = array;
         result(response, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         result(nil, error);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}
#pragma mark - 地图广告
+ (void)mapAdvert:(NSString *)scenicID result:(void(^)(MapAdvertResponse *response,NSError *error))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@scenicId=%@",K_ACTION_MAPADVERT,scenicID];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         

         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         [jsonObject setObject:jsonArr forKey:@"data"];
         [jsonObject setObject:@"成功" forKey:@"msg"];
         [jsonObject setObject:@"1" forKey:@"status"];
         MapAdvertResponse *response = [[MapAdvertResponse alloc] initWithJSONObject:jsonObject];
         response.message = [jsonObject objectForKey:@"msg"];
         response.status = [[jsonObject objectForKey:@"status"] boolValue];
         
         NSMutableArray *array = [[NSMutableArray alloc] init];
         
         for(NSDictionary *json in [jsonObject objectForKey:@"data"])
         {
             MapAdvertData * datetemp = [[MapAdvertData alloc] init];
             datetemp.scenicId        = [json objectForKey:@"scenicId"];
             datetemp.scenicName      = [json objectForKey:@"advertScenicName"];
             datetemp.advertPic       = [NSString stringWithFormat:@"%@%@",K_Image_URL,[json objectForKey:@"advertPic"]];
             [array addObject:datetemp];
         }
         response.advertArray = array;
         result(response, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         result(nil, error);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

#pragma mark - 是否在审核期
+ (void)isPublishedInAppStor:(void(^)(AppstoreResponse *response,NSError *error))result
{
#ifdef DEBUG
    AppstoreResponse *response = [[AppstoreResponse alloc] init];
    response.message = nil;
    response.status = 1;
    

    response.isAppStrore = YES;
    result(response, nil);
#else
    NSString *strUrl = [NSString stringWithFormat:@"%@",K_ACTION_ISPUBLISHEDINAPPSTORE];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         
         
         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         [jsonObject setObject:jsonArr forKey:@"data"];
         [jsonObject setObject:@"成功" forKey:@"msg"];
         [jsonObject setObject:@"1" forKey:@"status"];
         AppstoreResponse *response = [[AppstoreResponse alloc] initWithJSONObject:jsonObject];
         response.message = [jsonObject objectForKey:@"msg"];
         response.status = [[jsonObject objectForKey:@"status"] boolValue];
         response.isAppStrore = [[[[jsonObject objectForKey:@"data"] objectForKey:@"isAppStrore"] description] boolValue];
         result(response, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

         AppstoreResponse *response = [[AppstoreResponse alloc] init];
         response.message = nil;
         response.status = 1;
         response.isAppStrore = NO;
         result(response, nil);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
#endif
}



#pragma mark - token发送给服务器
+ (void)sendPushToken:(NSString *)token  recv_msg:(NSString *)recv_msg result:(void(^)(CommonActionStatus *response,NSError *error))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@devicetoken=%@&recv_msg=%@",K_ACTION_PUSHTOKEN,token,recv_msg];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         
         
         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         [jsonObject setObject:jsonArr forKey:@"data"];
         [jsonObject setObject:@"成功" forKey:@"msg"];
         [jsonObject setObject:@"1" forKey:@"status"];
         CommonActionStatus *response = [[CommonActionStatus alloc] initWithJSONObject:jsonObject];
         
         result(response, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         result(nil, error);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];

}

#pragma mark - 参加抽奖
+ (void)getLottery:(void(^)(LuckyDrawerResponse *response,NSError *error))result
{
    NSLog(@"%@",[User sharedInstance].password);
    NSLog(@"%@",[User sharedInstance].userid);
    NSString *md5Pwd = [[User sharedInstance].password md5];
    NSString *md5Pwd16bit = [md5Pwd substringWithRange:NSMakeRange(8, 16)];
    NSString *strUrl = [NSString stringWithFormat:@"%@userId=%@&password=%@",K_ACTION_LOTTERY,[User sharedInstance].userid, [md5Pwd16bit uppercaseString]];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         
         
         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         [jsonObject setObject:jsonArr forKey:@"data"];
         

         LuckyDrawerResponse *response = [[LuckyDrawerResponse alloc] initWithJSONObject:jsonObject];
         
         // Convert to dictionary
         NSDictionary *dataDic = [jsonObject objectForKey:@"data"];
         if (dataDic && dataDic.count > 0)
         {
             response.message = [dataDic objectForKey:@"errorMessage"];
             response.status  = [[dataDic objectForKey:@"status"] intValue];
             response.luckyDrawerData = [[LuckyDrawerData alloc]init];
             response.luckyDrawerData.prizeLevel = [dataDic objectForKey:@"prizeLevel"];
             response.luckyDrawerData.prizeName  = [dataDic objectForKey:@"prizeName"];
             response.luckyDrawerData.remainNum  = [dataDic objectForKey:@"remainNum"];
         }
         else
         {
             response.message = @"获取失败";
             response.status  = 1;
             response.luckyDrawerData = [[LuckyDrawerData alloc]init];
             response.luckyDrawerData.prizeLevel = nil;
             response.luckyDrawerData.prizeName  = nil;
             response.luckyDrawerData.remainNum  = nil;
         }

  
         result(response, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         LuckyDrawerResponse *response = [[LuckyDrawerResponse alloc] init];
         response.message = @"获取失败";
         response.status  = 1;
         response.luckyDrawerData = [[LuckyDrawerData alloc]init];
         response.luckyDrawerData.prizeLevel = nil;
         response.luckyDrawerData.prizeName  = nil;
         response.luckyDrawerData.remainNum  = nil;

         result(nil, error);
     }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

#pragma mark - 查询我的获奖记录
+ (void)queryMyPrizeList:(void(^)(LotteryWinnerListResponse *response,NSError *error))result
{
    NSLog(@"%@",[User sharedInstance].password);
    NSLog(@"%@",[User sharedInstance].userid);
    NSString *strUrl = [NSString stringWithFormat:@"%@&userId=%@",K_ACTION_QUERYLOTTERY,[User sharedInstance].userid];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         
         
         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         [jsonObject setObject:jsonArr forKey:@"data"];
         LotteryWinnerListResponse *response = [[LotteryWinnerListResponse alloc] initWithJSONObject:jsonObject];
         
         // Convert to dictionary
         NSDictionary *jsonDic = [jsonObject objectForKey:@"data"];
         
         if (jsonDic && jsonDic.count > 0)
         {
             response.message = [jsonDic objectForKey:@"message"];

             
             //if ([response.message isEqualToString:@"成功"])
             {
                 response.status = 1;
                 NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                                    options:NSJSONWritingPrettyPrinted
                                                                      error:nil];
                 
                 [self serialize:jsonData to:@"mylastestprizelist"];
             }

             [jsonObject setObject:@"成功" forKey:@"msg"];
             [jsonObject setObject:@"1" forKey:@"status"];
         }
         else
         {
             [jsonObject setObject:@"失败" forKey:@"msg"];
             [jsonObject setObject:@"0" forKey:@"status"];
         }
         
         result([Interface winnerListJson2WinnerListResponse:jsonObject], nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSMutableDictionary *jsonObject = nil;
         NSData *serializedData = [self deserializeFrom:@"mylastestprizelist"];
         
         if (serializedData)
         {
             jsonObject = [NSJSONSerialization JSONObjectWithData:serializedData
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
         }
         
         if (!jsonObject)
         {
             jsonObject = [[NSMutableDictionary alloc] init];
             [jsonObject setObject:[[NSArray alloc]init] forKey:@"data"];
             [jsonObject setObject:@"失败" forKey:@"msg"];
             [jsonObject setObject:@"0" forKey:@"status"];
         }
         
         result ([Interface winnerListJson2WinnerListResponse:jsonObject], nil);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

#pragma mark - 查询获奖用户列表
+ (void)queryWinnerList:(void(^)(LotteryWinnerListResponse *response,NSError *error))result
{
    NSLog(@"%@",[User sharedInstance].password);
    NSLog(@"%@",[User sharedInstance].userid);
    NSString *strUrl = [NSString stringWithFormat:@"%@",K_ACTION_QUERYLATEST];
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         
         
         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         [jsonObject setObject:jsonArr forKey:@"data"];
         
         
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
         
         [self serialize:jsonData to:@"lastestlotterywinnerlist"];
         
         
         result([Interface winnerListJson2WinnerListResponse:jsonObject], nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSMutableDictionary *jsonObject = nil;
         NSData *serializedData = [self deserializeFrom:@"lastestlotterywinnerlist"];
         
         if (serializedData)
         {
             jsonObject = [NSJSONSerialization JSONObjectWithData:serializedData
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
         }
         
         if (!jsonObject)
         {
             jsonObject = [[NSMutableDictionary alloc] init];
             [jsonObject setObject:[[NSArray alloc]init] forKey:@"data"];
             [jsonObject setObject:@"失败" forKey:@"msg"];
             [jsonObject setObject:@"0" forKey:@"status"];
         }
         
         result ([Interface winnerListJson2WinnerListResponse:jsonObject], nil);
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}


+(LotteryWinnerListResponse *)winnerListJson2WinnerListResponse:(NSMutableDictionary *)jsonObject
{
    if (!jsonObject)
    {
        return nil;
    }
    
    LotteryWinnerListResponse *response = [[LotteryWinnerListResponse alloc] initWithJSONObject:jsonObject];
    if (!response)
    {
        return nil;
    }

    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NSDictionary *dataDic = [jsonObject objectForKey:@"data"];
    
    if (dataDic && dataDic.count > 0)
    {
        NSArray *listArray = [dataDic objectForKey:@"prizeList"];
        
        if (listArray && listArray.count > 0)
        {
            for (NSDictionary *json in listArray)
            {
                PrizeWinner *winnerInfo   = [[PrizeWinner alloc] init];
                winnerInfo.userPortrait   = [json objectForKey:@"userPortrait"];
                winnerInfo.userName       = [json objectForKey:@"userName"];
                winnerInfo.userLocation   = [json objectForKey:@"userLocation"];
                winnerInfo.prizeName      = [json objectForKey:@"prizeName"];

                winnerInfo.prizeCode      = [json objectForKey:@"prizeCode"];
                winnerInfo.prizeLevel     = [json objectForKey:@"prizeLevel"];
                winnerInfo.exchangeStatus = [json objectForKey:@"exchangeStatus"];
                winnerInfo.endAngle       = [json objectForKey:@"endAngle"];
                winnerInfo.startAngle     = [json objectForKey:@"startAngle"];
                
                
                [result addObject:winnerInfo];
            }
        }
        
        response.message = @"成功";
        response.status = 1;
    }
    
    response.winnerList = result;
    return response;
}

#pragma mark - 查询天气信息
+ (void)getScenicWeather:(NSString *)scenicID result:(void(^)(ScenicWeatherResponse *response,NSError *error))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@scenicId=%@", K_ACTION_WEATHER, scenicID];
    
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         

         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         [jsonObject setObject:jsonArr forKey:@"data"];
         [jsonObject setObject:@"成功" forKey:@"msg"];
         [jsonObject setObject:@"1" forKey:@"status"];
         
         NSString *keyWord = [NSString stringWithFormat:@"%@____%@", @"ScenicWeather", scenicID];
         
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
         
         [self serialize:jsonData to:keyWord];
         
         
         
         ScenicWeatherResponse *response = [self scenicWeatherJson2WeatherResponse:jsonObject];
         result(response, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         NSString *keyWord = [NSString stringWithFormat:@"%@____%@", @"ScenicWeather", scenicID];
         

         NSMutableDictionary *jsonObject = nil;
         NSData *serializedData = [self deserializeFrom:keyWord];
         
         if (serializedData)
         {
             jsonObject = [NSJSONSerialization JSONObjectWithData:serializedData
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
         }
         
         
         if (!jsonObject)
         {
             jsonObject = [[NSMutableDictionary alloc] init];
             [jsonObject setObject:[[NSArray alloc]init] forKey:@"data"];
             [jsonObject setObject:@"失败" forKey:@"msg"];
             [jsonObject setObject:@"0" forKey:@"status"];
         }
         
         ScenicWeatherResponse *response = [self scenicWeatherJson2WeatherResponse:jsonObject];
         
         result(response, error);
     }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}


+ (ScenicWeatherResponse*)scenicWeatherJson2WeatherResponse:(NSMutableDictionary *)jsonObject
{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    
    NSDictionary *dataDic = [jsonObject objectForKey:@"data"];
    
    if (dataDic && dataDic.count > 0)
    {
        NSArray *weatherArray = [dataDic objectForKey:@"weatherInfs"];
        //for (int i = 0; i < [weatherArray count]; i ++)
        {
            // NSArray *weatherInfoArray = [dataArray objectAtIndex:i];
            for(NSDictionary *json in weatherArray)
            {
                WeatherModel *weatherData   = [[WeatherModel alloc] init];
                weatherData.date            = json[@"date"];
                weatherData.tempertureOfDay = json[@"tempertureOfDay"];
                weatherData.weather         = json[@"weather"];
                
                [resultArr addObject:weatherData];
            }
        }
    }
    
    ScenicWeatherResponse *response = [[ScenicWeatherResponse alloc] initWithJSONObject:jsonObject];
    response.weatherList = resultArr;
    
    return response;
}


+ (void)getMyComments:(NSString*)sceneId result:(void(^)(MyCommentsResponse *response,NSError *error))result
{
    NSString *strUrl = [NSString stringWithFormat:@"%@userId=%@&limit=100&offset=0", K_ACTION_MYCOMMENTS, sceneId];
    
    NSMutableURLRequest *request = [Interface method:@"GET" requestWithparameters:strUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
         
         
         NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
         [jsonObject setObject:jsonArr forKey:@"data"];
         [jsonObject setObject:@"成功" forKey:@"msg"];
         [jsonObject setObject:@"1" forKey:@"status"];
         
         NSString *keyWord = [NSString stringWithFormat:@"%@____%@", @"MyCommentsList", sceneId];
         
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
         
         [self serialize:jsonData to:keyWord];
         
         MyCommentsResponse *response = [self myCommentsJson2MyCommentsResponse:jsonObject];
         result(response, nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         NSString *keyWord = [NSString stringWithFormat:@"%@____%@", @"MyCommentsList", sceneId];
         
         
         NSMutableDictionary *jsonObject = nil;
         NSData *serializedData = [self deserializeFrom:keyWord];
         
         if (serializedData)
         {
             jsonObject = [NSJSONSerialization JSONObjectWithData:serializedData
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
         }
         
         
         if (!jsonObject)
         {
             jsonObject = [[NSMutableDictionary alloc] init];
             [jsonObject setObject:[[NSArray alloc]init] forKey:@"data"];
             [jsonObject setObject:@"失败" forKey:@"msg"];
             [jsonObject setObject:@"0" forKey:@"status"];
         }
         
         MyCommentsResponse *response = [self myCommentsJson2MyCommentsResponse:jsonObject];
         result(response, error);
     }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}


+ (MyCommentsResponse*)myCommentsJson2MyCommentsResponse:(NSMutableDictionary *)jsonObject
{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    
    NSArray *dataArray = [jsonObject objectForKey:@"data"];
    
    for(NSDictionary *json in dataArray)
    {
        MyComment *myComment   = [[MyComment alloc] init];
        myComment.commentTime            = json[@"commentTime"];
        myComment.content            = json[@"content"];
        myComment.scenicId = json[@"scenicId"];

        [resultArr addObject:myComment];
    }
    
    MyCommentsResponse *response = [[MyCommentsResponse alloc] initWithJSONObject:jsonObject];
    response.commentsList = resultArr;
    
    return response;
}

@end
