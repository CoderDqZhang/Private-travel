//
//  CusAnnotationView.m
//  MAMapKit_static_demo
//
//  Created by songjian on 13-10-16.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "MapCusAnnotationView.h"
#import "CustomCalloutView.h"
#import "THLabel.h"

#define kWidth          100.f
#define kHeight         60.f

#define kHoriMargin     5.f
#define kVertMargin     5.f

#define kPortraitWidth  50.f
#define kPortraitHeight 50.f

#define kCalloutWidth   180.0
#define kCalloutHeight  60.0


@interface MapCusAnnotationView ()

@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) THLabel     *nameLabel;
@property (nonatomic        ) BOOL        isCalloutOn;

@end

@implementation MapCusAnnotationView

@synthesize calloutView;
@synthesize portraitImageView   = _portraitImageView;
@synthesize nameLabel           = _nameLabel;

#pragma mark - Handle Action

- (void)btnAction
{
    CLLocationCoordinate2D coorinate = [self.annotation coordinate];
    
    NSLog(@"1111coordinate = {%f, %f}", coorinate.latitude, coorinate.longitude);
}

#pragma mark - Override

- (NSString *)name
{
    return self.nameLabel.text;
}

- (void)setName:(NSString *)name
{
    self.nameLabel.text = name;
    
    //  Calculate width of name
    CGSize nameTextSize = [[LabelSize labelsizeManger] getStringRect:name MaxSize:CGSizeMake(App_Frame_Width - 30, 100) FontSize:14.0f];
    
    [self.nameLabel setWidth:nameTextSize.width + 20];
}

- (UIImage *)portrait
{
    return self.portraitImageView.image;
}

- (void)setPortrait:(UIImage *)portrait
{
    self.portraitImageView.image = portrait;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (!self.isCallOnAvailable)
    {
        return;
    }

    if (self.isCalloutOn == selected)
    {
        return;
    }
    
    [self switchSlectionManually:animated];
}


- (void)switchSlectionManually:(BOOL)animated
{
    if (!self.isCalloutOn)
    {
        if (self.calloutView == nil)
        {
            [self btnAction];
            
            /* Construct custom callout. */
            self.calloutView = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
            
            
            self.voiceBtn.frame = CGRectMake(10, 5, self.calloutView.width/2 -10 , self.calloutView.height-20);
            [self.calloutView addSubview:self.voiceBtn];
            
            
            self.comeHereBtn.frame = CGRectMake(self.voiceBtn.right, 5, self.calloutView.width/2-10 , self.calloutView.height-20);
            [self.calloutView addSubview:self.comeHereBtn];
            
            
            self.closeBtn.frame = CGRectMake(self.calloutView.width - 15, 0, 15, 15);
            [self.closeBtn addTarget:self
                              action:@selector(mapCloseAction:)
                    forControlEvents:(UIControlEventTouchUpInside)];
            
            [self.calloutView addSubview:self.closeBtn];
        }
        
        [self addSubview:self.calloutView];
        
        self.isCalloutOn = YES;
    }
    else
    {
        self.isCalloutOn = NO;
        [self.calloutView removeFromSuperview];
    }
    
    [super setSelected:self.isCalloutOn animated:animated];
}

- (void)mapCloseAction:(UIButton *)sender
{
    self.isCalloutOn = NO;
    [self.calloutView removeFromSuperview];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL inside = [self.nameLabel pointInside:point withEvent:event];
    /* Points that lie outside the receiver’s bounds are never reported as hits, 
     even if they actually lie within one of the receiver’s subviews. 
     This can occur if the current view’s clipsToBounds property is set to NO and the affected subview extends beyond the view’s bounds.
     */
    if (!inside && self.selected)
    {
        inside = [self.calloutView pointInside:[self convertPoint:point toView:self.calloutView] withEvent:event];
    }
    
    return inside;
}

#pragma mark - Life Cycle

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    self.isCalloutOn = NO;
    
    if (self)
    {
        self.bounds = CGRectMake(0.f, 0.f, 300, 100);
        
        self.backgroundColor = [UIColor clearColor];
 
        //  This image show nothing, and adds padding between image and nameLabel only
        self.portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kHoriMargin, kVertMargin, 10, 10)];
        [self addSubview:self.portraitImageView];
        
        /* Create name label. */
        self.nameLabel = [[THLabel alloc] initWithFrame:CGRectMake(self.portraitImageView.width + kHoriMargin,
                                                                   0,
                                                                   kWidth - self.portraitImageView.width - kHoriMargin,
                                                                   20)];
        self.nameLabel.font = [UIFont systemFontOfSize:14.f];
        self.nameLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.75];
        self.nameLabel.shadowOffset = CGSizeMake(0.0, 2.0);
        self.nameLabel.shadowBlur = (5.0);
        self.nameLabel.innerShadowColor = [UIColor redColor];
        self.nameLabel.innerShadowOffset = CGSizeMake(0.0, 1.0);
        self.nameLabel.innerShadowBlur = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 4.0 : 2.0);
        self.nameLabel.strokeColor = [UIColor whiteColor];
        self.nameLabel.strokeSize = (3.0);
        self.nameLabel.gradientStartColor = [UIColor colorWithRed:255.0 / 255.0 green:193.0 / 255.0 blue:127.0 / 255.0 alpha:1.0];
        self.nameLabel.gradientEndColor = [UIColor colorWithRed:255.0 / 255.0 green:163.0 / 255.0 blue:64.0 / 255.0 alpha:1.0];
        self.nameLabel.userInteractionEnabled = YES;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pot:)];
        [self.nameLabel addGestureRecognizer:tap];
        [self addSubview:self.nameLabel];
        
        
        self.voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.voiceBtn setBackgroundColor:[UIColor clearColor]];
        [self.voiceBtn setImage:[UIImage imageNamed:@"img_map_voice_playing.png"] forState:(UIControlStateNormal)];
        [self.voiceBtn setTitle:@"语音讲解" forState:(UIControlStateNormal)];
        [self.voiceBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
        self.voiceBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        
        
        self.comeHereBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.comeHereBtn setBackgroundColor:[UIColor clearColor]];
        [self.comeHereBtn setImage:[UIImage imageNamed:@"detail_more_share.png"] forState:(UIControlStateNormal)];
        [self.comeHereBtn setTitle:@"到这儿去" forState:(UIControlStateNormal)];
        [self.comeHereBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
        self.comeHereBtn.titleLabel.font = [UIFont systemFontOfSize:13];

        
        self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeBtn setBackgroundColor:[UIColor clearColor]];
        [self.closeBtn setImage:[UIImage imageNamed:@"closeIcon.png"] forState:(UIControlStateNormal)];
    }
    
    return self;
}

- (void)pot:(UITapGestureRecognizer *)tap
{
    [self switchSlectionManually:NO];
    //[self setSelected:YES	 animated:NO];
}
@end
