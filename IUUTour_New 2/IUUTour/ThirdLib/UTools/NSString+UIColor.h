#import <Foundation/Foundation.h>

// 用于扩展NSString,转换UIColor
@interface NSString (UIColor)

// 获取由当前的NSString转换来的UIColor
- (UIColor*)color;

@end
