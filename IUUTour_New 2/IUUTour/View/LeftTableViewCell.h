//
//  LeftTableViewCell.h
//  IUUTour
//
//  Created by Zhang on 12/31/15.
//  Copyright © 2015 DevDiv Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftTableViewCell : UITableViewCell


-(void)setDate:(NSString *)imagename selectImage:(NSString *)selectImage namestring:(NSString *)name rightImage:(NSString *)string select:(BOOL)selected;
-(void)cellUpdate:(NSString *)selectImage;

@end
