//
//  MyComment.m
//  IUUTour
//
//  Created by Vincent on 15/11/26.
//  Copyright © 2015 DevDiv Technology. All rights reserved.
//

#import "MyComment.h"

@implementation MyComment
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.commentTime forKey:@"commentTime"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.scenicId forKey:@"scenicId"];
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.commentTime     = [aDecoder decodeObjectForKey:@"commentTime"];
        self.content   = [aDecoder decodeObjectForKey:@"content"];
        self.scenicId   = [aDecoder decodeObjectForKey:@"scenicId"];
    }
    
    return self;
}
@end
