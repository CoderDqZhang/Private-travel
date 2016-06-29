//
//  md5.h
//  BaoRuanReader
//
//  Created by li huanhuan on 1/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (MyExtensions)
- (NSString *) md5;
@end

@interface NSData (MyExtensions)
- (NSString*)md5;
@end

