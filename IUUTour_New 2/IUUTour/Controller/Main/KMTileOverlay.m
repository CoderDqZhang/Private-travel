#import "KMTileOverlay.h"

@implementation KMTileOverlay
- (void)loadTileAtPath:(MATileOverlayPath)path result:(void (^)(NSData *tileData, NSError *error))result
{
    //    NSBundle *mainBundle = [NSBundle mainBundle];
    //NSString *imagePath = [mainBundle pathForResource:@"purplePin" ofType:@"png"];
    UIImage *image = [[UIImage alloc] init];
    image = [[UIColor grayColor] image];
    
    NSData * data;
    if (UIImagePNGRepresentation(image) == nil) {
        
        data = UIImageJPEGRepresentation(image, 1);
        
    } else {
        
        data = UIImagePNGRepresentation(image);
    }

    NSError *error = nil;

    result(data,error);
}
@end
