#import <UIKit/UIKit.h>

@interface ShareView : UIView

+ (instancetype)showShareViewChoice:(void (^)(NSInteger index))choiceBlock cancel:(void (^)(void))cancelBlock;

@end
