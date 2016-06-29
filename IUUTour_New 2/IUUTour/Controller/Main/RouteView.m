//
//  RouteView.m
//  Manyou
//
//  Created by Yang Eastern on 14/12/15.
//  Copyright (c) 2014年 yangjf. All rights reserved.
//
//
//  Comment by Vincent
//  It's used in ScenicSpotGuideViewController only


#import "RouteView.h"

@implementation RouteView

@synthesize lines;
@synthesize scenicSpots;
@synthesize mapScale;

@synthesize maxMapX;
@synthesize maxMapY;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    float width     = rect.size.width;
    float height    = rect.size.height;

    float lineWight = 2;
    float lineArrow = 10;
    float lineArrowAngel = M_PI_2 / 3;
    
    // Drawing code
    CGContextRef ref = UIGraphicsGetCurrentContext();
    //    CGContextSetShouldAntialias(ref, NO);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {0.0, 0.0, 0.0, 1.0};
    
    UIColor *color = [UIColor redColor];
    [color getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];

    CGContextSetLineWidth(ref, lineWight);
    CGContextSetLineCap(ref, kCGLineCapRound);
    CGContextSetStrokeColor(ref, components);
    CGFloat lengths[] = {5,5};

    NSInteger count = [lines count];
    for (NSInteger i = 0; i < count; i ++) {
        NSDictionary *line  = [lines objectAtIndex:i];
        NSString *aspotId   = [line objectForKey:A_Spot_Id];
        NSDictionary *aspot = [scenicSpots objectForKey:aspotId];

        NSString *bspotId   = [line objectForKey:B_Spot_Id];
        NSDictionary *bspot = [scenicSpots objectForKey:bspotId];

        NSArray *subLines   = [line objectForKey:Recommend_Line_Section_Guide];

        float fromX         = [[aspot objectForKey:Relative_Longitude] floatValue] / maxMapX * width;
        float fromY         = (height - [[aspot objectForKey:Relative_Latitude] floatValue] / maxMapY * height);

        float endX          = [[bspot objectForKey:Relative_Longitude] floatValue] / maxMapX * width;
        float endY          = (height - [[bspot objectForKey:Relative_Latitude] floatValue] / maxMapY * height);
        
        //画中间线段，不带箭头
        CGContextSetLineDash(ref, 0, lengths, 2);
        for (NSDictionary *subLinePoint in subLines) {
            float toX = [[subLinePoint objectForKey:Relative_Longitude] floatValue] / maxMapX * width;
            float toY = (height - [[subLinePoint objectForKey:Relative_Latitude] floatValue] / maxMapY * height);
            
            CGContextMoveToPoint(ref, fromX, fromY);
            CGContextAddLineToPoint(ref, toX, toY);
            CGContextStrokePath(ref);
            
            fromX = toX;
            fromY = toY;
        }
        
        //画最后一个线段
        CGContextMoveToPoint(ref, fromX, fromY);
        CGContextAddLineToPoint(ref, endX, endY);
        CGContextStrokePath(ref);
        
        if (i == count - 1) {
            //整个路线最后终点，画箭头
            //画箭头短线段
            //线段的弧度
            CGContextSetLineDash(ref, 0, NULL, 0);
            float angle  = 0;
            float deltaX = endX - fromX;
            float deltaY = endY - fromY;
            //NSLog(@"deltaX:%f deltaY:%f", deltaX, deltaY);
            float l      = sqrtf(deltaX * deltaX + deltaY * deltaY);//斜边
            if (deltaY > 0) {
            angle = acosf(deltaX / l);
            }
            else {
            angle = M_PI * 2 - acosf(deltaX / l);
            }
            //NSLog(@"angle:%f", angle);
            float arrowAngle1 = angle - lineArrowAngel;
            float delta_y1    = lineArrow * sinf(arrowAngle1);
            float delta_x1    = lineArrow * cosf(arrowAngle1);
            CGContextMoveToPoint(ref, (endX - delta_x1), (endY - delta_y1));

            CGContextAddLineToPoint(ref, endX, endY);

            float arrowAngle2 = angle + lineArrowAngel;
            float delta_y2    = lineArrow * sinf(arrowAngle2);
            float delta_x2    = lineArrow * cosf(arrowAngle2);
            CGContextAddLineToPoint(ref, (endX - delta_x2), (endY - delta_y2));
            CGContextStrokePath(ref);
        }
    }
    
    CGColorSpaceRelease(colorSpace);
}

- (void)setMapScale:(float)newMapScale {
    mapScale = newMapScale;
    float oldWidth = self.frame.size.width;
    float oldHeight = self.frame.size.height;
    self.frame = CGRectMake(0, 0, oldWidth * mapScale, oldHeight * mapScale);
}
@end
