#import "TabBarView.h"

@interface TabBarView ()
{
    NSMutableArray *_btnArray;
}

@end

@implementation TabBarView

+ (instancetype)tabBarViewWithSelect:(selectIndexBlock)selectIndexBlock
{
    TabBarView *tabBar = [[TabBarView alloc] initWithFrame:CGRectMake(0, App_Frame_Height - 49+20, App_Frame_Width, 49)];
    [tabBar setSelectIndexBlock:selectIndexBlock];
    return tabBar;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        UIImageView *backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 49)];
        backView.image        = [UIImage imageNamed:@"tabBarBg.png"];

        [self addSubview:backView];
        
        _btnArray = [[NSMutableArray alloc] init];

        NSArray *normalImages = @[@"mainNor.png",@"personNor.png"];
        NSArray *selectImages = @[@"mainSel.png",@"personSel.png"];
        for (int i = 0; i < selectImages.count; i ++)
        {
            TabBarButton *btn = [TabBarButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(App_Frame_Width/2*i, 0, App_Frame_Width/2, 49)];
            [btn setSelected:i == 0 ? YES : NO];
            [btn setTag:1000 + i];
            [btn setImage:[UIImage imageNamed:normalImages[i]]  forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:selectImages[i]]  forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            [_btnArray addObject:btn];
        }
    }
    return self;
}

- (void)btnAction:(UIButton *)btn
{
    NSInteger index  = btn.tag - 1000;

    {
        for (UIButton *bt in _btnArray)
        {
            bt.selected = (btn == bt);
        }
        
        if (self.selectIndexBlock)
        {
            self.selectIndexBlock(index);
        }
    }
}

@end

@implementation TabBarButton

- (id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake((CGRectGetWidth(self.frame) - 30)/2, (CGRectGetHeight(self.frame) - 30)/2, 30, 30);
}


@end
