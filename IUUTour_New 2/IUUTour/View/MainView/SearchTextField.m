//
//  SearchTextField.m
//  IUUTour
//
//  Created by Zhang on 1/7/16.
//  Copyright © 2016 DevDiv Technology. All rights reserved.
//

#import "SearchTextField.h"

@implementation SearchTextField

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect incoRect = [super leftViewRectForBounds:bounds];
    incoRect.origin.x += 10;
    return incoRect;
}

//-(CGRect)placeholderRectForBounds:(CGRect)bounds
//{
//    CGRect placeholderRect = [super placeholderRectForBounds:bounds];
//    placeholderRect.origin.x += 10;
//    return placeholderRect;
//}

-(CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect textRect = [super textRectForBounds:bounds];
    textRect.origin.x += 10;
    textRect.origin.y += 1;
    return textRect;
}

@end
