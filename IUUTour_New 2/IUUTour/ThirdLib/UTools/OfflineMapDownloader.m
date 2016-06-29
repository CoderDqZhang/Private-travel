#import "OfflineMapDownloader.h"
#import "ZipArchive.h"
#import "AFDownloadRequestOperation.h"
#import "DownResource.h"

@interface DownInfo : NSObject<NSCoding>
@property (nonatomic, copy) NSString      *sceneId;
@property (nonatomic, copy) NSString      *tempZipPath;
@property (nonatomic, copy) NSString      *targetPath;
@property (nonatomic, copy) NSString      *sourceUrlStr;
@property (nonatomic, copy) NSDictionary  *sceneData;
@end

@implementation DownInfo

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.sceneId forKey:@"sceneId"];
    [aCoder encodeObject:self.tempZipPath forKey:@"tempZipPath"];
    [aCoder encodeObject:self.targetPath forKey:@"targetPath"];
    [aCoder encodeObject:self.sourceUrlStr forKey:@"sourceUrlStr"];
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.sceneId      = [aDecoder decodeObjectForKey:@"sceneId"];
        self.tempZipPath  = [aDecoder decodeObjectForKey:@"tempZipPath"];
        self.targetPath   = [aDecoder decodeObjectForKey:@"targetPath"];
        self.sourceUrlStr = [aDecoder decodeObjectForKey:@"sourceUrlStr"];
    }
    
    return self;
}
@end

@interface OfflineMapDownloader ()
{
    NSOperationQueue    *downQueue;
    NSMutableArray      *downInfoArray;
}
@end


@implementation OfflineMapDownloader

+ (instancetype)sharedInstance
{
    static OfflineMapDownloader *single = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        single = [[OfflineMapDownloader alloc] init];
        
        single->downQueue     = [[NSOperationQueue alloc] init];
        single->downQueue.maxConcurrentOperationCount = 1;
        
        single.handlingArray  = [[NSMutableArray alloc]init];
        single.unzippingArray = [[NSMutableArray alloc]init];
        single.doneArray      = [[NSMutableArray alloc]init];
        single.failureArray   = [[NSMutableArray alloc]init];
        single.progressArray  = [[NSMutableArray alloc]init];

        single->downInfoArray = [[NSMutableArray alloc]init];
    });
    
    return single;
}


- (void)downloadFrom:(NSString*)sourceUrlStr to:(NSString*)targetPath withTempPath:(NSString*)tempPath forScene:(NSString*)sceneId withSceneData:(NSDictionary*)sceneData
{
    FileTools *fileTools = [FileTools defaultTools];
    
    [fileTools deleteDir:tempPath];
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:sourceUrlStr] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    
    NSString *fileIdentifier   = [sourceUrlStr stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    NSString *fileIdentifierEx = [fileIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    
    AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request fileIdentifier:fileIdentifierEx targetPath:tempPath shouldResume:YES];
    
    //  No weak-strong dance required
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *param = [[NSMutableArray alloc]init];
        [param addObject:sceneId];
        [param addObject:tempPath];
        [param addObject:targetPath];
        
        
        NSString *percentageStr = @"100";
        
        [self removeFromProgressArrayForScene:sceneId];
        
        NSMutableDictionary *progressDic = [[NSMutableDictionary alloc]init];
        [progressDic setValue:percentageStr forKey:sceneId];
        
        [[self mutableArrayValueForKey:@"progressArray"]addObject:progressDic];
        
        [self performSelectorInBackground:@selector(handleDone:) withObject:param];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        @synchronized(self)
        {
            [self.doneArray removeObject:sceneId];
            [self.unzippingArray removeObject:sceneId];
            [self removeFromProgressArrayForScene:sceneId];
            
            [[self mutableArrayValueForKey:@"failureArray"]addObject:sceneId];
            
            NSIndexSet *index2Remove = [self.handlingArray indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *dic = (NSDictionary*)obj;
                
                if ([dic valueForKey:sceneId])
                {
                    return YES;
                }
                else
                {
                    return NO;
                }
            }];
            if (index2Remove && index2Remove.count > 0)
            {
                [self.handlingArray removeObjectsAtIndexes:index2Remove];
            }
            

            if (self.handlingArray.count > 0)
            {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.handlingArray];
                [Interface serialize:data to:@"OfflineMapHandlingArray"];
            }
            else
            {
                [Interface serialize:nil to:@"OfflineMapHandlingArray"];
            }
        }
    }];
    
    [operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        
        @synchronized(self)
        {
            [self.failureArray removeObject:sceneId];
            [self.doneArray removeObject:sceneId];
            [self.unzippingArray removeObject:sceneId];
            
            
            NSNumber *percentage = [NSNumber numberWithLongLong:totalBytesReadForFile * 100 / totalBytesExpectedToReadForFile];
            
            NSString *percentageStr = [percentage stringValue];
            
            [self removeFromProgressArrayForScene:sceneId];
            
            NSMutableDictionary *progressDic = [[NSMutableDictionary alloc]init];
            [progressDic setValue:percentageStr forKey:sceneId];
            
            [[self mutableArrayValueForKey:@"progressArray"]addObject:progressDic];
        }
    }];

    NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc]init];
    [userInfoDic setValue:sceneId forKey:@"sceneId"];
    operation.userInfo = userInfoDic;
    
    [downQueue addOperation:operation];
    
    @synchronized(self)
    {
        [self.doneArray removeObject:sceneId];
        [self.failureArray removeObject:sceneId];
        [self.unzippingArray removeObject:sceneId];
        [self removeFromProgressArrayForScene:sceneId];
        

        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setValue:sceneData forKey:sceneId];
        [[self mutableArrayValueForKey:@"handlingArray"]addObject:dic];
        
    
        if (self.handlingArray.count > 0)
        {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.handlingArray];
            [Interface serialize:data to:@"OfflineMapHandlingArray"];
        }
        else
        {
            [Interface serialize:nil to:@"OfflineMapHandlingArray"];
        }
        
        DownInfo *downInfo    = [[DownInfo alloc]init];
        downInfo.sceneId      = sceneId;
        downInfo.tempZipPath  = tempPath;
        downInfo.targetPath   = targetPath;
        downInfo.sourceUrlStr = sourceUrlStr;
        
        [downInfoArray addObject:downInfo];
        NSData *data2 = [NSKeyedArchiver archivedDataWithRootObject:downInfoArray];
        [Interface serialize:data2 to:@"OfflineMapDownInfogArray"];
    }
}

-(void)updateMapList2File4Scene:(NSDictionary *)dic
{
    NSArray * paths     = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString * path     = [paths  objectAtIndex:0];
    NSString * filePath = [path stringByAppendingPathComponent:@"leaveMapData.plist"];
    

    UIImage * image = [[DownResource DownResourceManger] getImageFromURL:[dic objectForKey:@"smallImage"]];
    [[DownResource DownResourceManger] saveImage:image withFileName:[NSString stringWithFormat:@"%@-Img",[dic objectForKey:@"scenicID"]] ofType:@"jpg" inDirectory:path];
    
    
    
    NSMutableArray *jsonObject = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    for (int i = 0; i < jsonObject.count; i++) {
        if ([[[jsonObject objectAtIndex:i] objectForKey:@"scenicID"] intValue] == [[dic objectForKey:@"scenicID"] intValue]) {
            [jsonObject removeObjectAtIndex:i];
        }
    }
    
    if (jsonObject==nil) {
        jsonObject = [[NSMutableArray alloc] init];
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSString stringWithFormat:@"%@-Img.jpg",[dic objectForKey:@"scenicID"]] forKey:@"imageName"];
    [dict setObject:[dic objectForKey:@"mapSize"] forKey:@"size"];
    [dict setObject:[dic objectForKey:@"scenicID"] forKey:@"scenicID"];
    [dict setObject:[dic objectForKey:@"scenicName"] forKey:@"scenicname"];
    [dict setObject:[dic objectForKey:@"canNavi"] forKey:@"canNavi"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    [dict setObject:strDate forKey:@"datetime"];
    [dict setObject:@"1" forKey:@"mapVerison"];
    [jsonObject addObject:dict];
    
    [jsonObject writeToFile:filePath atomically:YES];
}


- (void)removeFromProgressArrayForScene:(NSString*)sceneId
{
    NSIndexSet *index2Remove = [self.progressArray indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *dic = (NSMutableDictionary*)obj;
        if ([dic valueForKey:sceneId])
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }];
    
    if (index2Remove && index2Remove.count > 0)
    {
        [self.progressArray removeObjectsAtIndexes:index2Remove];
    }
}

- (void)handleDone:(NSArray*)param
{
    if (!param || param.count < 3)
    {
        return;
    }
    
    NSString *sceneId    = [param objectAtIndex:0];
    NSString *tempPath   = [param objectAtIndex:1];
    NSString *targetPath = [param objectAtIndex:2];
    
    @synchronized(self)
    {
        [self.failureArray removeObject:sceneId];
        [self removeFromProgressArrayForScene:sceneId];
        
        [[self mutableArrayValueForKey:@"unzippingArray"] addObject:sceneId];
    }
    
    [self uncompressFrom:tempPath to:targetPath forScene:sceneId];
    
    [self performSelectorOnMainThread:@selector(postDone4Scene:) withObject:sceneId waitUntilDone:NO];
    
    @synchronized(self)
    {
        [self.unzippingArray removeObject:sceneId];
        
        NSIndexSet *index2Remove = [self.handlingArray indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *dic = (NSDictionary*)obj;
            
            if ([dic valueForKey:sceneId])
            {
                return YES;
            }
            else
            {
                return NO;
            }
        }];
        if (index2Remove && index2Remove.count > 0)
        {
            NSDictionary *dic = [self.handlingArray objectAtIndex:index2Remove.firstIndex];
            
            @synchronized(self)
            {
                [self.handlingArray removeObjectsAtIndexes:index2Remove];
                
                if (self.handlingArray.count > 0)
                {
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.handlingArray];
                    [Interface serialize:data to:@"OfflineMapHandlingArray"];
                }
                else
                {
                    [Interface serialize:nil to:@"OfflineMapHandlingArray"];
                }
            }
            
            
            [self updateMapList2File4Scene:[dic valueForKey:sceneId]];
        }
    }
}

- (void)postDone4Scene:(NSString*)sceneId
{
    [[self mutableArrayValueForKey:@"doneArray"] addObject:sceneId];
}

- (void)uncompressFrom:(NSString*)tempZipPath to:(NSString*)targetPath forScene:(NSString*)sceneId
{
    FileTools *fileTools = [FileTools defaultTools];
    
    [fileTools deleteDir:targetPath];
    
    ZipArchive *zip = [[ZipArchive alloc] init];
    [zip UnzipOpenFile:tempZipPath];
    [zip UnzipFileTo:targetPath overWrite:YES];
    [zip UnzipCloseFile];
    
    [fileTools deleteDir:tempZipPath];
}


- (void)cancelDownloadOfScene:(NSString*)sceneId clearCache:(BOOL)clear
{
    @synchronized(self)
    {
        NSIndexSet *index2Remove = [self.handlingArray indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *dic = (NSDictionary*)obj;
            
            if ([dic valueForKey:sceneId])
            {
                return YES;
            }
            else
            {
                return NO;
            }
        }];
        if (index2Remove && index2Remove.count > 0)
        {
            [self.handlingArray removeObjectsAtIndexes:index2Remove];
        }
        
        [self.unzippingArray removeObject:sceneId];
        [self.doneArray removeObject:sceneId];
        
        NSIndexSet *index2Remove2 = [self.progressArray indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *dic = (NSMutableDictionary*)obj;
            if ([dic valueForKey:sceneId])
            {
                return YES;
            }
            else
            {
                return NO;
            }
        }];
        
        if (index2Remove2 && index2Remove2.count > 0)
        {
            [self.progressArray removeObjectsAtIndexes:index2Remove2];
        }
    }
    

    NSInteger index2 = [self->downQueue.operations indexOfObjectPassingTest:^BOOL(__kindof NSOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AFDownloadRequestOperation *operation = (AFDownloadRequestOperation*)obj;
        
        NSString *sceneId4Operation = [operation.userInfo valueForKey:@"sceneId"];
        
        if ([sceneId4Operation isEqualToString:sceneId])
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }];
    
    if (index2 == NSNotFound)
    {
        return;
    }
    
    AFDownloadRequestOperation *operation = [self->downQueue.operations objectAtIndex:index2];
    [operation cancel];
    
    if (clear)
    {
        [operation deleteTempFileWithError:nil];
    }

    @synchronized(self)
    {
        //  serialize to disk (handlingArray)
        if (self.handlingArray.count > 0)
        {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.handlingArray];
            [Interface serialize:data to:@"OfflineMapHandlingArray"];
        }
        else
        {
            [Interface serialize:nil to:@"OfflineMapHandlingArray"];
        }
    }
}

- (void)restoreFromAccident
{
    NSData *data = [Interface deserializeFrom:@"OfflineMapHandlingArray"];
    NSArray *unarchivedHandlingArr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!unarchivedHandlingArr || unarchivedHandlingArr.count < 1)
    {
        return;
    }
    
    [[self mutableArrayValueForKey:@"handlingArray"]removeAllObjects];
    [[self mutableArrayValueForKey:@"doneArray"]removeAllObjects];
    [[self mutableArrayValueForKey:@"progressArray"]removeAllObjects];
    [[self mutableArrayValueForKey:@"unzippingArray"]removeAllObjects];
    
    NSMutableArray *failedScenes = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in unarchivedHandlingArr)
    {
        NSString *sceneId = [dic.allKeys objectAtIndex:0];
        if (sceneId)
        {
            [failedScenes addObject:sceneId];
        }
    }
    [[self mutableArrayValueForKey:@"failureArray"]addObjectsFromArray:failedScenes];
}


@end
