#import <Foundation/Foundation.h>


@interface FileTools : NSObject
{
    NSString *documentsDirectory;
    NSString *applicationDirectory;
    NSString *tmpDirectory;
    NSString *curUserDocumentsDirectory;
}

+ (FileTools*)defaultTools;


- (NSString*)GetDocumentsPath;


- (NSString*)GetFullFilePathInDocuments:(NSString*)filePath;

- (void)deleteDir:(NSString*)dirPath;

- (void)deleteDirInDocuments:(NSString*)dirPath;


- (id)GetJSONObjectFromFile:(NSString*)file;
@end
