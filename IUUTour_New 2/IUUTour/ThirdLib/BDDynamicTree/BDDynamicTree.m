//
//  BDDynamicTree.m
//
//  Created by Scott Ban (https://github.com/reference) on 14/07/30.
//  Copyright (C) 2011-2020 by Scott Ban

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "BDDynamicTree.h"
#import "BDDynamicTreeNode.h"
#import "BDDynamicTreeCell.h"
#import "OfflineMapDownloader.h"
#import "DownResource.h"
#import "AFNetworking.h"

@interface BDDynamicTree () <UITableViewDataSource,UITableViewDelegate>
{
    UITableView    *_tableView;
    NSMutableArray *_dataSource;
    NSMutableArray *_nodesArray;
    
}

@property(atomic, strong)NSMutableArray *handlingArray;
@property(atomic, strong)NSMutableArray *doneArray;
@property(atomic, strong)NSMutableArray *unzippingArray;
@property(atomic, strong)NSMutableArray *failureArray;
@property(atomic, strong)NSMutableArray *progressArray;

@end


@implementation BDDynamicTree


- (id)initWithFrame:(CGRect)frame nodes:(NSArray *)nodes
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.handlingArray  = [[NSMutableArray alloc] init];
        self.doneArray      = [[NSMutableArray alloc] init];
        self.unzippingArray = [[NSMutableArray alloc] init];
        self.failureArray   = [[NSMutableArray alloc] init];
        self.progressArray  = [[NSMutableArray alloc] init];
        
        _dataSource   = [[NSMutableArray alloc] init];
        _nodesArray   = [[NSMutableArray alloc] init];

        
        if (nodes && nodes.count) {
            [_nodesArray addObjectsFromArray:nodes];
            
            //添加根节点
            [_dataSource addObjectsFromArray:[self rootNode]];
        }
        
        //tableview
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)
                                                  style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_tableView];
        
        [self observeDownloadProgress];
    }
    return self;
}

- (void)move2Scene:(NSString*)sceneId
{
    NSInteger dataSourceIndex = [_dataSource indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BDDynamicTreeNode *node = (BDDynamicTreeNode *)obj;
        
        if ([node.sceneId isEqualToString:sceneId])
        {
            return YES;
        }
        else
        {
            return NO;
        }
        
    }];
    if (dataSourceIndex != NSNotFound)
    {
        [self->_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dataSourceIndex inSection:0]
                         atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (void)unfoldScene:(NSString*)sceneId
{
    //  Find node info
    NSInteger nodeArrindex = [_nodesArray indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BDDynamicTreeNode *node = (BDDynamicTreeNode *)obj;
        
        if (!node.data || node.data.count < 1)
        {
            return NO;
        }
        
        if ([node.data valueForKey:@"scenicID"] && [[node.data valueForKey:@"scenicID"] isEqualToString:sceneId])
        {
            return YES;
        }
        else
        {
            return NO;
        }

    }];
    if (nodeArrindex == NSNotFound)
    {
        return;
    }
    BDDynamicTreeNode *node = [_nodesArray objectAtIndex:nodeArrindex];
   

    NSString *fatherNodeId = node.fatherNodeId;
    NSInteger nodeArrindex2 = [_nodesArray indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BDDynamicTreeNode *node = (BDDynamicTreeNode *)obj;
        
        if ([node.nodeId isEqualToString:fatherNodeId])
        {
            return YES;
        }
        else
        {
            return NO;
        }
        
    }];
    if (nodeArrindex2 == NSNotFound)
    {
        return;
    }
    BDDynamicTreeNode *parentNode = [_nodesArray objectAtIndex:nodeArrindex2];
    

    NSString *grandFatherNodeId = parentNode.fatherNodeId;
    NSInteger nodeArrindex3 = [_nodesArray indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BDDynamicTreeNode *node = (BDDynamicTreeNode *)obj;
        
        if ([node.nodeId isEqualToString:grandFatherNodeId])
        {
            return YES;
        }
        else
        {
            return NO;
        }
        
    }];
    

    if (nodeArrindex3 != NSNotFound)
    {
        BDDynamicTreeNode *grandParentNode = [_nodesArray objectAtIndex:nodeArrindex3];
        if (!grandParentNode.isOpen)
        {
            NSInteger dataSourceIndex = [_dataSource indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BDDynamicTreeNode *node = (BDDynamicTreeNode *)obj;
                
                if ([node.nodeId isEqualToString:grandFatherNodeId])
                {
                    return YES;
                }
                else
                {
                    return NO;
                }
                
            }];
            if (dataSourceIndex != NSNotFound)
            {
                [self addSubNodesByFatherNode:grandParentNode atIndex:dataSourceIndex];
            }
        }
    }
    

    NSInteger dataSourceIndex2 = [_dataSource indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BDDynamicTreeNode *node = (BDDynamicTreeNode *)obj;
        
        if ([node.nodeId isEqualToString:fatherNodeId])
        {
            return YES;
        }
        else
        {
            return NO;
        }
        
    }];
    if (dataSourceIndex2 != NSNotFound)
    {
        if (!parentNode.isOpen)
        {
            [self addSubNodesByFatherNode:parentNode atIndex:dataSourceIndex2];
        }
    }
}


- (void)observeDownloadProgress
{
    OfflineMapDownloader *downloader = [OfflineMapDownloader sharedInstance];
    
    @weakify(self);
    RACSignal *handlingSignal = RACObserve(downloader, handlingArray);
    [handlingSignal subscribeNext:^(NSMutableArray *handlingScenes) {
        @strongify(self);
        
        [self.handlingArray removeAllObjects];
        [self.handlingArray addObjectsFromArray:handlingScenes];
        
        for (NSDictionary *dic in handlingScenes)
        {
            NSString* scendId = [dic.allKeys objectAtIndex:0];
            NSArray *cells = self->_tableView.visibleCells;
            for (BDDynamicTreeCell *cell in cells)
            {
                if ([cell.node.sceneId isEqualToString:scendId])
                {
                    UIButton *button = (UIButton*)cell.btnDownLoad;
                    button.userInteractionEnabled = NO;
                    button.hidden = NO;
                    
                    cell.progress.hidden = YES;
                    cell.pauseButton.hidden = YES;
                    
                    [button setTitle:@"请稍后！" forState:UIControlStateNormal];
                }
            }
        }
    }];
    
    
    
    RACSignal *doneSignal = RACObserve(downloader, doneArray);
    [doneSignal subscribeNext:^(NSMutableArray *doneScenes) {
        @strongify(self);
        
        [self.doneArray removeAllObjects];
        [self.doneArray addObjectsFromArray:doneScenes];
        
        for (NSString* scendId in doneScenes)
        {
            NSArray *cells = self->_tableView.visibleCells;
            for (BDDynamicTreeCell *cell in cells)
            {
                if ([cell.node.sceneId isEqualToString:scendId])
                {
                    UIButton *button = (UIButton*)cell.btnDownLoad;
                    button.userInteractionEnabled = NO;
                    button.hidden = NO;
                    
                    cell.progress.hidden = YES;
                    cell.pauseButton.hidden = YES;
                    
                    [button setTitle:@"已下载" forState:UIControlStateNormal];
                }
            }
        }
    }];
    
    
    
    RACSignal *unzippingSignal = RACObserve(downloader, unzippingArray);
    [unzippingSignal subscribeNext:^(NSMutableArray *unzippingScenes) {
        @strongify(self);
        
        [self.unzippingArray removeAllObjects];
        [self.unzippingArray addObjectsFromArray:unzippingScenes];
        
        for (NSString* scendId in unzippingScenes)
        {
            NSArray *cells = self->_tableView.visibleCells;
            for (BDDynamicTreeCell *cell in cells)
            {
                if ([cell.node.sceneId isEqualToString:scendId])
                {
                    UIButton *button = (UIButton*)cell.btnDownLoad;
                    button.userInteractionEnabled = NO;
                    button.hidden = NO;
                    
                    cell.progress.hidden = YES;
                    cell.pauseButton.hidden = YES;
                    
                    [button setTitle:@"正在解压" forState:UIControlStateNormal];
                }
            }
        }
    }];
    
    RACSignal *failureSignal = RACObserve(downloader, failureArray);
    [failureSignal subscribeNext:^(NSMutableArray *failureScenes) {
        @strongify(self);
        
        [self.failureArray removeAllObjects];
        [self.failureArray addObjectsFromArray:failureScenes];
        
        for (NSString* scendId in failureScenes)
        {
            NSArray *cells = self->_tableView.visibleCells;
            for (BDDynamicTreeCell *cell in cells)
            {
                if ([cell.node.sceneId isEqualToString:scendId])
                {
                    if (!cell.pauseButton.hidden && [cell.pauseButton.titleLabel.text isEqualToString:@"继续下载"])
                    {
                        
                    }
                    else
                    {
                        UIButton *button = (UIButton*)cell.btnDownLoad;
                        button.userInteractionEnabled = YES;
                        button.hidden = NO;
                        
                        cell.progress.hidden = YES;
                        cell.pauseButton.hidden = YES;
                        [button setTitle:@"下载" forState:UIControlStateNormal];
                    }
                }
            }
        }
    }];
    
    
    RACSignal *progressSignal = RACObserve(downloader, progressArray);
    [progressSignal subscribeNext:^(NSMutableArray *progress4Scenes) {
        @strongify(self);
        
        [self.progressArray removeAllObjects];
        [self.progressArray addObjectsFromArray:progress4Scenes];
        
        for (NSDictionary *dic in progress4Scenes)
        {
            NSString *scendIdKey = [dic.allKeys objectAtIndex:0];
            if (!scendIdKey)
            {
                continue;
            }
            
            NSArray *cells = self->_tableView.visibleCells;
            for (BDDynamicTreeCell *cell in cells)
            {
                if ([cell.node.sceneId isEqualToString:scendIdKey])
                {
                    UIButton *button = (UIButton*)cell.btnDownLoad;
                    button.userInteractionEnabled = NO;
                    
                    NSString *percentage = [dic valueForKey:scendIdKey];
                    if ([percentage intValue] > 99)
                    {
                        NSString *title = [NSString stringWithFormat:@"%@", @"正在解压"];
                        [button setTitle:title forState:UIControlStateNormal];
                        button.hidden = NO;
                        
                        cell.progress.hidden = YES;
                        cell.pauseButton.hidden = YES;
                    }
                    else
                    {
//                        NSString *title = [NSString stringWithFormat:@"%@%%", [dic valueForKey:scendIdKey]];
//                        [button setTitle:title forState:UIControlStateNormal];
                        button.hidden = YES;
                        
                        cell.progress.hidden = NO;
                        NSString *progress = [dic valueForKey:scendIdKey];
                        [cell.progress setProgress:[progress floatValue] / 100.0f];
                        cell.pauseButton.hidden = NO;
                    }
                }
            }
        }
    }];
}


#pragma mark - private methods

- (NSArray *)rootNode
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (BDDynamicTreeNode *node in _nodesArray) {
        if ([node isRoot]) {
            [arr addObject:node];
        }
    }
    return arr;
}

//添加子节点
- (void)addSubNodesByFatherNode:(BDDynamicTreeNode *)fatherNode atIndex:(NSInteger )index
{
    if (fatherNode)
    {
        NSMutableArray *array = [NSMutableArray array];
        NSMutableArray *cellIndexPaths = [NSMutableArray array];
        
        NSUInteger count = index;
        for(BDDynamicTreeNode *node in _nodesArray) {
            if ([node.fatherNodeId isEqualToString:fatherNode.nodeId]) {
                node.originX = fatherNode.originX + 10/*space*/;
                [array addObject:node];
                [cellIndexPaths addObject:[NSIndexPath indexPathForRow:count++ inSection:0]];
            }
        }
        
        if (array.count) {
            fatherNode.isOpen = YES;
            fatherNode.subNodes = array;
            
            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index,[array count])];
            [_dataSource insertObjects:array atIndexes:indexes];
            [_tableView insertRowsAtIndexPaths:cellIndexPaths withRowAnimation:UITableViewRowAnimationFade];
            [_tableView reloadData];
        }
    }
}

//根据节点减去子节点
- (void)minusNodesByNode:(BDDynamicTreeNode *)node
{
    if (node) {
        
        NSMutableArray *nodes = [NSMutableArray arrayWithArray:_dataSource];
        for (BDDynamicTreeNode *nd in nodes) {
            if ([nd.fatherNodeId isEqualToString:node.nodeId]) {
                [_dataSource removeObject:nd];
                [self minusNodesByNode:nd];
            }
        }
        
        node.isOpen = NO;
        [_tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BDDynamicTreeNode *node = _dataSource[indexPath.row];
    CellType type = node.isDepartment?CellType_Department:CellType_Employee;
    return [BDDynamicTreeCell heightForCellWithType:type];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    BDDynamicTreeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   
    if (cell == nil) {
        NSArray* topObjects = [[NSBundle mainBundle] loadNibNamed:@"BDDynamicTreeCell" owner:self options:nil];
        cell = [topObjects objectAtIndex:0];
         cell.delegate = self;
    }
    
    [cell fillWithNode:_dataSource[indexPath.row]];
    
    for (NSDictionary *dic in self.handlingArray)
    {
        NSString *sceneId = [dic.allKeys objectAtIndex:0];
        if (sceneId && [sceneId isEqualToString:cell.node.sceneId])
        {
            cell.btnDownLoad.userInteractionEnabled = NO;
            [cell.btnDownLoad setTitle:@"请稍后！" forState:UIControlStateNormal];
        }
    }
    for (NSString *sceneId in self.doneArray)
    {
        if (sceneId && [sceneId isEqualToString:cell.node.sceneId])
        {
            cell.btnDownLoad.userInteractionEnabled = NO;
            [cell.btnDownLoad setTitle:@"已下载" forState:UIControlStateNormal];
        }
    }
    for (NSString *sceneId in self.unzippingArray)
    {
        if (sceneId && [sceneId isEqualToString:cell.node.sceneId])
        {
            cell.btnDownLoad.userInteractionEnabled = NO;
            [cell.btnDownLoad setTitle:@"正在解压" forState:UIControlStateNormal];
        }
    }
    for (NSString *sceneId in self.failureArray)
    {
        if (sceneId && [sceneId isEqualToString:cell.node.sceneId])
        {
            cell.btnDownLoad.userInteractionEnabled = YES;
            [cell.btnDownLoad setTitle:@"下载" forState:UIControlStateNormal];
        }
    }
    for (NSDictionary *dic in self.progressArray)
    {
        NSString *sceneId = [dic.allKeys objectAtIndex:0];
        if (sceneId && [sceneId isEqualToString:cell.node.sceneId])
        {
            cell.btnDownLoad.userInteractionEnabled = YES;
            
            NSString *percentage = [dic valueForKey:sceneId];
            if ([percentage intValue] > 99)
            {
                NSString *title = [NSString stringWithFormat:@"%@", @"正在解压"];
                [cell.btnDownLoad setTitle:title forState:UIControlStateNormal];
                cell.btnDownLoad.userInteractionEnabled =  NO;
            }
            else
            {
                NSString *title = [NSString stringWithFormat:@"%@%%", [dic valueForKey:sceneId]];
                [cell.btnDownLoad setTitle:title forState:UIControlStateNormal];
            }
        }
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    BDDynamicTreeNode *node = _dataSource[indexPath.row];
    
    BDDynamicTreeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    
    [self tableCell:cell didSelectedRowWithNode:node];
    
    if (node.isDepartment) {
        if (node.isOpen) {
            //减
            [self minusNodesByNode:node];
        }
        else{
            //加一个
            NSUInteger index=indexPath.row+1;
            
            [self addSubNodesByFatherNode:node atIndex:index];
        }
    }
}


- (void)tableCell:(BDDynamicTreeCell*)cell didSelectedRowWithNode:(BDDynamicTreeNode*)node
{
    if (!node.sceneId || !cell.btnDownLoad)
    {
        return;
    }
    
    NSString *title = cell.btnDownLoad.titleLabel.text;
    if ([title rangeOfString:@"请稍后" options:NSCaseInsensitiveSearch].location != NSNotFound ||
        [title rangeOfString:@"%" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确认要取消下载吗？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        

        [[alert rac_buttonClickedSignal] subscribeNext:^(id x) {
            if ([x integerValue] == 1)
            {
                cell.pauseButton.hidden = YES;
                cell.progress.hidden = YES;
                cell.btnDownLoad.hidden = NO;
                [cell.btnDownLoad setTitle:@"下载" forState:UIControlStateNormal];
                cell.btnDownLoad.userInteractionEnabled = YES;
                [[OfflineMapDownloader sharedInstance]cancelDownloadOfScene:node.sceneId clearCache:YES];
            }
        }];
        
        
        [alert show];
    }
}

- (void)pauseAction:(BDDynamicTreeNode *)node  withLbl:(UIButton *)button
{
    if ([button.titleLabel.text isEqualToString:@"暂停下载"])
    {
        [button setTitle:@"继续下载" forState:UIControlStateNormal];
        button.userInteractionEnabled = NO;
        [[OfflineMapDownloader sharedInstance]cancelDownloadOfScene:node.sceneId clearCache:NO];
        [self performSelector:@selector(enableButton:) withObject:button afterDelay:0.5f];
    }
    else
    {
        [button setTitle:@"暂停下载" forState:UIControlStateNormal];
        button.userInteractionEnabled = NO;
        NSString *scenicId = node.nodeId;
        NSString *urlStr;
        NSString *scenic;
        
        if ([node.data[@"canNavi"] intValue] == 1) {
            urlStr = [NSString stringWithFormat:@"http://map.imyuu.com:9100/map/%@.zip", scenicId];
            scenic = @"";
        }
        else
        {
            urlStr = [NSString stringWithFormat:@"http://www.imyuu.com/trip/oneScenicScenicAreaAction.action?scenicId=%@", scenicId];
            scenic = @"scenic";
        }
        
        FileTools *fileTools = [FileTools defaultTools];
        NSString *zipFilePath = [fileTools GetFullFilePathInDocuments:[NSString stringWithFormat:@"%@%@.zip",scenic, scenicId]];
        
        NSString *targetPath = [fileTools GetFullFilePathInDocuments:[NSString stringWithFormat:@"%@%@", scenic,scenicId]];
        
        [fileTools deleteDir:zipFilePath];
        
        [[OfflineMapDownloader sharedInstance]downloadFrom:urlStr to:targetPath withTempPath:zipFilePath forScene:scenicId withSceneData:node.data];
        [self performSelector:@selector(enableButton:) withObject:button afterDelay:0.5f];
    }
}

- (void)enableButton:(UIButton*)button
{
    button.userInteractionEnabled = YES;
}

- (void)downLoadAction:(BDDynamicTreeNode *)node  withLbl:(UIButton *)lblText
{
    UIAlertView * alert = nil;
    
    AFNetworkReachabilityManager *reachabilityMgr = [AFNetworkReachabilityManager sharedManager];
    if (reachabilityMgr.networkReachabilityStatus != AFNetworkReachabilityStatusReachableViaWiFi)
    {
        alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您未接入WiFi，确定开始下载？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
    else
    {
        alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"即将下载景区地图，确定开始下载？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
    
    [[alert rac_buttonClickedSignal] subscribeNext:^(id x) {
        if ([x integerValue] == 1)
        {
            NSString *scenicId = node.nodeId;
            NSString *urlStr;
            NSString *scenic;
            
            if ([node.data[@"canNavi"] intValue] == 1) {
                urlStr = [NSString stringWithFormat:@"http://map.imyuu.com:9100/map/%@.zip", scenicId];
                scenic = @"";
            }
            else
            {
                urlStr = [NSString stringWithFormat:@"http://www.imyuu.com/trip/oneScenicScenicAreaAction.action?scenicId=%@", scenicId];
                scenic = @"scenic";
            }
            
            FileTools *fileTools = [FileTools defaultTools];
            NSString *zipFilePath = [fileTools GetFullFilePathInDocuments:[NSString stringWithFormat:@"%@%@.zip",scenic, scenicId]];
            
            NSString *targetPath = [fileTools GetFullFilePathInDocuments:[NSString stringWithFormat:@"%@%@", scenic,scenicId]];
            
            [fileTools deleteDir:zipFilePath];
            
            [[OfflineMapDownloader sharedInstance]downloadFrom:urlStr to:targetPath withTempPath:zipFilePath forScene:scenicId withSceneData:node.data];
        }
    }];
    
    [alert show];
}


@end
