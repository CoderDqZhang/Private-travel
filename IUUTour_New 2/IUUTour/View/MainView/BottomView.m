//
//  BottomView.m
//  IUUTour
//
//  Created by Zhang on 1/8/16.
//  Copyright © 2016 DevDiv Technology. All rights reserved.
//

#import "BottomView.h"

#define ViewTag 8888


@interface BottomView()
{
    UIButton *bottomBtn;
    UIImageView *bgImage;
    UIButton *hideBtn;
}

@end

@implementation BottomView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initBottomView];
    }
    return self;
}

-(void)initBottomView{
    NSArray *iconArray = @[@"ic_jiudian",@"ic_meishi",@"ic_menpiao",@"ic_shangcheng"];
    CGFloat wid = (App_Frame_Width-150)/4;
    CGFloat heig = wid;
    CGFloat imgHeight = 90+heig;
    
    bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, App_Frame_Height-imgHeight, App_Frame_Width, imgHeight)];
    bgImage.hidden = YES;
    [bgImage setImage:[UIImage imageNamed:@"bg"]];
    bgImage.alpha = 0.7;
    [self addSubview:bgImage];
    
    for (int i = 0; i < 4; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(30+i*(wid+30), App_Frame_Height - heig+340, wid, heig);
        button.tag = ViewTag+i;
        [button setBackgroundImage:[UIImage imageNamed:iconArray[i]] forState:UIControlStateNormal];
        [self addSubview:button];
    }
    
    hideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    hideBtn.frame = CGRectMake((App_Frame_Width - 30)/2, App_Frame_Height + 360, 30, 30);
    [hideBtn setBackgroundImage:[UIImage imageNamed:@"hide"] forState:UIControlStateNormal];
    [hideBtn addTarget:self action:@selector(hideBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:hideBtn];
    
}


-(void)showBtn{
    
    bottomBtn.hidden = YES;
    bgImage.hidden = NO;
    
    for (UIView *view in self.subviews) {
        UIButton *button = (UIButton*)view;
        switch (button.tag - ViewTag) {
            case 0:
            case 1:
            case 2:
            case 3:{
                [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.4f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveLinear animations:^{
                    
                    button.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y - 400, view.frame.size.width, view.frame.size.height);
                } completion:^(BOOL finished) {
                    
                }];
            }
                break;
        }
    }
    hideBtn.frame = CGRectMake(hideBtn.frame.origin.x, hideBtn.frame.origin.y - 400, 30, 30);
}

-(void)hideBtn {
    bottomBtn.hidden = NO;
    bgImage.hidden = YES;
    
    for (UIView *view in self.subviews) {
        UIButton *button = (UIButton*)view;
        switch (button.tag - ViewTag) {
            case 0:
            case 1:
            case 2:
            case 3:{
                [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.4f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveLinear animations:^{
                    
                    button.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + 400, view.frame.size.width, view.frame.size.height);
                } completion:^(BOOL finished) {
                    
                }];
            }
                break;
        }
    }
    hideBtn.frame = CGRectMake(hideBtn.frame.origin.x, hideBtn.frame.origin.y + 400, 30, 30);
}

@end
