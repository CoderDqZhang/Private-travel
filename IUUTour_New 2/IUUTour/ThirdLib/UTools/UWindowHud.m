#import "UWindowHud.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CGAffineTransform.h>

UWindowHud *currentHud = nil;
NSMutableArray *animationIDArray = nil;
static int contentLableTag = 0xFFCF;

// 用于UI的静态变量
static CGFloat defaultCornerRadius      =   6;

@interface UWindowHud(Private)
+ (void)clearHud;
- (void)setContentString:(NSString*)str;
@end

@implementation UWindowHud
@synthesize canBeCanceled = _canBeCanceled;
@synthesize contentView = _contentView;

// 动画的默认ID格式
static NSString *hideAnimationIDForm = @"hideAnimation%d";

#pragma mark - Static Functions
// 创建Hud
+ (UWindowHud*)hudOnView:(UIView*)view  withType:(HudType)type
{
    @synchronized(currentHud)
    {
        if (!currentHud)
        {
            //currentHud = [[UWindowHud alloc] initWithFrame:view.bounds];
            currentHud = [[UWindowHud alloc] initWithFrame:CGRectMake(0, 100, view.bounds.size.width, 100)];
            //currentHud.center = view.center;

            animationIDArray = [[NSMutableArray alloc] init];
        }
        currentHud.backgroundColor = [UIColor clearColor];
        [currentHud removeFromSuperview];
        [view addSubview:currentHud];
        
        // 为当前的Hud创建一个唯一的ID，防止界面被其他的请求Hide
        NSString *animationID = [NSString stringWithFormat:hideAnimationIDForm, [animationIDArray count]];
        [animationIDArray addObject:animationID];
        
        // 装载控件
        [currentHud loadComponentsWithType:type];
        
        // 还原控件显示的优先等级
//        HUD_LEVEL = 0;
        
        return currentHud;
    }
}


// 创建Hud
+ (UWindowHud*)hudModalOnView:(UIView*)view  withType:(HudType)type
{
    @synchronized(currentHud)
    {
        if (!currentHud)
        {
            currentHud = [[UWindowHud alloc] initWithFrame:view.bounds];
            //currentHud = [[UWindowHud alloc] initWithFrame:CGRectMake(0, 100, view.bounds.size.width, 100)];
            //currentHud.center = view.center;
            
            animationIDArray = [[NSMutableArray alloc] init];
        }
        currentHud.backgroundColor = [UIColor clearColor];
        [currentHud removeFromSuperview];
        [view addSubview:currentHud];
        
        // 为当前的Hud创建一个唯一的ID，防止界面被其他的请求Hide
        NSString *animationID = [NSString stringWithFormat:hideAnimationIDForm, [animationIDArray count]];
        [animationIDArray addObject:animationID];
        
        // 装载控件
        [currentHud loadComponentsWithType:type];
        
        // 还原控件显示的优先等级
        //        HUD_LEVEL = 0;
        
        return currentHud;
    }
}

// 根据类型和内容创建
+ (UWindowHud*)hudWithType:(HudType)type withContentString:(NSString*)string withRootView:(UIView*)rootView
{
    UWindowHud *hud = [UWindowHud hudOnView:rootView withType:type];

    
    [hud setContentString:string];
    return hud;
}



// 创建Hud
+ (UWindowHud*)hudWithType:(HudType)type
{
    UIView *window = [APP_DELEGATE window];
    return [UWindowHud hudOnView:window withType:type];
}

// 根据类型和内容创建
+ (UWindowHud*)hudWithType:(HudType)type withContentString:(NSString*)string
{
    // 根据Http请求和类型创建
    UWindowHud *hud = [UWindowHud hudWithType:type];
    [hud setContentString:string];
    return hud;
}

// 是否动画隐藏Hud
+ (void)hideAnimated:(BOOL)animated
{
    if (currentHud)
    {
        currentHud->_canBeCanceled = YES;
        if (animated)
        {
            [UIView beginAnimations:[animationIDArray lastObject] context:NULL];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationDelegate:currentHud];
            [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
            currentHud->_contentView.transform = CGAffineTransformMakeScale(1.1f, 1.15f);
            currentHud->_contentView.alpha = 0.02f;
            [UIView commitAnimations];
        }
        else
        {
            [UWindowHud clearHud];
        }
    }
}

// 清除动画相关
+ (void)clearHud
{
    [animationIDArray removeAllObjects];
    [currentHud removeFromSuperview];
}

#pragma mark - Life Functions

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _shadowEdgeWith = 2;
        _shadowOpacity = 0.55;
        _shadowOffset = CGSizeMake(-1, -1);
        _defaultBGColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        _shadowColor = [UIColor blackColor];
    }
    return self;
}

// 根据当前的Hud类型创建对应的控件
- (void)loadComponentsWithType:(HudType)type
{
    self.backgroundColor = [UIColor clearColor];
    if (_type == type )
    {
        _contentView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        _contentView.alpha = 1.0f;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideAnimated:) object:self];
        if (kHttpLodingType != _type)
        {
            [self performSelector:@selector(hideAnimated:) withObject:self afterDelay:2.0f];
        }
        //        ULog(@"%s %d %p %p retrun", __FUNCTION__, __LINE__, currentHud, currentHud.currentRequest);
        return;
    }
    
    //    ULog(@"%s %d %p %p type = %d", __FUNCTION__, __LINE__, currentHud, currentHud.currentRequest, type);
    // 将不用的控件清理
    for (UIView *subview in self.subviews)
    {
        [subview removeFromSuperview];
    }
    _contentView = nil;
    _controlBtn = nil;
    // 初始化是否可以取消状态
    _canBeCanceled = YES;
    // 初始化动画状态
    _type = type;
    self.alpha = 1.0f;
    self.userInteractionEnabled = YES;
    
    // 重新加载新的控件
    if (kHttpLodingType == type)
    {
        // 内容View
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 75.0f, 75.0f)];
        _contentView.backgroundColor = _defaultBGColor;
        _contentView.layer.cornerRadius = defaultCornerRadius;
        CGRect rect = _contentView.bounds;
        CGPathRef pathRef = CGPathCreateWithRect(rect, &CGAffineTransformIdentity);
        _contentView.layer.shadowPath = pathRef;
        CFRelease(pathRef);
        _contentView.center = self.center;
        
        // 菊花~
        UIImageView *loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(17.5f, 17.5f, 40.0f, 40.0f)];
        [_contentView addSubview:loadingView];
        loadingView.image = [UIImage imageNamed:@"loading_0.png"];
        CABasicAnimation *an = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        an.byValue = [NSNumber numberWithFloat:2*M_PI];
        an.duration = 1.0f;
        an.removedOnCompletion = NO;
        an.repeatCount = NSNotFound;
        [loadingView.layer addAnimation:an forKey:@"an"];
    }
    else if (kToastType == type)
    {
        // 内容View
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 50)];
        _contentView.backgroundColor = _defaultBGColor;
        _contentView.layer.cornerRadius = defaultCornerRadius;
        CGRect rect = _contentView.bounds;
        CGPathRef pathRef = CGPathCreateWithRect(rect, &CGAffineTransformIdentity);
        _contentView.layer.shadowPath = pathRef;
        CFRelease(pathRef);
        _contentView.center = self.center;
        
        // 内容Label
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 270, 50)];
        contentLabel.tag = contentLableTag;
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.font = [UIFont systemFontOfSize:14.0];
        contentLabel.textColor = [UIColor whiteColor];
        contentLabel.textAlignment = NSTextAlignmentCenter;
        contentLabel.numberOfLines = 2;
        [_contentView addSubview:contentLabel];
        contentLabel.center = CGPointMake(CGRectGetWidth(_contentView.bounds)/2, CGRectGetHeight(_contentView.bounds)/2);
        
        [self performSelector:@selector(hideAnimated:) withObject:self afterDelay:2.0f];
    }
    
    [self addSubview:_contentView];
}

// 设置Toast内容
- (void)setContentString:(NSString*)str
{
    UILabel * contantLabel = (UILabel*)[_contentView viewWithTag:contentLableTag];
    contantLabel.text = str;
    
    if (str.length > 0)
    {
        _contentView.frame = CGRectMake(0, 0, 270, 50);
        _contentView.center = self.center;
        CGRect rect = _contentView.bounds;
        rect.size.width = rect.size.width + _shadowEdgeWith;
        rect.size.height = rect.size.height + _shadowEdgeWith;
        CGPathRef pathRef = CGPathCreateWithRect(rect, &CGAffineTransformIdentity);
        _contentView.layer.shadowPath = pathRef;
        CFRelease(pathRef);
        contantLabel.center = CGPointMake(CGRectGetWidth(_contentView.bounds)/2, CGRectGetHeight(_contentView.bounds)/2);
    }
    else
    {
        _contentView.frame = CGRectMake(0, 0, 75, 75);
        _contentView.center = self.center;
        CGRect rect = _contentView.bounds;
        rect.size.width = rect.size.width + _shadowEdgeWith;
        rect.size.height = rect.size.height + _shadowEdgeWith;
        CGPathRef pathRef = CGPathCreateWithRect(rect, &CGAffineTransformIdentity);
        _contentView.layer.shadowPath = pathRef;
        CFRelease(pathRef);
        contantLabel.center =CGPointMake(CGRectGetWidth(_contentView.bounds)/2, CGRectGetHeight(_contentView.bounds)/2);
    }
}

// Hide动画结束的回调函数
- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void*)context
{
    if ([animationID isEqualToString:[animationIDArray lastObject]])
    {
        [UWindowHud clearHud];
    }
}


// 取消页面
- (void)hideAnimated:(BOOL)animated
{
    [UWindowHud hideAnimated:animated];
}

// 设置是否可被取消
- (void)setCanBeCanceled:(BOOL)canBeCanceled
{
    //    if (kHttpLodingType == _type)
    //    {
    //        if (_canBeCanceled != canBeCanceled)
    //        {
    //            _canBeCanceled = canBeCanceled;
    //            if (_canBeCanceled)
    //            {
    //                _controlBtn.hidden = NO;
    //                _contentView.frame = CGRectMake(0, 0, 228, 57);
    //                _contentView.center = self.center;
    //            }
    //            else
    //            {
    //                _controlBtn.hidden = YES;
    //                _contentView.frame = CGRectMake(0, 0, 228-57-2, 57);
    //                _contentView.center = self.center;
    //            }
    //        }
    //    }
}

#pragma mark - Cancel Btn Response

- (void)cancelBtnClicked:(id)sender
{
    [UWindowHud hideAnimated:YES];
}



@end
