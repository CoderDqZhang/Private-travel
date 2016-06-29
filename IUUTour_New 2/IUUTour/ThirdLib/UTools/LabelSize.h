#import <Foundation/Foundation.h>

@interface LabelSize : NSObject

+ (id)labelsizeManger;

- (CGSize)labelAutoCalculateRectWith:(NSString*)text FontSize:(CGFloat)fontSize MaxSize:(CGSize)maxSize;

- (CGSize)getStringRect:(NSString*)aString MaxSize:(CGSize)maxSize FontSize:(CGFloat)flt;
@end
