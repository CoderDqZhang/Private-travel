#import "LabelSize.h"
static LabelSize * plabelsize = nil;
@implementation LabelSize
+(id)labelsizeManger
{
    if (plabelsize == nil) {
        plabelsize = [LabelSize new];

    }
    return plabelsize;
}
- (CGSize)labelAutoCalculateRectWith:(NSString*)text FontSize:(CGFloat)fontSize MaxSize:(CGSize)maxSize

{
  
    CGRect labelRect = [text boundingRectWithSize:maxSize options:(NSStringDrawingTruncatesLastVisibleLine |
                                                                   NSStringDrawingUsesLineFragmentOrigin |
                                                                   NSStringDrawingUsesFontLeading) attributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontSize] forKey:NSFontAttributeName]context:nil];
    
    
    CGSize labelsize = CGSizeMake(labelRect.size.width, labelRect.size.height);
    
    
    labelsize.width = ceil(labelsize.width);
    labelsize.height = ceil(labelsize.height) ;
    if (text.length == 0) {
        labelsize = CGSizeMake(0, 0);
    }
    return labelsize;
    
}

- (CGSize)getStringRect:(NSString*)aString MaxSize:(CGSize)maxSize FontSize:(CGFloat)flt

{
    UIFont *font = [UIFont systemFontOfSize:flt];
    
    
    CGRect labelRect = [aString boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin) attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]context:nil];
    

    
    return labelRect.size;
    
    
}
@end
