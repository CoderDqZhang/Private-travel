#import <Foundation/Foundation.h>

@interface OfflineMapDownloader : NSObject


@property (atomic, strong) NSMutableArray      *handlingArray;
@property (atomic, strong) NSMutableArray      *unzippingArray;
@property (atomic, strong) NSMutableArray      *doneArray;
@property (atomic, strong) NSMutableArray      *failureArray;
@property (atomic, strong) NSMutableArray      *progressArray;



+ (instancetype)sharedInstance;
- (void)restoreFromAccident;
- (void)downloadFrom:(NSString*)sourceUrlStr to:(NSString*)targetPath withTempPath:(NSString*)tempPath forScene:(NSString*)sceneId withSceneData:(NSDictionary*)sceneData;
- (void)cancelDownloadOfScene:(NSString*)sceneId clearCache:(BOOL)clear;

@end
