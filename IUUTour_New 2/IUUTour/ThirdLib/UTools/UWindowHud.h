#import <UIKit/UIKit.h>

typedef enum {
    kDefaultType,
    kHttpLodingType,
    kToastType,
}HudType;

//int HUD_LEVEL;

@interface UWindowHud : UIControl
{
    HudType         _type;
    BOOL            _canBeCanceled;
    CGFloat         _shadowEdgeWith;
    CGSize          _shadowOffset;
    UIColor         *_defaultBGColor;
    UIColor         *_shadowColor;
    CGFloat         _shadowOpacity;
@private
    UIView          *_contentView;      //不用管理内存
    UIButton        *_controlBtn;       //不用管理内存
}


@property (nonatomic, assign)   BOOL                canBeCanceled;
@property (nonatomic, readonly) UIView              *contentView;

// 根据父页面和类型创建
+ (UWindowHud*)hudOnView:(UIView*)view  withType:(HudType)type;

// 根据类型创建
+ (UWindowHud*)hudWithType:(HudType)type;

// 根据类型和内容创建
+ (UWindowHud*)hudWithType:(HudType)type withContentString:(NSString*)string;

+ (UWindowHud*)hudWithType:(HudType)type withContentString:(NSString*)string withRootView:(UIView*)rootView;

// 根据是否动画来隐藏
+ (void)hideAnimated:(BOOL)animated;

@end
