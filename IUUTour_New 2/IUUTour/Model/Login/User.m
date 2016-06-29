#import "User.h"
#import "AppDelegate.h"

#define kEncodedObjectPath_User ([[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"user"])

@implementation User

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static User *single = nil;
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    dispatch_once(&onceToken, ^{
        if([User isLoggedIn])
        {
            single = [NSKeyedUnarchiver unarchiveObjectWithFile:kEncodedObjectPath_User];
        }
        else
        {
            single = [[User alloc] init];
        }
    });
    
    
    return single;
}

+ (BOOL)synchronize
{
    return [NSKeyedArchiver archiveRootObject:[User sharedInstance] toFile:kEncodedObjectPath_User];
}

+ (BOOL)isLoggedIn
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:kEncodedObjectPath_User];
}

+ (BOOL)logout
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL result = [fileManager removeItemAtPath:kEncodedObjectPath_User error:&error];
    if(!result)
    {
        NSLog(@"注销失败!\n%@", error);
    }
    else
    {
//        AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        if (del.logoutCompleteBlock)
//        {
//            del.logoutCompleteBlock();
//        }
    }
    
    [User sharedInstance].userid    = nil;
    [User sharedInstance].nickname  = nil;
    [User sharedInstance].loginName = nil;
    [User sharedInstance].tel       = nil;
    [User sharedInstance].address   = nil;
    [User sharedInstance].name      = nil;
    [User sharedInstance].sex       = nil;
    [User sharedInstance].age       = nil;
    [User sharedInstance].token     = nil;
    [User sharedInstance].city      = nil;
    [User sharedInstance].email     = nil;
    [User sharedInstance].password  = nil;

    
    return result;
}

- (id)init
{
    if (self = [super init])
    {
       
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if(self)
    {
        self.userid    = [aDecoder decodeObjectForKey:@"userid"];
        self.nickname  = [aDecoder decodeObjectForKey:@"nickname"];
        self.loginName = [aDecoder decodeObjectForKey:@"loginName"];
        self.tel       = [aDecoder decodeObjectForKey:@"tel"];
        self.address   = [aDecoder decodeObjectForKey:@"address"];
        self.name      = [aDecoder decodeObjectForKey:@"name"];
        self.userpic   = [aDecoder decodeObjectForKey:@"userpic"];
        self.sex       = [aDecoder decodeObjectForKey:@"sex"];
        self.birthday  = [aDecoder decodeObjectForKey:@"birthday"];
        self.token     = [aDecoder decodeObjectForKey:@"token"];
        self.level     = [aDecoder decodeObjectForKey:@"level"];
        self.age       = [aDecoder decodeObjectForKey:@"age"];
        self.credits   = [aDecoder decodeObjectForKey:@"credits"];
        self.desc      = [aDecoder decodeObjectForKey:@"desc"];
        self.email     = [aDecoder decodeObjectForKey:@"email"];
        self.city      = [aDecoder decodeObjectForKey:@"city"];
        self.password  = [aDecoder decodeObjectForKey:@"password"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userid forKey:@"userid"];
    [aCoder encodeObject:self.nickname forKey:@"nickname"];
    [aCoder encodeObject:self.loginName forKey:@"loginName"];
    [aCoder encodeObject:self.tel forKey:@"tel"];
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.userpic forKey:@"userpic"];
    [aCoder encodeObject:self.sex forKey:@"sex"];
    [aCoder encodeObject:self.token forKey:@"token"];
    [aCoder encodeObject:self.birthday forKey:@"birthday"];
    [aCoder encodeObject:self.level forKey:@"level"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.desc forKey:@"desc"];
    [aCoder encodeObject:self.credits forKey:@"credits"];
    [aCoder encodeObject:self.age forKey:@"age"];
    [aCoder encodeObject:self.city forKey:@"city"];
    [aCoder encodeObject:self.password forKey:@"password"];
}

+ (BOOL)saveCacheImage:(UIImage *)image withName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = paths[0];
    [path stringByAppendingPathComponent:@"/uploadImage"];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:path])
    {
        NSError *error = nil;
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    }
    [path stringByAppendingFormat:@"/%@",name];
    NSData *imageData = UIImagePNGRepresentation(image);
    return [imageData writeToFile:path atomically:YES];
}

+ (UIImage *)imageForName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = paths[0];
    NSFileManager *fm = [NSFileManager defaultManager];
    [path stringByAppendingFormat:@"/uploadImage/%@",name];
    if (![fm isReadableFileAtPath:path])
    {
        return nil;
    }
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    return [[UIImage alloc] initWithData:data];
}

+ (BOOL)saveBaseData:(id)data WithName:(NSString *)name
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths    = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path    = paths.lastObject;
    NSString *temPath = [path stringByAppendingPathComponent:@"baseData"];
    
    if (![fm fileExistsAtPath:temPath])
    {
        NSError *error = nil;
        [fm createDirectoryAtPath:temPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSString *filePath = [temPath stringByAppendingFormat:@"/%@.plist",name];
//    LSLog(@"save_path = %@",filePath);
//    NSData *dat = [NSKeyedArchiver archivedDataWithRootObject:data];
    return [NSKeyedArchiver archiveRootObject:data toFile:filePath];
}

+ (id)getBaseDataWithName:(NSString *)name
{
    NSFileManager *fm  = [NSFileManager defaultManager];
    NSArray *paths     = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path     = paths[0];
    NSString *filePath = [path stringByAppendingFormat:@"/baseData/%@.plist",name];
//    LSLog(@"read_path = %@",filePath);
    if (![fm isReadableFileAtPath:filePath])
    {
        return nil;
    }
    id dat = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    return dat;
}

+ (void)saveChatWithMessageArray:(NSMutableArray *)message withKey:(NSString *)key
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths    = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path    = paths.lastObject;
    NSString *temPath = [path stringByAppendingPathComponent:@"ChatData"];
    
    if (![fm fileExistsAtPath:temPath])
    {
        NSError *error = nil;
        [fm createDirectoryAtPath:temPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSString *filePath = [temPath stringByAppendingFormat:@"/%@.plist",key];
    [NSKeyedArchiver archiveRootObject:message toFile:filePath];
}

+ (id)getChatMessageWithKey:(NSString *)key
{
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths    = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path    = paths.lastObject;
    NSString *temPath = [path stringByAppendingPathComponent:@"ChatData"];
    if (![fm fileExistsAtPath:temPath])
    {
        return nil;
    }
    NSString *filePath = [temPath stringByAppendingFormat:@"/%@.plist",key];
    NSData *dat        = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    return dat;
}


@end
