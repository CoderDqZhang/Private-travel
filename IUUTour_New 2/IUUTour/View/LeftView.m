//
//  LeftView.m
//  IUUTour
//
//  Created by Zhang on 12/31/15.
//  Copyright © 2015 DevDiv Technology. All rights reserved.
//

#import "LeftView.h"
#import "LeftTableViewCell.h"
#import "GBPathImageView.h"

#define PhotoViewHeight 73
#define OvalPhotoViewHeight 145
@implementation LeftView

-(instancetype)initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.mainTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 250, APP_Screen_Height) style:UITableViewStylePlain];
        self.mainTable.backgroundColor = LeftBackColor;
        self.mainTable.layer.borderColor = [LeftBackColor CGColor];
        self.mainTable.layer.borderWidth = 1.0;
        self.mainTable.delegate = self;
        self.mainTable.dataSource  = self;
        [self.mainTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        self.mainTable.tableHeaderView = [self tableHeaderView];
        self.mainTable.tableHeaderView.height = 200;
        [self addSubview:self.mainTable];
        
        NSIndexPath *tableSelect = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.mainTable selectRowAtIndexPath:tableSelect animated:YES scrollPosition:UITableViewScrollPositionBottom];
        [self.mainTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return self;
}

-(UIView*)tableHeaderView
{
    UIView *userView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 245)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSURL *portraitUrl = [NSURL URLWithString:[User sharedInstance].userpic];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:portraitUrl
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (image) {
                                    
                                    GBPathImageView *squareImage = [[GBPathImageView alloc] initWithFrame:CGRectMake((250-PhotoViewHeight)/2, 63, PhotoViewHeight, PhotoViewHeight) image:image pathType:GBPathImageViewTypeCircle pathColor:[UIColor clearColor] borderColor:[UIColor clearColor] pathWidth:1];
                                    [userView addSubview:squareImage];
                                }
                            }];
    });
    
    
    UIImageView *photoView = [[UIImageView alloc] initWithFrame:CGRectMake((userView.frame.size.width-OvalPhotoViewHeight)/2, 28, OvalPhotoViewHeight, OvalPhotoViewHeight)];
    photoView.image = [UIImage imageNamed:@"oval"];
    [userView addSubview:photoView];
    
    
    UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(0, photoView.frame.size.height + photoView.frame.origin.y + 14, 250, 15)];
    userName.font = [UIFont systemFontOfSize:15.0];
    userName.text = [User sharedInstance].nickname;
    
    userName.textAlignment = NSTextAlignmentCenter;
    userName.textColor = [UIColor whiteColor];
    [userView addSubview:userName];
    
    return userView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return [self tableHeaderView];
//}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdetify = @"nomalInfo";
    LeftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
    if (!cell) {
        cell = [[LeftTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdetify];
    }
    cell.userInteractionEnabled = YES;
//    UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 4)];
//    cellView.backgroundColor = [UIColor blueColor];
//    [cell.contentView addSubview:cellView];
    [cell setDate:[self.leftImageArray objectAtIndex:indexPath.row] selectImage:[self.selectImageArray objectAtIndex:indexPath.row]  namestring:[self.nameArray objectAtIndex:indexPath.row] rightImage:@"houzhui" select:cell.selected];
    UIView *view_bg = [[UIView alloc]initWithFrame:cell.frame];
    view_bg.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = view_bg;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate tableViewSelect:indexPath];
}


@end
