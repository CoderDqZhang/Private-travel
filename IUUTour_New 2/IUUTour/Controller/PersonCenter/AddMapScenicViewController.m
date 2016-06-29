#import "AddMapScenicViewController.h"
#import "BDDynamicTreeNode.h"
#import "ZipArchive.h"
#import "DownResource.h"
#import "AFDownloadRequestOperation.h"
#import "OfflineMapDownloader.h"

@interface AddMapScenicViewController ()<BDDynamicTreeDelegate, UITextFieldDelegate>
{
    BDDynamicTree   *_dynamicTree;
    NSMutableArray  *mapListArr;
    NSMutableArray  *arrFilterResult;
    NSMutableArray  *searchResultArr;
    NSString        *zipFilePath;

    NSString        *canNai;
    NSString        *scenicID;
    UIButton        *button;
    NSDictionary    *dic;
}
@end

@implementation AddMapScenicViewController

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.titleLabel.text  = @"添加地图";
    self.titleView.hidden = NO;
    [self initWithBackBtn];
    
    UIView *searchBgView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleView.frame), App_Frame_Width, 44)];
    searchBgView.backgroundColor = [UIColor colorWithRed:0xf0/255.0f green:0xf1/255.0f blue:0xf3/255.0f alpha:1];
    [self.view addSubview:searchBgView];
    
    UITextField *_searchField = [[UITextField alloc ]initWithFrame:CGRectMake(10, 4, App_Frame_Width - 20, 36)];
    _searchField.placeholder       = @"请输入景区名称/城市/省份";
    _searchField.backgroundColor   = [UIColor colorWithWhite:1 alpha:1];
    _searchField.clearButtonMode   = UITextFieldViewModeWhileEditing;

    _searchField.textAlignment     = NSTextAlignmentCenter;
    _searchField.returnKeyType     = UIReturnKeySearch;
    _searchField.layer.cornerRadius = 18;
    
    @weakify(self);
    [[self rac_signalForSelector:@selector(textFieldShouldClear:)] subscribeNext:^(RACTuple *sender) {
        UITextField *searchField = sender.first;
        
        if (searchField.text.length <= 0)
        {
            return;
        }
        
        @strongify(self);

        
        searchField.text=@"";
        
        [self reloadData];
        
        [self performSelector:@selector(unfoldHandlingScene) withObject:nil afterDelay:0.0f];
        
        [self.view endEditing:YES];
    }];
    
    
    [[self rac_signalForSelector:@selector(textFieldShouldReturn:) fromProtocol:@protocol(UITextFieldDelegate)] subscribeNext:^(RACTuple *sender) {
        UITextField *searchField = sender.first;
        @strongify(self);
        
        [self.view endEditing:YES];
        
        [self loadSearchResult:searchField.text];
    }];
    
    _searchField.delegate = self;
    [searchBgView addSubview:_searchField];
    
    
    mapListArr = [[NSMutableArray alloc] init];
    
    searchResultArr = [[NSMutableArray alloc] init];
    
    OfflineMapDownloader *downloader = [OfflineMapDownloader sharedInstance];
    [downloader.doneArray removeAllObjects];
    
    [self loadAllListAndUnfold];
}

- (void)unfoldHandlingScene
{
    OfflineMapDownloader *downloader = [OfflineMapDownloader sharedInstance];
    
    NSString *selectedSceneId = nil;
    for (NSDictionary *handlingDic in downloader.handlingArray)
    {
        NSString *sceneId = [handlingDic.allKeys objectAtIndex:0];
        if (sceneId)
        {
            if (!selectedSceneId)
            {
                selectedSceneId = sceneId;
            }
            
            [self->_dynamicTree unfoldScene:sceneId];
        }
    }
    
    for (NSString *sceneId in downloader.failureArray)
    {
        if (!selectedSceneId)
        {
            selectedSceneId = sceneId;
        }
        [self->_dynamicTree unfoldScene:sceneId];
    }
    
    [self->_dynamicTree move2Scene:selectedSceneId];
}


- (void)loadAllListAndUnfold
{
    [SVProgressHUD showWithOwner:@"AddMapScenicViewController_List"];
    __weak __typeof(self)weakSelf = self;
    [Interface getMapCityList:^(MapCityResponse *response, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }
        
        [strongSelf->mapListArr addObjectsFromArray:response.mapList];
        
        strongSelf->_dynamicTree = [[BDDynamicTree alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(strongSelf.titleView.frame)+48, strongSelf.view.bounds.size.width, strongSelf.view.bounds.size.height - CGRectGetHeight(strongSelf.titleView.frame) - 100) nodes:[strongSelf generateData:strongSelf->mapListArr]];
        strongSelf->_dynamicTree.delegate = strongSelf;
        [strongSelf.view addSubview:strongSelf->_dynamicTree];
        
        [SVProgressHUD dismissFromOwner:@"AddMapScenicViewController_List"];
        
        
        [self performSelector:@selector(unfoldHandlingScene) withObject:nil afterDelay:0.0f];
    }];
}

- (NSArray *)generateData:(NSMutableArray *)dataListArr
{
    NSMutableArray *arr = [NSMutableArray array];
    
    for (int i=0; i<dataListArr.count; i++) {
        
        ProvinceData *provinceD = dataListArr[i];
        
        BDDynamicTreeNode *root = [[BDDynamicTreeNode alloc] init];
        root.originX      = 20.f;
        root.isDepartment = YES;
        root.fatherNodeId = nil;
        root.isOpen       = NO;
        root.nodeId       = [NSString stringWithFormat:@"node_%d",i];
        root.name         = provinceD.province;
        root.data         = @{@"mapSize":provinceD.provinceMapSize};
        root.sceneId      = nil;
        [arr addObject:root];
        
        for (int j=0; j<provinceD.cityListArr.count; j++) {
            CityData *cityD = provinceD.cityListArr[j];
            
            BDDynamicTreeNode *cityNode = [[BDDynamicTreeNode alloc] init];
            cityNode.isDepartment = YES;
            cityNode.fatherNodeId = [NSString stringWithFormat:@"node_%d",i];
            cityNode.nodeId       = [NSString stringWithFormat:@"citynode_%d%d",i,j];
            cityNode.name         = cityD.cityname;
            cityNode.data         = @{@"mapSize":cityD.cityMapSize,@"citySign":@"1"};
            cityNode.sceneId      = nil;
            cityNode.isOpen       = NO;

            [arr addObject:cityNode];
        
            for (int m = 0; m < cityD.sceneListArr.count; m++) {
                ScenicData *scenicD = cityD.sceneListArr[m];
                
                BDDynamicTreeNode *scenicNode = [[BDDynamicTreeNode alloc] init];
                scenicNode.isDepartment = YES;
                scenicNode.fatherNodeId = [NSString stringWithFormat:@"citynode_%d%d",i,j];
                scenicNode.sceneId      = scenicD.scenicID;
                scenicNode.nodeId       = scenicD.scenicID;
                scenicNode.name         = scenicD.scenicName;
                
                scenicNode.data =@{@"scenicID":scenicD.scenicID,@"canNavi":scenicD.canNav,@"scenicName":scenicD.scenicName,@"mapSize":scenicD.scenicMapSize,@"smallImage":scenicD.scenicImage};

                [arr addObject:scenicNode];
            }
        }
    }
    
    return arr;
    
}


- (void)reloadData
{
    [_dynamicTree removeFromSuperview];
    _dynamicTree = [[BDDynamicTree alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleView.frame)+48, self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetHeight(self.titleView.frame) - 100) nodes:[self generateData:mapListArr]];
    _dynamicTree.delegate = self;
    
    
    [self.view addSubview:_dynamicTree];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark search
- (void)loadSearchResult:(NSString *)searchString
{
    [SVProgressHUD showWithOwner:@"AddMapScenicViewController_Search"];

    NSString *nonSpacingText = [searchString stringByReplacingOccurrencesOfString:@" " withString:@""];

    if (nonSpacingText.length == 0)
    {
        [self reloadData];
    }
    else
    {
        [searchResultArr removeAllObjects];
        
        
        for (int i = 0; i < mapListArr.count; i ++)
        {
            ProvinceData *provinceData = mapListArr[i];
            if (provinceData && [provinceData.province rangeOfString:nonSpacingText options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                //[searchResultArr addObject:provinceData];
                //  flatten the whole province
                for (int j = 0; provinceData.cityListArr && j < provinceData.cityListArr.count; j ++)
                {
                    CityData *cityData = provinceData.cityListArr[j];
                    
                    for (int k = 0; cityData.sceneListArr && k < cityData.sceneListArr.count; k ++)
                    {
                        ScenicData *scenicData = cityData.sceneListArr[k];
                        
                        [searchResultArr addObject:scenicData];
                    }
                }
            }
            else
            {
                ProvinceData *newProvince = [[ProvinceData alloc]init];
                newProvince.province = [NSString stringWithString:provinceData.province];
                newProvince.provinceMapSize = [NSString stringWithString:provinceData.provinceMapSize];
                
                for (int j = 0; provinceData.cityListArr && j < provinceData.cityListArr.count; j ++)
                {
                    CityData *cityData = provinceData.cityListArr[j];
                    
                    CityData *newCityData = [[CityData alloc]init];
                    newCityData.cityname = [NSString stringWithString:cityData.cityname];
                    newCityData.cityMapSize = [NSString stringWithString:cityData.cityMapSize];
                    
                    if (cityData && [cityData.cityname rangeOfString:nonSpacingText options:NSCaseInsensitiveSearch].location != NSNotFound)
                    {
                        for (int k = 0; cityData.sceneListArr && k < cityData.sceneListArr.count; k ++)
                        {
                            ScenicData *scenicData = cityData.sceneListArr[k];
                            
                            [searchResultArr addObject:scenicData];
                        }
                    }
                    else
                    {
                        for (int k = 0; cityData.sceneListArr && k < cityData.sceneListArr.count; k ++)
                        {
                            ScenicData *scenicData = cityData.sceneListArr[k];
                            if (scenicData && [scenicData.scenicName rangeOfString:nonSpacingText options:NSCaseInsensitiveSearch].location != NSNotFound)
                            {
                                [searchResultArr addObject:scenicData];
                            }
                        }
                    }
                }
            }
        }
        
        
        [_dynamicTree removeFromSuperview];
        
        
        _dynamicTree = [[BDDynamicTree alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleView.frame)+48, self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetHeight(self.titleView.frame) - 100) nodes:[self generateDataFromFlattenedArray:searchResultArr]];
        _dynamicTree.delegate = self;
        [self.view addSubview:_dynamicTree];
        
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
    
    [SVProgressHUD dismissFromOwner:@"AddMapScenicViewController_Search"];
}


- (NSArray *)generateDataFromFlattenedArray:(NSMutableArray *)dataListArr
{
    NSMutableArray *arr = [NSMutableArray array];
    
    for (int i=0; i<dataListArr.count; i++) {
        
        ScenicData *scenicData = dataListArr[i];
        
        
        BDDynamicTreeNode *scenicNode = [[BDDynamicTreeNode alloc] init];
        scenicNode.originX      = 20.f;
        scenicNode.isDepartment = YES;
        scenicNode.fatherNodeId = nil;
        scenicNode.sceneId      = scenicData.scenicID;
        scenicNode.nodeId       = scenicData.scenicID;
        scenicNode.name         = scenicData.scenicName;
        
        scenicNode.data =@{@"scenicID":scenicData.scenicID,@"canNavi":scenicData.canNav,@"scenicName":scenicData.scenicName,@"mapSize":scenicData.scenicMapSize,@"smallImage":scenicData.scenicImage};
        
        [arr addObject:scenicNode];
    }
    
    return arr;
}



@end
