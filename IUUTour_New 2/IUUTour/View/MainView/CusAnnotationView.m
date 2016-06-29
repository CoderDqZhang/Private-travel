//
//  CusAnnotationView.m
//  MAMapKit_static_demo
//
//  Created by songjian on 13-10-16.
//  Copyright (c) 2013年 songjian. All rights reserved.
//
/**
 * ┏┛┻━━━┛┻┓
 ┃｜｜｜｜｜｜｜┃
 ┃　　　━　　　┃
 ┃　┳┛ 　┗┳ 　┃
 ┃　　　　　　　┃
 ┃　　　┻　　　┃
 ┃　　　　　　　┃
 ┗━┓　　　┏━┛
 　　┃　   　┃　　神兽镇压
 　　┃　   　┃　　		代码无BUG
 　　┃　   　┃
 　　┃　   　┃
 　　┃　　　┗━━━┓
 　　┃           ┣┓
 　　┃             ┃
 　　┗┓┓┏━┳┓┏┛
 　　　┃┫┫　┃┫┫
 　　　┗┻┛　┗┻┛
 * */

#import "CusAnnotationView.h"
#import "THLabel.h"

#define kWidth  150.f
#define kHeight 60.f

#define kHoriMargin 5.f
#define kVertMargin 5.f

#define kPortraitWidth  50.f
#define kPortraitHeight 50.f

#define kCalloutWidth   200.0
#define kCalloutHeight  70.0

@interface CusAnnotationView ()
{
    THLabel *nameLabel;
}

@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation CusAnnotationView

@synthesize portraitImageView   = _portraitImageView;
@synthesize nameLabel           = _nameLabel;

#pragma mark - Handle Action


#pragma mark - Override
//
//- (UIImage *)portrait
//{
//    return self.portraitImageView.image;
//}
//
//- (void)setPortrait:(UIImage *)portrait
//{
//    self.portraitImageView.image = portrait;
//}

//- (void)setSelected:(BOOL)selected
//{
//    [self setSelected:selected animated:NO];
//}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    if (self.selected == selected)
//    {
//        return;
//    }
//    
//    if (selected)
//    {
//        if (self.calloutView == nil)
//        {
//            /* Construct custom callout. */
//            self.calloutView = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth+20, kCalloutHeight+10)];
//            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
//                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.   calloutOffset.y);
//            
//            
//        }
//        
//        [self addSubview:self.calloutView];
//    }
//    else
//    {
//        [self.calloutView removeFromSuperview];
//    }
//    
//    [super setSelected:selected animated:animated];
//}
//
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
//{
//    BOOL inside = [super pointInside:point withEvent:event];
//    /* Points that lie outside the receiver’s bounds are never reported as hits, 
//     even if they actually lie within one of the receiver’s subviews. 
//     This can occur if the current view’s clipsToBounds property is set to NO and the affected subview extends beyond the view’s bounds.
//     */
//    if (!inside && self.selected)
//    {
//        inside = [self.calloutView pointInside:[self convertPoint:point toView:self.calloutView] withEvent:event];
//    }
//    
//    return inside;
//}

#pragma mark - Life Cycle

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.bounds = CGRectMake(0.f, 0.f, 100, 50);
        
        self.backgroundColor = [UIColor clearColor];
        
        
        UIImageView * pImg = [[UIImageView alloc]initWithFrame:CGRectZero];
        pImg.image = [UIImage imageNamed:@"pin_purple.png"];
        pImg.size = CGSizeMake(pImg.image.size.width/1.5, pImg.image.size.height/1.5);
        
        self.backgroundImage = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.backgroundImage.size = CGSizeMake(pImg.image.size.width/1.5, pImg.image.size.height/1.5);
        [self addSubview:self.backgroundImage];
        
        
        self.userHeadImage = [[UIImageView alloc]initWithFrame:CGRectMake(4, 4, pImg.width - 8,pImg.width - 8)];
        self.userHeadImage.layer.masksToBounds = YES;
        self.userHeadImage.layer.cornerRadius = self.userHeadImage.height/2;
        [self addSubview:self.userHeadImage];
        

        /* Create name label. */
        nameLabel = [[THLabel alloc] initWithFrame:CGRectMake(-10,
                                                              -30,
                                                              1,
                                                              1)];
        nameLabel.font = [UIFont systemFontOfSize:14.f];
        nameLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.75];
        nameLabel.shadowOffset = CGSizeMake(0.0, 2.0);
        nameLabel.shadowBlur = (5.0);
        nameLabel.innerShadowColor = [UIColor redColor];
        nameLabel.innerShadowOffset = CGSizeMake(0.0, 1.0);
        nameLabel.innerShadowBlur = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 4.0 : 2.0);
        nameLabel.strokeColor = [UIColor whiteColor];
        nameLabel.strokeSize = (3.0);
        nameLabel.gradientStartColor = [UIColor colorWithRed:255.0 / 255.0 green:193.0 / 255.0 blue:127.0 / 255.0 alpha:1.0];
        nameLabel.gradientEndColor = [UIColor colorWithRed:255.0 / 255.0 green:163.0 / 255.0 blue:64.0 / 255.0 alpha:1.0];
        nameLabel.userInteractionEnabled = YES;
        nameLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:nameLabel];
        
        self.bounds = CGRectMake(0.f, 0.f, pImg.width, 50);
    }
    
    return self;
}


- (void)setTitle4Focus:(NSString *)title
{
    nameLabel.text = title;
    
    //  Calculate width of name
    CGSize nameTextSize = [[LabelSize labelsizeManger] getStringRect:title MaxSize:CGSizeMake(App_Frame_Width - 30, 100) FontSize:14.0f];
    
    [nameLabel setWidth:nameTextSize.width + 20];
    [nameLabel setHeight:30];
}

@end
