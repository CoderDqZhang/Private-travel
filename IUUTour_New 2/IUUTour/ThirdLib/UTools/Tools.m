#import "Tools.h"

@implementation Tools


+ (CGSize)returnSizeWithStr:(NSString *)str andBaseSize:(CGSize)bSize andBaseFont:(NSInteger)bFont
{
    CGSize s = [str boundingRectWithSize:bSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:bFont]} context:nil].size;
    
    return s;
}
@end
