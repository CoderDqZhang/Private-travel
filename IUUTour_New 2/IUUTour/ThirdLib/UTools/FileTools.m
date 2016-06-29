#import "FileTools.h"

static FileTools* _fileTools;

@implementation FileTools

- (id)init {
    @autoreleasepool {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
        NSLog(@"-----------%@",paths);
        tmpDirectory = NSTemporaryDirectory();
    }

    return self;
}

+ (FileTools*)defaultTools {
    @autoreleasepool {
        if (_fileTools == nil) {
            NSLog(@"FileTools init");
            _fileTools = [[FileTools alloc] init];
        }
        return _fileTools;
    }
}



- (NSString*)GetDocumentsPath {
    //NSLog(@"GetDocumentsPath documentsDirectory=%@", documentsDirectory);
    @autoreleasepool {
        return documentsDirectory;
    }
}


- (NSString*)GetFullFilePathInDocuments:(NSString*)filePath {
    @autoreleasepool {
        NSString *fullFilePath = [NSString stringWithFormat:@"%@/%@", [self GetDocumentsPath], filePath];
        return fullFilePath;
    }
}



- (void)deleteDir:(NSString*)dirPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL isDir;
    BOOL exist = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    if (exist) {
        if (isDir) {
            NSArray *items = [fileManager contentsOfDirectoryAtPath:dirPath error:&error];
            for (NSString *fileName in items) {
                NSString *subPath = [NSString stringWithFormat:@"%@/%@", dirPath, fileName];
                [self deleteDir:subPath];
            }
        }
        [fileManager removeItemAtPath:dirPath error:&error];
    }
}

- (void)deleteDirInDocuments:(NSString*)dirPath {
    [self deleteDir:[self GetFullFilePathInDocuments:dirPath]];
}



- (id)GetJSONObjectFromFile:(NSString *)file {
    NSError *error;
    NSLog(@"%@",file);
    NSData *data = [NSData dataWithContentsOfFile:file];
    id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error != nil) {
        NSLog(@"%@", error);
    }
    return obj;
}
@end
