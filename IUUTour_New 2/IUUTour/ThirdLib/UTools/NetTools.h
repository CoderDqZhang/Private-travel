//  Deprecated
//  Used by ScenicSpotGuideViewController only

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


typedef enum {
    NetStatusNone,
    NetStatus3G,
	NetStatusWifi
} NetStatus;

@interface NetTools : NSObject {

}

+ (NetStatus)LoadCurrntNet;
+ (NetStatus)GetCurrntNet;
+ (NSString *)EncodeToPercentEscapeString: (NSString *) input;

+ (NSString*)GetVersionFromServer;

+ (NSString*)HttpPost:(NSString*)url datas:(NSDictionary*)datas;
+ (NSString*)HttpGet:(NSString*)url;

+ (NSArray*)HttpGetJSONArray:(NSString*)urlStr;
+ (NSDictionary*)HttpGetJSONDictionary:(NSString*)urlStr;
+ (NSDictionary*)HttpPostJSONDictionary:(NSString *)urlStr datas:(NSDictionary *)datas paramPrifix:(NSString*)prefix;
+ (NSDictionary*)HttpPostJSONDictionary:(NSString *)urlStr datas:(NSDictionary *)datas paramPrifix:(NSString*)prefix filePath:(NSString*)filePath dataType:(NSString*)fileType;

+ (NSString*)GetCurrentIP;

+ (BOOL)download:(NSString*)urlStr andSaveTo:(NSString*)filePath;
@end
