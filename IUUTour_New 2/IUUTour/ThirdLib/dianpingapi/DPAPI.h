//
//  DPAPI.h
//  apidemo
//
//  Created by ZhouHui on 13-1-28.
//  Copyright (c) 2013年 Dianping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPRequest.h"

#define kDPAppKey             @"9699551594"
#define kDPAppSecret          @"f2acc603b7d248b7b0521023496a0a1a"

#ifndef kDPAppKey
#error
#endif

#ifndef kDPAppSecret
#error
#endif

@interface DPAPI : NSObject

- (DPRequest*)requestWithURL:(NSString *)url
					  params:(NSMutableDictionary *)params
					delegate:(id<DPRequestDelegate>)delegate;

- (DPRequest *)requestWithURL:(NSString *)url
				 paramsString:(NSString *)paramsString
					 delegate:(id<DPRequestDelegate>)delegate;


- (void)cancelRunningRequests;

@end
