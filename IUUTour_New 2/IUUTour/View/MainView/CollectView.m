//
//  CollectView.m
//  IUUTour
//
//  Created by Zhang on 12/31/15.
//  Copyright © 2015 DevDiv Technology. All rights reserved.
//

#import "CollectView.h"
#import "CollectionViewCell.h"
#import "SearchTextField.h"

@implementation CollectView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _collectView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:[self createLayout]];
        _collectView.delegate = self;
        _collectView.dataSource = self;
        _collectView.backgroundColor = [UIColor colorWithRed:(40.0 / 255.0) green:(40.0/255.0) blue:(44.0/255.0) alpha:1.0f];
        [_collectView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView"];
        [_collectView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"CollectionCell"];
        [self addSubview:_collectView];
    }
    return self;
}

-(void)setHederView:(UICollectionReusableView *)headerView
{
    UIView *header = [[UIView alloc] init];
    header.frame = CGRectMake(0, 0, App_Frame_Width, 96);
    header.backgroundColor = NavigationColor;
    [headerView addSubview:header];
    
    UIImage *iuuIco = [UIImage imageNamed:@"iuu"];
    UIImageView *iuuIcoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 25, iuuIco.size.width, iuuIco.size.height)];
    iuuIcoView.image = iuuIco;
    [header addSubview:iuuIcoView];

//    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(iuuIcoView.frame.size.width + 20, 10, App_Frame_Width - iuuIcoView.frame.size.width - 20 - 60, 40)];
//    searchBar.backgroundColor = [UIColor colorWithRed:56/255.0 green:56/255.0 blue:59/255.0 alpha:1.0];
//    searchBar.placeholder = @"搜索目的地/景点/路径";
////    searchBar.backgroundColor=[UIColor clearColor];
//    for (UIView *subview in searchBar.subviews)
//    {
//        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
//        {
//            [subview removeFromSuperview];
//            break;  
//        }   
//    }
//    searchBar.layer.cornerRadius = 3;
//    [header addSubview:searchBar];
    
    SearchTextField *_searchField = [[SearchTextField alloc ]initWithFrame:CGRectMake(iuuIcoView.frame.size.width + 20, 13, App_Frame_Width - iuuIcoView.frame.size.width - 20 - 60, 34)];
    _searchField.placeholder       = @"搜索目的地/景点/路径";
    _searchField.clearButtonMode   = UITextFieldViewModeWhileEditing;

    _searchField.textAlignment     = NSTextAlignmentLeft;
    _searchField.returnKeyType     = UIReturnKeySearch;
    _searchField.layer.cornerRadius = 3;
    UIImageView *search = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search.png"]];
    _searchField.leftView = search;
    _searchField.leftViewMode = UITextFieldViewModeAlways;
    _searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _searchField.backgroundColor = [UIColor colorWithRed:56/255.0 green:56/255.0 blue:59/255.0 alpha:1.0];
    _searchField.textColor = [UIColor whiteColor];
    [_searchField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_searchField setValue:[UIFont systemFontOfSize:15.f] forKeyPath:@"_placeholderLabel.font"];
    [[self rac_signalForSelector:@selector(textFieldShouldClear:)] subscribeNext:^(RACTuple *sender) {
        UITextField *searchField = sender.first;

        if (searchField.text.length <= 0)
        {
            return;
        }


        searchField.text=@"";

        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }];


    [[self rac_signalForSelector:@selector(textFieldShouldReturn:) fromProtocol:@protocol(UITextFieldDelegate)] subscribeNext:^(RACTuple *sender) {
        UITextField *searchField = sender.first;

        NSString *nonSpacingText1 = [searchField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([nonSpacingText1 length] <= 0)
        {
            [UWindowHud hudWithType:kToastType withContentString:@"请输入搜索内容！"];
            return;
        }

        [headerView endEditing:YES];

        [_delegate searchText:nonSpacingText1];
//        NSString *nonSpacingText = [self->_cityLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""];
//
//        self->lastLocatedOrSelectedCity = [NSString stringWithString:nonSpacingText];
//
//        [self loadSearchResult:searchField.text];
        
        searchField.text=@"";
        [searchField resignFirstResponder];
    }];
    _searchField.delegate = self;

    [header addSubview:_searchField];
    
    UIButton *map = [UIButton buttonWithType:UIButtonTypeCustom];
    [map setImage:[UIImage imageNamed:@"mapstyle"] forState:UIControlStateNormal];
    [map setFrame:CGRectMake(App_Frame_Width -50, 7, 40, 40)];
    [header addSubview:map];
    [headerView addSubview:header];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, App_Frame_Width, 39)];
    bgView.backgroundColor = [UIColor colorWithRed:(40.0 / 255.0) green:(40.0/255.0) blue:(44.0/255.0) alpha:1.0f];
    
    UILabel *scenryStyle = [[UILabel alloc] initWithFrame:CGRectMake(22, 12, App_Frame_Width, 15)];
    scenryStyle.text = @"周边景点";
    scenryStyle.font = [UIFont systemFontOfSize:15.0];
    scenryStyle.textColor = [UIColor whiteColor];
    scenryStyle.backgroundColor = [UIColor clearColor];
    [bgView addSubview:scenryStyle];
    
    UILabel *lableBg = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, 4, 15)];
    lableBg.textColor = [UIColor whiteColor];
    lableBg.backgroundColor = [UIColor whiteColor];
    
    [bgView addSubview:lableBg];
    
    [headerView addSubview:bgView];
}

-(UICollectionViewFlowLayout *)createLayout
{
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    return layout;
}

//通过设置SupplementaryViewOfKind 来设置头部或者底部的view，其中 ReuseIdentifier 的值必须和 注册是填写的一致，本例都为 “reusableView”
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView" forIndexPath:indexPath];
        headerView.backgroundColor = NavigationColor;
        [self setHederView:headerView];
        return headerView;
    }else{
        return nil;
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.tourModelArray.count > 8) {
        return 4;
    }else{
        return self.tourModelArray.count - 4;
    }
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"CollectionCell";
    CollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setData:[_tourModelArray objectAtIndex:indexPath.row + 4] distance:[_cityLatLon objectAtIndex:indexPath.row + 4]];
    cell.backgroundColor = [UIColor colorWithRed:(40.0 / 255.0) green:(40.0/255.0) blue:(44.0/255.0) alpha:1.0f];
    
    return cell;
}


#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(App_Frame_Width/2-3.5, 155.5);
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 7;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 15;
}

//header的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(App_Frame_Width, 100);
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    cell.backgroundColor = [UIColor whiteColor];
    [_delegate mainTableDelegate:[self.tourModelArray objectAtIndex:indexPath.row + 4]];
}
//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


@end
