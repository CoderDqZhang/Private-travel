//
//  ImgListViewController.m
//  IUUTour
//
//  Created by admin on 16/1/7.
//  Copyright (c) 2016年 DevDiv Technology. All rights reserved.
//

#import "ImgListViewController.h"

@interface ImgListViewController ()

@end

@implementation ImgListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initScrollView];
}

-(void)initScrollView{
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(exitImgView)];
    gesture.numberOfTapsRequired    = 1;
    gesture.numberOfTouchesRequired = 1;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, App_Frame_Height)];
    scrollView.backgroundColor = [UIColor blackColor];
    scrollView.scrollEnabled = YES;
    scrollView.pagingEnabled = YES;
    scrollView.contentOffset = CGPointMake(self.index * App_Frame_Width, 0);
    scrollView.contentSize = CGSizeMake(App_Frame_Width*self.urlArray.count, App_Frame_Height);
    [scrollView addGestureRecognizer:gesture];
    [self.view addSubview:scrollView];
    
    for (int i = 0 ; i < self.urlArray.count; i++) {
        NSString *string = self.urlArray[i];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*App_Frame_Width, 0, App_Frame_Width, App_Frame_Height)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView sd_setImageWithURL:[NSURL URLWithString:string] placeholderImage:[UIImage imageNamed:@"placeholder_common"]options:SDWebImageProgressiveDownload | SDWebImageRetryFailed];
        [scrollView addSubview:imageView];
    }
}

-(void)exitImgView{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
