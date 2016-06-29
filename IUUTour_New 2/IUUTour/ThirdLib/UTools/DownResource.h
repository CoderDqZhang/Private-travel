#import <Foundation/Foundation.h>

@interface DownResource : NSObject
@property (nonatomic,retain) NSMutableData * receivedData;
@property (nonatomic,retain) NSString * voiceName;
+ (id)DownResourceManger;
-(UIImage *) getImageFromURL:(NSString *)fileURL;
-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath;
- (void)getVoiceURL:(NSString *)fileURL Voice:(NSString *)voiceName;
@end
