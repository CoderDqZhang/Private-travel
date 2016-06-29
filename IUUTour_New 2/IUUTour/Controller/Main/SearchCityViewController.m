#import "SearchCityViewController.h"
#import "CityModel.h"
#import "SearchTextField.h"

@interface SearchCityViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    NSMutableArray  *_hotCityArr;
    NSMutableArray  *_cityArr;
    
    NSArray         *_sectionArr;
    
    NSMutableArray  *_filterdSectionArr;

    NSMutableArray * _filteredCityArr;

    BOOL           isFiltering;
    
    UITableView     *_tableView;
}

@end

@implementation SearchCityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [self setupNavigation];
    self.title = @"选择城市";
    self.view.backgroundColor = [UIColor colorWithRed:40/255 green:39/255 blue:44/255 alpha:1.0];
    
//    self.titleLabel.text  = @"选择城市";
//    self.titleView.hidden = NO;
//    [self initWithBackBtn];
    
    UIView *searchBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, App_Frame_Width, 44)];
    searchBgView.backgroundColor = [UIColor colorWithRed:53/255 green:53/255 blue:53/255 alpha:1.0];
//    searchBgView.backgroundColor = [UIColor colorWithRed:0xf0/255.0f green:0xf1/255.0f blue:0xf3/255.0f alpha:1];
    [self.view addSubview:searchBgView];
    
    
    SearchTextField *_searchField = [[SearchTextField alloc ]initWithFrame:CGRectMake((App_Frame_Width-311)/2, 4, 311, 34)];
    _searchField.placeholder       = @"城市/行政区/拼音";
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
    @weakify(self);
    [[self rac_signalForSelector:@selector(textFieldShouldClear:)] subscribeNext:^(RACTuple *sender) {
        isFiltering = NO;
        
        _searchField.text=@"";
        
        [self.view endEditing:YES];
        
        [_tableView reloadData];
    }];
    
    
    [[self rac_signalForSelector:@selector(textFieldShouldReturn:) fromProtocol:@protocol(UITextFieldDelegate)] subscribeNext:^(RACTuple *sender) {
        UITextField *searchField = sender.first;
        
        @strongify(self);
        isFiltering = YES;
        
        [self.view endEditing:YES];
        
        [self filterCityListWithString:searchField.text];
        
        [_tableView reloadData];
    }];
    _searchField.delegate = self;
    
    [searchBgView addSubview:_searchField];
    
//    UITextField *_searchField = [[UITextField alloc ]initWithFrame:CGRectMake((App_Frame_Width-311)/2, 4, 311, 34)];
//    _searchField.placeholder       = @"城市/行政区/拼音";
////    _searchField.backgroundColor   = [UIColor colorWithWhite:1 alpha:1];
//    _searchField.backgroundColor = [UIColor whiteColor];
//    _searchField.clearButtonMode   = UITextFieldViewModeWhileEditing;
//
//    _searchField.textAlignment     = NSTextAlignmentCenter;
//    _searchField.returnKeyType     = UIReturnKeySearch;
//    _searchField.layer.cornerRadius = 4;
//    
//    @weakify(self);
//    [[self rac_signalForSelector:@selector(textFieldShouldClear:)] subscribeNext:^(RACTuple *sender) {
//        UITextField *searchField = sender.first;
//        
//        if (searchField.text.length <= 0)
//        {
//            return;
//        }
//
//        isFiltering = NO;
//        
//        searchField.text=@"";
//        
//        [self.view endEditing:YES];
//        
//        [_tableView reloadData];
//    }];
//    
//    
//    [[self rac_signalForSelector:@selector(textFieldShouldReturn:) fromProtocol:@protocol(UITextFieldDelegate)] subscribeNext:^(RACTuple *sender) {
//        UITextField *searchField = sender.first;
//
//        @strongify(self);
//        isFiltering = YES;
//        
//        [self.view endEditing:YES];
//        
//        [self filterCityListWithString:searchField.text];
//        
//        [_tableView reloadData];
//    }];
//    
//    
//    _searchField.delegate = self;
//
//    [searchBgView addSubview:_searchField];
    
    isFiltering = NO;
    

    _filterdSectionArr = [[NSMutableArray alloc]init];
    _filteredCityArr   = [[NSMutableArray alloc]init];
    

    _cityArr = [[NSMutableArray alloc] init];
    
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, searchBgView.bottom, App_Frame_Width, self.view.height - searchBgView.height) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = [UIColor colorWithRed:34.0/255.0 green:33.0/255.0 blue:38.0/255.0 alpha:1];
    _tableView.delegate   = self;
    _tableView.dataSource = self;
    _tableView.sectionIndexBackgroundColor=[UIColor clearColor];
    _tableView.sectionIndexColor = [UIColor lightGrayColor];
    [self.view addSubview:_tableView];

    
    _tableView.tableFooterView = [[UIView alloc] init];
 }

-(void)setupNavigation
{
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],NSForegroundColorAttributeName,
                                               [UIFont systemFontOfSize:18],
                                               NSFontAttributeName, nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    if (!IS_RUNNING_IOS7) {
        // support full screen on iOS 6
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
    }
    [self.navigationController.navigationBar setBackgroundImage:[UIImage createImageWithColor:NavigationColor] forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar setShadowImage:[UIImage createImageWithColor:[UIColor clearColor]]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    

    [self getHotCityList];


    [self getCityAction];
}

- (void)getCityAction
{
    [SVProgressHUD showWithOwner:@"SearchCityViewController_getCity"];
    
    __weak SearchCityViewController* weakSelf = self;
    [Interface getCityList:^(NSMutableArray *cityArr, NSError *error) {
        
        __strong SearchCityViewController* strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }
        
        if (cityArr.count != 0)
        {
            [strongSelf clearUpData:cityArr];
            strongSelf->_sectionArr = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
            [strongSelf->_tableView reloadData];
            
        }
        
        [SVProgressHUD dismissFromOwner:@"SearchCityViewController_getCity"];
    }];
}

- (void)getHotCityList
{
    __weak SearchCityViewController* weakSelf = self;
    [Interface getHotCityList:^(NSMutableArray *hotCityArr, NSError *error) {
        __strong SearchCityViewController* strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }
        
        if (hotCityArr.count != 0)
        {
            strongSelf->_hotCityArr = [NSMutableArray arrayWithArray:hotCityArr];
            
            strongSelf->_tableView.tableHeaderView = [strongSelf creatHeadView];
        }
    }];

}

- (void)selectCityAction:(void (^)(CityModel *))city
{
    self.selectCityBlock = city;
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)filterCityListWithString:(NSString*)searchText
{
    [_filteredCityArr removeAllObjects];
    [_filterdSectionArr removeAllObjects];
    
    NSString *originalText = searchText;
    NSString *nonSpacingText = [originalText stringByReplacingOccurrencesOfString:@" " withString:@""];
    

    NSString *foundKey = nil;
    BOOL found = NO;
    
    for (int i = 0; i < _cityArr.count; i ++)
    {
        NSMutableDictionary *dic = _cityArr[i];
        
        NSString *key = _sectionArr[i];
        NSMutableArray *arr = dic[key];
        
        for (CityModel *cityModel in arr)
        {
            if ([cityModel.cityName rangeOfString:nonSpacingText options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [cityModel.cityPinYin rangeOfString:nonSpacingText options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [_filteredCityArr addObject:cityModel];
                
                foundKey = key;
                
                found = YES;
            }
        }
    }
    
    if (found)
    {
        [_filterdSectionArr addObject:foundKey];
    }
}

#pragma mark tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 26;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 25)];
    headV.backgroundColor = [UIColor colorWithRed:34.0/255.0 green:33.0/255.0 blue:38.0/255.0 alpha:1];
//    headV.backgroundColor = [UIColor colorWithRed:0xf0/255.0 green:0xf1/255.0 blue:0xf3/255.0 alpha:1];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 25)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor lightGrayColor];
    [headV addSubview:label];
    
    label.text = _sectionArr[section];
    
    return headV;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isFiltering)
    {
        return _filterdSectionArr.count;
    }
    
    return _sectionArr.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isFiltering)
    {
        if (section > 0)
        {
            return 0;
        }
        
        return _filteredCityArr.count;
    }
    
    NSMutableDictionary *dic = _cityArr[section];
    NSString *keyStr = _sectionArr[section];
    NSMutableArray *arr = dic[keyStr];
    if (arr.count != 0)
    {
        return arr.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ind = @"CITYCELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ind];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ind];
    }
    
    if (isFiltering)
    {
        if (indexPath.row >= _filteredCityArr.count)
        {
            return cell;
        }
        
        CityModel *mm =_filteredCityArr[indexPath.row];
        cell.textLabel.text = mm.cityName;
    }
    else
    {
        NSMutableDictionary *dic = _cityArr[indexPath.section];
        NSString *keyStr = _sectionArr[indexPath.section];
        NSMutableArray *arr = dic[keyStr];

        
        CityModel *mm = arr[indexPath.row];
        cell.textLabel.text = mm.cityName;
        
    }
    cell.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:53.0/255.0 blue:53.0/255.0 alpha:1];
    cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CityModel *mm = nil;
    
    if (isFiltering)
    {
        mm = _filteredCityArr[indexPath.row];
    }
    else
    {
        NSMutableDictionary *dic = _cityArr[indexPath.section];
        NSString *keyStr = _sectionArr[indexPath.section];
        NSMutableArray *arr = dic[keyStr];

        mm = arr[indexPath.row];
    }
    
    if (self.selectCityBlock)
    {
        self.selectCityBlock(mm);
    }
    [self backAction];
}


//返回索引栏的列别数据
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _sectionArr;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)creatHeadView
{
    UIView *vv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 170)];
    vv.tag = 1011;
    vv.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:53.0/255.0 blue:53.0/255.0 alpha:1];
    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 40)];
//    label.backgroundColor = [UIColor whiteColor];
//    label.font            = [UIFont systemFontOfSize:16];
//    label.text            = [NSString stringWithFormat:@"    当前搜索关键字：%@",self.selectCity];
//    [vv addSubview:label];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.font            = [UIFont systemFontOfSize:16];
    label.text            = @"    热门国内城市";
    label.textColor = [UIColor lightGrayColor];
    [vv addSubview:label];
    
    float btnW = (App_Frame_Width - 75)/4;
    float spaceH = 15;
    float spaceV = 15;
    
    for (int i = 0; i < 3; i ++)
    {
        for (int j = 0; j < 4; j++)
        {
            CityModel *mm = _hotCityArr[i*4+j];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame              = CGRectMake(spaceH + spaceH*j + btnW*j, CGRectGetMaxY(label.frame) + 8 + spaceV*i + 30*i, btnW, 30);
            btn.layer.cornerRadius = 4;
            btn.backgroundColor    = [UIColor colorWithRed:53.0/255.0 green:53.0/255.0 blue:53.0/255.0 alpha:1];
            btn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            btn.layer.borderWidth = 0.5f;
            [btn setTitle:mm.cityName forState:
             UIControlStateNormal];
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            btn.tag = i*4+j;
            
            if ([self.selectCity isEqualToString:btn.titleLabel.text])
            {
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                btn.backgroundColor = ButtonColorB;
            }
            [btn addTarget:self action:@selector(hotCityAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [vv addSubview:btn];
        }
    }
    
    
    return vv;

}

- (void)hotCityAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor greenColor];
    
    CityModel *mm = _hotCityArr[button.tag];
    
    if (self.selectCityBlock)
    {
        self.selectCityBlock(mm);
    }
    UIView *vv = _tableView.tableHeaderView;
    
    for (id sub in vv.subviews)
    {
        if ([sub isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)sub;
            if (btn.tag != button.tag)
            {
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                btn.backgroundColor = [UIColor whiteColor];
            }
            else
            {
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                btn.backgroundColor = [UIColor greenColor];
            }
        }
    }

    [self backAction];
}

//重新分配数据
- (void)clearUpData:(NSMutableArray *)arr
{
    NSMutableDictionary *aDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *aArr = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *bDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *bArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *cDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *cArr = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *dDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *dArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *eDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *eArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *fDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *fArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *gDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *gArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *hDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *hArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *iDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *iArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *jDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *jArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *kDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *kArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *lDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *lArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *mArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *nDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *nArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *oDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *oArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *pDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *pArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *qDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *qArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *rDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *rArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *sDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *sArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *tDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *tArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *uDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *uArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *vDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *vArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *wDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *wArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *xDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *xArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *yDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *yArr = [[NSMutableArray alloc] init];

    NSMutableDictionary *zDic = [[NSMutableDictionary alloc] init];
    NSMutableArray      *zArr = [[NSMutableArray alloc] init];

    
    for (int i = 1; i < arr.count ; i ++)
    {
        CityModel *mm = arr[i];
        
        NSString *pinYin = mm.cityPinYin;
        NSString *fchair = [pinYin substringToIndex:1];
        if ([self sameChair:fchair toChair:@"A"] )
        {
            [aArr addObject:mm];
        }
        else if ([self sameChair:fchair toChair:@"B"])
        {
            [bArr addObject:mm];
        }
        else if ([self sameChair:fchair toChair:@"C"])
        {
            [cArr addObject:mm];
        }
        else if ([self sameChair:fchair toChair:@"D"])
        {
            [dArr addObject:mm];
            
        }else if ([self sameChair:fchair toChair:@"E"])
        {
            [eArr addObject:mm];
            
        }else if ([self sameChair:fchair toChair:@"F"])
        {
            [fArr addObject:mm];
        }
        else if ([self sameChair:fchair toChair:@"G"])
        {
            [gArr addObject:mm];
        }
        else if ([self sameChair:fchair toChair:@"H"])
        {
            [hArr addObject:mm];
        }
        else if ([self sameChair:fchair toChair:@"I"])
        {
            [iArr addObject:mm];
        }
        else if ([self sameChair:fchair toChair:@"J"])
        {
            [jArr addObject:mm];
        }
        else if ([self sameChair:fchair toChair:@"K"])
        {
            [kArr addObject:mm];
            
        }else if ([self sameChair:fchair toChair:@"L"]){
            [lArr addObject:mm];
            
        }else if ([self sameChair:fchair toChair:@"M"]){
            [mArr addObject:mm];
            
        }else if ([self sameChair:fchair toChair:@"N"]){
            [nArr addObject:mm];
            
        }else if ([self sameChair:fchair toChair:@"O"]){
            [oArr addObject:mm];
            
        }else if ([self sameChair:fchair toChair:@"P"]){
            [pArr addObject:mm];
            
        }else if ([self sameChair:fchair toChair:@"Q"]){
            [qArr addObject:mm];
        }
        else if ([self sameChair:fchair toChair:@"R"])
        {
            [rArr addObject:mm];
        }else if ([self sameChair:fchair toChair:@"S"])
        {
            [sArr addObject:mm];
        }else if ([self sameChair:fchair toChair:@"T"])
        {
            [tArr addObject:mm];
            
        }else if ([self sameChair:fchair toChair:@"U"]){
            [uArr addObject:mm];
            
        }else if ([self sameChair:fchair toChair:@"V"]){
            [vArr addObject:mm];
            
        }else if ([self sameChair:fchair toChair:@"W"]){
            [wArr addObject:mm];
            
        }else if ([self sameChair:fchair toChair:@"X"]){
            [xArr addObject:mm];
            
        }else if ([self sameChair:fchair toChair:@"Y"]){
            [yArr addObject:mm];
            
        }else if ([self sameChair:fchair toChair:@"Z"])
        {
            [zArr addObject:mm];
        }
    }
    
    [aDic setObject:aArr forKey:@"A"];
    [bDic setObject:bArr forKey:@"B"];
    [cDic setObject:cArr forKey:@"C"];
    [dDic setObject:dArr forKey:@"D"];
    [eDic setObject:eArr forKey:@"E"];
    [fDic setObject:fArr forKey:@"F"];
    [gDic setObject:gArr forKey:@"G"];
    [hDic setObject:hArr forKey:@"H"];
    [iDic setObject:iArr forKey:@"I"];
    [jDic setObject:jArr forKey:@"J"];
    [kDic setObject:kArr forKey:@"K"];
    [lDic setObject:lArr forKey:@"L"];
    [mDic setObject:mArr forKey:@"M"];
    [nDic setObject:nArr forKey:@"N"];
    [oDic setObject:oArr forKey:@"O"];
    [pDic setObject:pArr forKey:@"P"];
    [qDic setObject:qArr forKey:@"Q"];
    [rDic setObject:rArr forKey:@"R"];
    [sDic setObject:sArr forKey:@"S"];
    [tDic setObject:tArr forKey:@"T"];
    [uDic setObject:uArr forKey:@"U"];
    [vDic setObject:vArr forKey:@"V"];
    [wDic setObject:wArr forKey:@"W"];
    [xDic setObject:xArr forKey:@"X"];
    [yDic setObject:yArr forKey:@"Y"];
    [zDic setObject:zArr forKey:@"Z"];

    [_cityArr addObject:aDic];
    [_cityArr addObject:bDic];
    [_cityArr addObject:cDic];
    [_cityArr addObject:dDic];
    [_cityArr addObject:eDic];
    [_cityArr addObject:fDic];
    [_cityArr addObject:gDic];
    [_cityArr addObject:hDic];
    [_cityArr addObject:iDic];
    [_cityArr addObject:jDic];
    [_cityArr addObject:kDic];
    [_cityArr addObject:lDic];
    [_cityArr addObject:mDic];
    [_cityArr addObject:nDic];
    [_cityArr addObject:oDic];
    [_cityArr addObject:pDic];
    [_cityArr addObject:qDic];
    [_cityArr addObject:rDic];
    [_cityArr addObject:sDic];
    [_cityArr addObject:tDic];
    [_cityArr addObject:uDic];
    [_cityArr addObject:vDic];
    [_cityArr addObject:wDic];
    [_cityArr addObject:xDic];
    [_cityArr addObject:yDic];
    [_cityArr addObject:zDic];
}

- (BOOL)sameChair:(NSString *)chair1 toChair:(NSString *)chair2
{
    BOOL result = [chair1 caseInsensitiveCompare:chair2] == NSOrderedSame;
    
    return result;
}
@end
