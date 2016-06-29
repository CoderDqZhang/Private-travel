#import "ShareView.h"
#import "AppDelegate.h"


@interface ShareView ()<UIGestureRecognizerDelegate>
{
    UIImageView *_bgView;
}

@property (nonatomic,copy)void (^choiceBlock)(NSInteger index);
@property (nonatomic,copy)void (^cancelBlock)(void);

- (id)initWithFrame:(CGRect)frame;

@end

@implementation ShareView


+ (instancetype)showShareViewChoice:(void (^)(NSInteger index))choiceBlock cancel:(void (^)(void))cancelBlock
{
    ShareView *share = [[ShareView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [share setChoiceBlock:choiceBlock];
    [share setCancelBlock:cancelBlock];
    [APP_DELEGATE.window addSubview:share];
    [share show];
    return share;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        
        _bgView                        = [[UIImageView alloc] initWithFrame:self.frame];
        _bgView.alpha                  = 0.0f;
        _bgView.image                  = [UIImage imageNamed:@"sign_bg"];
        _bgView.userInteractionEnabled = YES;
        [self addSubview:_bgView];
        
        UILabel *lblDes = [[UILabel alloc] initWithFrame:CGRectMake(0, App_Frame_Height - 340, App_Frame_Width, 40)];
        lblDes.text            = @"分享";
        lblDes.textAlignment   = NSTextAlignmentCenter;
        lblDes.textColor       = [UIColor whiteColor];
        lblDes.font            = [UIFont boldSystemFontOfSize:18.f];
        lblDes.backgroundColor = [UIColor clearColor];
        [_bgView addSubview:lblDes];
        
        NSArray *array = @[@"微信",@"朋友圈",@"新浪微博",@"腾讯微博",@"QQ好友",@"QQ空间",@"人人网",@"电子邮件"];
        NSArray *arrayImg = @[@"share_weChat.png",@"share_friend.png",@"share_sina.png",@"share_tencent.png",@"share_qq.png",@"share_zone.png",@"share_renren.png", @"share_message.png"];
        
        CGFloat width = 55;
        CGFloat space = (App_Frame_Width / 4 - width)/2;
        CGRect rect   = CGRectMake(space, App_Frame_Height - 250, width, width);
        for (int i = 0; i < [array count]; i ++)
        {
            if (i % 4 == 0 && i != 0)
            {
                rect.origin.x = space;
                rect.origin.y = CGRectGetMaxY(rect)+space*2;
            }
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setImage:[UIImage imageNamed:[arrayImg objectAtIndex:i]]  forState:UIControlStateNormal];
            btn.frame     = rect;
            btn.tag       = 1000 + i;
            [btn addTarget:self action:@selector(choiceAction:) forControlEvents:UIControlEventTouchUpInside];
            [_bgView addSubview:btn];
            UILabel *shareTitle      = [[UILabel alloc] initWithFrame:CGRectMake(0+i%4*App_Frame_Width/4, CGRectGetMaxY(btn.frame) + 5, App_Frame_Width/4, 20)];
            shareTitle.text          = [array objectAtIndex:i];
            shareTitle.textAlignment = NSTextAlignmentCenter;
            shareTitle.textColor     = [UIColor whiteColor];
            shareTitle.font          = [UIFont boldSystemFontOfSize:16.f];
            shareTitle.backgroundColor = [UIColor clearColor];
            [_bgView addSubview:shareTitle];
            rect.origin.x = CGRectGetMaxX(rect)+space*2;
        }
    }
    return self;
}

- (void)show
{
    [UIView beginAnimations:@"show" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:AnimationDurationTime];
    _bgView.alpha = 1.0f;
    [UIView commitAnimations];
}

- (void)choiceAction:(UIButton *)btn
{
    if (self.choiceBlock)
    {
        self.choiceBlock(btn.tag - 1000);
    }
    [self cancelBtnAction];
}

- (void)tapAction
{
    if (self.cancelBlock)
    {
        self.cancelBlock();
    }
    [self cancelBtnAction];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (CGRectContainsPoint(_bgView.frame, point))
    {
        return NO;
    }
    
    return YES;
}

- (void)cancelBtnAction
{
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:.6 animations:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }
        
        [UIView beginAnimations:@"hide" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:AnimationDurationTime];
        strongSelf->_bgView.alpha = .0f;
        [UIView commitAnimations];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self tapAction];
}


@end
