//
//  MyComment.h
//  IUUTour
//
//  Created by Vincent on 15/11/26.
//  Copyright © 2015 DevDiv Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyComment : NSObject<NSCoding>
@property (nonatomic, copy)  NSString *commentTime;
@property (nonatomic, copy)  NSString *content;
@property (nonatomic, copy)  NSString *scenicId;
@end
