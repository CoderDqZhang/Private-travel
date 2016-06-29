#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
{
    UIView  * _defaultView;
    CGFloat _navBarHeight;
    CGFloat _height;
}

@property (nonatomic, readonly) UIView  *defaultView;
@property (nonatomic, retain)   UIView  *titleView;
@property (nonatomic, retain)   UILabel *titleLabel;

-(void)initWithBackBtn;
-(void)initWithXBtn;

@end
