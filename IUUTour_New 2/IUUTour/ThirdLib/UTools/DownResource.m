#import "DownResource.h"
static DownResource * plabelsize = nil;

@implementation DownResource
+ (id)DownResourceManger
{
    if (plabelsize == nil) {
        plabelsize = [DownResource new];
        
    }
    return plabelsize;
}
-(UIImage *) getImageFromURL:(NSString *)fileURL {
    NSLog(@"执行图片下载函数");
    __block UIImage * result;
//   
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];

//    });
    return result;
}


-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    dispatch_queue_t globalQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //异步执行队列任务
    dispatch_async(globalQueue, ^{
        if ([[extension lowercaseString] isEqualToString:@"png"]) {
            [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
        } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {

            [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
        } else {
            //ALog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
            NSLog(@"文件后缀不认识");
        }
    });

}

- (void)getVoiceURL:(NSString *)fileURL Voice:(NSString *)voiceName
{
    dispatch_queue_t globalQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    //异步执行队列任务
    dispatch_async(globalQueue, ^{
    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    [data writeToFile:[documentsDirectoryPath stringByAppendingPathComponent:voiceName]  atomically:YES];
        });
}

@end
