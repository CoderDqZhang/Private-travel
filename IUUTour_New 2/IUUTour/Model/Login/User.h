#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface User : NSObject


@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *loginName;
@property (nonatomic, copy) NSString *tel;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *userpic;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *age;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *credits;
@property (nonatomic, copy) NSString *level;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;

@property(nonatomic,copy) void (^clearMyCenterDataBlock)(void);// 登出清除我的活动
+ (instancetype)sharedInstance;

+ (BOOL)synchronize;

+ (BOOL)isLoggedIn;

+ (BOOL)logout;

+ (BOOL)saveBaseData:(id)data WithName:(NSString *)name;

+ (id)getBaseDataWithName:(NSString *)name;

+ (void)saveChatWithMessageArray:(NSMutableArray *)message withKey:(NSString *)key;

+ (id)getChatMessageWithKey:(NSString *)key;

@end
