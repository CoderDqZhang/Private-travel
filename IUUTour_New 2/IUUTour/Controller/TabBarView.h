#import <UIKit/UIKit.h>

typedef void (^selectIndexBlock)(NSInteger index);

@interface TabBarView : UIView

@property (nonatomic,copy)selectIndexBlock selectIndexBlock;


+ (instancetype)tabBarViewWithSelect:(selectIndexBlock)selectIndexBlock;

@end

@interface TabBarButton : UIButton
{
    CGRect titleRect;
}

@end
