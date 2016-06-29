//  Deprecated
//  Used by ScenicSpotGuideViewController only

#import "NetTools.h"

#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#import <dlfcn.h>
//#import "wwanconnect.h“//frome apple 你可能没有哦
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"

static NetStatus netStatus;

@implementation NetTools

+ (NetStatus)LoadCurrntNet{
    
    Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:// 没有网络连接
            netStatus = NetStatusNone;
            break;
        case ReachableViaWWAN:// 使用3G网络
            netStatus = NetStatus3G;
            break;
        case ReachableViaWiFi:// 使用WiFi网络
            netStatus = NetStatusWifi;
            break;
    }
    return netStatus;
}

+ (NetStatus)GetCurrntNet{
    [self LoadCurrntNet];
    return netStatus;
}

+ (NSString *)EncodeToPercentEscapeString: (NSString *) input{  
    // Encode all the reserved characters, per RFC 3986  
    // (<http://www.ietf.org/rfc/rfc3986.txt>)  
    NSString *outputStr = (NSString *)   
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,  
                                            (__bridge CFStringRef)input,
                                            NULL,  
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",  
                                            kCFStringEncodingUTF8));  
    return outputStr;  
}

+ (NSString*)GetVersionFromServer
{
//    NSDictionary *versionDict = [NetTools HttpGetJSONDictionary:Version_URL];
//    return [versionDict objectForKey:App_Update_Version];
    return @"";
}

+ (NSString*)HttpPost:(NSString *)urlStr datas:(NSDictionary *)datas {
    NSMutableString *postStr = [[NSMutableString alloc] init];
    for (NSString *key in [datas keyEnumerator]) {
        NSString *value = [datas objectForKey:key];
       // NSLog(@"key=%@, value=%@", key, value);
        [postStr appendFormat:@"%@=%@&", key, [self EncodeToPercentEscapeString:value]];
    }
    
    NSURL *url=[NSURL URLWithString:urlStr];
    
    NSData *postData = [postStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%ld", (long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    // [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
    
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSString *data=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
    return data;
}

#define HTTP_CONTENT_BOUNDARY @"kn9j23tv"

+ (NSDictionary*)HttpPostJSONDictionary:(NSString *)urlStr datas:(NSDictionary *)datas paramPrifix:(NSString*)prefix filePath:(NSString*)filePath dataType:(NSString*)fileType {
    @try {
        urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL* url = [NSURL URLWithString:urlStr];
        
        NSMutableData *httpBody = [NSMutableData data];
        //处理数据部分
        if (datas != nil) {
            for (NSString *key in [datas keyEnumerator]) {
                NSString *value = [datas objectForKey:key];
                NSString *dataBegin = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n", HTTP_CONTENT_BOUNDARY, key];
                [httpBody appendData:[dataBegin dataUsingEncoding:NSUTF8StringEncoding]];
                [httpBody appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
                [httpBody appendData:[NSData dataWithBytes:"\n" length:1]];
            }
        }
        
        //处理文件部分
        NSData* fileData = [NSData dataWithContentsOfFile:filePath];
        NSString* fileName = [filePath lastPathComponent];
        NSString* strBodyEnd = [NSString stringWithFormat:@"\r\n--%@--\r\n",HTTP_CONTENT_BOUNDARY];
        
        NSString* strBodyBegin = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n", HTTP_CONTENT_BOUNDARY, @"fileUpload", fileName, fileType];
        [httpBody appendData:[strBodyBegin dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:fileData];
        [httpBody appendData:[strBodyEnd dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        [request setTimeoutInterval: 60000];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)httpBody.length] forHTTPHeaderField:@"Content-Length"];
        [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",HTTP_CONTENT_BOUNDARY] forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:httpBody];
        
        NSHTTPURLResponse* httpResponse = nil;
        NSError *error = [[NSError alloc] init];
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:&error];
        if (httpResponse == nil) {
            NSLog(@"url: %@\nerror_code: %@", urlStr, error);
            return nil;
        }
        else {
            [httpBody writeToFile:[[FileTools defaultTools] GetFullFilePathInDocuments:@"debug-request.htm"] atomically:YES];
            [responseData writeToFile:[[FileTools defaultTools] GetFullFilePathInDocuments:@"debug-response.htm"] atomically:YES];
            NSDictionary *returnData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
            if (error != nil) {
                NSLog(@"error:%@", error);
                NSLog(@"return data: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                [httpBody writeToFile:[[FileTools defaultTools] GetFullFilePathInDocuments:@"debug-request.htm"] atomically:YES];
                [responseData writeToFile:[[FileTools defaultTools] GetFullFilePathInDocuments:@"debug-response.htm"] atomically:YES];
            }
            return returnData;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception:%@", exception);
    }
    @finally {
        return nil;
    }
}

+ (NSDictionary*)HttpPostJSONDictionary:(NSString *)urlStr datas:(NSDictionary *)datas paramPrifix:(NSString*)prefix{
    NSMutableString *postStr = [[NSMutableString alloc] init];
    for (NSString *key in [datas keyEnumerator]) {
        NSString *value = [datas objectForKey:key];
//        NSLog(@"key=%@, value=%@", key, value);
        if (prefix == nil) {
            [postStr appendFormat:@"%@=%@&", key, [self EncodeToPercentEscapeString:value]];
        }
        else {
            [postStr appendFormat:@"%@.%@=%@&", prefix, key, [self EncodeToPercentEscapeString:value]];
        }
    }
    NSError *error;
    NSURL *url=[NSURL URLWithString:urlStr];
    
    NSData *postData = [postStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    //NSData *postData = [NSJSONSerialization dataWithJSONObject:datas options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *postLength = [NSString stringWithFormat:@"%ld", (long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    // [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
    
    NSURLResponse *response;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error != nil) {
        NSLog(@"error:%@", error);
    }
    NSLog(@"urlData:%@", urlData);
    if (urlData != nil) {
        NSDictionary *returnData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingAllowFragments error:&error];
        if (error != nil) {
            NSLog(@"error:%@", error);
            NSLog(@"return data: %@", [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding]);
            [postData writeToFile:[[FileTools defaultTools] GetFullFilePathInDocuments:@"debug-request.htm"] atomically:YES];
            [urlData writeToFile:[[FileTools defaultTools] GetFullFilePathInDocuments:@"debug-response.htm"] atomically:YES];
        }
        return returnData;
    }
    else {
        return nil;
    }
}


+ (NSString*)HttpGet:(NSString*)url {
    NSError *error;
    NSString *data = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:&error];
    return data;
}

+ (NSArray*)HttpGetJSONArray:(NSString*)urlStr {
    NSURL *url=[NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    
    // [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
    
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (urlData != nil) {
        return [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingAllowFragments error:&error];
    }
    else {
        return nil;
    }
}

+ (NSDictionary*)HttpGetJSONDictionary:(NSString*)urlStr {
    NSURL *url=[NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    
    // [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
    
    NSError *error;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (urlData != nil) {
        return [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingAllowFragments error:&error];
    }
    else {
        return nil;
    }
}

+ (NSString *)GetCurrentIP {
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"])  // Wi-Fi adapter
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil;
}

+ (NSString *) stringFromAddress: (const struct sockaddr *) address
{
    if(address && address->sa_family == AF_INET) {
        const struct sockaddr_in* sin = (struct sockaddr_in*) address;
        return [NSString stringWithFormat:@"%@:%d", [NSString stringWithUTF8String:inet_ntoa(sin->sin_addr)], ntohs(sin->sin_port)];
    }
    
    return nil;
}

+ (BOOL)download:(NSString*)urlStr andSaveTo:(NSString*)filePath {
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
    if (data != nil) {
        [data writeToFile:filePath atomically:YES];
        return TRUE;
    }
    return FALSE;
}
@end
