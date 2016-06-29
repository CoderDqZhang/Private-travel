//
//  BDDynamicTreeCell.m
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

#import "BDDynamicTreeCell.h"

#define DepartmentCellHeight 44
#define EmployeeCellHeight  60

@interface BDDynamicTreeCell ()
@end

@implementation BDDynamicTreeCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.avatarImageView.layer.cornerRadius = 5.f;
    self.avatarImageView.layer.masksToBounds = YES;
}

+ (CGFloat)heightForCellWithType:(CellType)type
{
    if (type == CellType_Department) {
        return DepartmentCellHeight;
    }
    return EmployeeCellHeight;
}

- (IBAction)pauseBtnAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(pauseAction:withLbl:)]) {
        [_delegate pauseAction:self.node withLbl:self.pauseButton];
    }
}

- (IBAction)btnDownloadAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(downLoadAction:withLbl:)]) {
        [_delegate downLoadAction:self.node withLbl:self.btnDownLoad];
    }
}

- (void)fillWithNode:(BDDynamicTreeNode*)node
{
    if (node) {
        self.progress.hidden = YES;
        NSInteger cellType = node.isDepartment;
        self.node = node;
        [self setCellStypeWithType:cellType originX:node.originX];
        
        if (cellType == CellType_Department) {
            self.labelTitle.text = [NSString stringWithFormat:@"%@(%@个景点)",node.name,node.data[@"mapSize"]];
            self.labelTitle.font = [UIFont systemFontOfSize:14];
            
            NSRange range = [node.data[@"mapSize"] rangeOfString:@"M"];
            if (range.location != NSNotFound) {
                self.labelTitle.text = [NSString stringWithFormat:@"%@(%@)", node.name,node.data[@"mapSize"]];
                self.btnDownLoad.hidden = NO;
                [self.btnDownLoad setTitleColor:ButtonColorB forState:UIControlStateNormal];
                self.btnDownLoad.tag = [node.data[@"scenicId"] intValue];
                self.btnDownLoad.frame = CGRectMake(App_Frame_Width-70, 0, CGRectGetWidth(self.btnDownLoad.frame), CGRectGetHeight(self.btnDownLoad.frame));
                
                self.pauseButton.hidden = YES;
                [self.pauseButton setTitleColor:ButtonColorB forState:UIControlStateNormal];
                self.pauseButton.frame = CGRectMake(App_Frame_Width-70, 10, CGRectGetWidth(self.btnDownLoad.frame), CGRectGetHeight(self.pauseButton.frame));
                
                
                self.progress.hidden = YES;
                self.progress.frame = CGRectMake(App_Frame_Width-57, 10, CGRectGetWidth(self.btnDownLoad.frame) - 25, CGRectGetHeight(self.progress.frame));
            }
            if ([[node.data allKeys] containsObject:@"citySign"]) {
                self.btnOpenClose.hidden = NO;
                if (node.isOpen) {
                    self.btnOpenClose.image = [UIImage imageNamed:@"me_uparrow"];
                }else
                {
                    self.btnOpenClose.image = [UIImage imageNamed:@"me_downarrow"];
                    
                }
                self.btnOpenClose.frame = CGRectMake(App_Frame_Width-50, 15, CGRectGetWidth(self.btnOpenClose.frame), CGRectGetHeight(self.btnOpenClose.frame));
            }
        }
        else{
            NSDictionary *dic = node.data;
            
            NSRange range = [dic[@"mapSize"] rangeOfString:@"M"];
            if (range.location != NSNotFound) {
                self.labelTitle.text = [NSString stringWithFormat:@"%@(%@个景点)", dic[@"name"],dic[@"mapSize"]];
            }
            else
            {
                
                self.labelTitle.text = [NSString stringWithFormat:@"%@(%@)", dic[@"name"],dic[@"mapSize"]];
            }
            
            self.avatarImageView.image = [UIImage imageNamed:@"2.jpg"];
        }
    }
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString * path = [paths  objectAtIndex:0];
    NSString * filePath = [path stringByAppendingPathComponent:@"leaveMapData.plist"];
    NSMutableArray *jsonObject = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    for (int i = 0; i < jsonObject.count; i++) {
        if ([[[jsonObject objectAtIndex:i] objectForKey:@"scenicID"] intValue] == [node.data[@"scenicID"] intValue]) {
            [self.btnDownLoad removeTarget:self action:@selector(downLoadAction:withLbl:) forControlEvents:UIControlEventTouchUpInside];
            [self.btnDownLoad setTitle:@"已下载" forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)setCellStypeWithType:(NSInteger)type originX:(CGFloat)x
{
    if (type == CellType_Department) {
        self.contentView.frame = CGRectMake(self.contentView.frame.origin.x,
                                            self.contentView.frame.origin.y,
                                            self.contentView.frame.size.width, DepartmentCellHeight);
        
        self.avatarImageView.hidden = YES;
        
        //设置 + 号的位置
        self.plusImageView.frame = CGRectMake(x, self.plusImageView.frame.origin.y,
                                              self.plusImageView.frame.size.width,
                                              self.plusImageView.frame.size.height);
        
        //设置 label的位置
        self.labelTitle.frame = CGRectMake(self.plusImageView.frame.origin.x/*space*/, 0,
                                           self.contentView.frame.size.width - self.plusImageView.frame.origin.x - self.plusImageView.frame.size.width - 5 - 5/*space*/,
                                           self.contentView.frame.size.height);
        
        //underline
        self.underLine.frame = CGRectMake(x,
                                          self.contentView.frame.size.height - 0.5,
                                          self.contentView.frame.size.width - x,
                                          0.5);
        self.underLine.backgroundColor = [UIColor colorWithRed:242/255.f green:244/255.f blue:246/255.f alpha:1];
        
    }
    else{
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        self.contentView.frame = CGRectMake(self.contentView.frame.origin.x,
                                            self.contentView.frame.origin.y,
                                            self.contentView.frame.size.width, EmployeeCellHeight);
        
        self.plusImageView.hidden = YES;
        
        //设置头像的位置
        CGFloat iconWidth = EmployeeCellHeight - 10;
        self.avatarImageView.frame = CGRectMake(x, EmployeeCellHeight/2.f - iconWidth/2.f, iconWidth, iconWidth);
        
        //这是label
        self.labelTitle.frame = CGRectMake(self.avatarImageView.frame.origin.x+self.avatarImageView.frame.size.width + 5/*space*/,
                                           0,
                                           self.contentView.frame.size.width - self.avatarImageView.frame.origin.x - self.avatarImageView.frame.size.width - 5 - 5/*space*/,
                                           self.contentView.frame.size.height);
        
        //underline
        self.underLine.frame = CGRectMake(x,
                                          self.contentView.frame.size.height - 0.5,
                                          self.contentView.frame.size.width - x,
                                          0.5);
        self.underLine.backgroundColor = [UIColor colorWithRed:242/255.f green:244/255.f blue:246/255.f alpha:1];
    }
}

@end
