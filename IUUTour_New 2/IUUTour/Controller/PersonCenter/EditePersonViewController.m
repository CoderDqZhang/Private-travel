#import "EditePersonViewController.h"
#import "CustomPickerView.h"

@interface EditePersonViewController ()<UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate>
{
    UIImageView * headImage;
}
@property (nonatomic,strong) NSMutableArray * sexBtnArray;
@property (nonatomic,strong) NSString  * sexSelected;

@end

@implementation EditePersonViewController

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.titleView.hidden = NO;
    self.titleLabel.text  = @"编辑基本信息";
    [self initWithBackBtn];
    
    User *user = [User sharedInstance];


    self.sexBtnArray   = [[NSMutableArray alloc]init];

    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(self.titleView.width - 55, 10, 50.0f, 30.0f)];
    [rightBtn setTitle:@"保存" forState:(UIControlStateNormal)];
    [rightBtn setBackgroundColor:[UIColor colorWithRed:20/255. green:140/255. blue:203/255. alpha:1]];
    [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    rightBtn.layer.cornerRadius = 5.0f;
    rightBtn.clipsToBounds      = YES;
    [rightBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:rightBtn];
    
    headImage = [[UIImageView alloc]initWithFrame:CGRectMake(App_Frame_Width/2 - 50, self.titleView.bottom + 50, 100, 100)];

    
    if (![User sharedInstance].userid)
    {
        [headImage setImage:[UIImage imageNamed:@"me_Icon"]];
    }
    else
    {
        [headImage setShowActivityIndicatorView:YES];
        [headImage setIndicatorStyle:UIActivityIndicatorViewStyleGray];
        NSString *headUrl = [Interface getHeadImgUrl];
        [headImage sd_setImageWithURL:[NSURL URLWithString:headUrl] placeholderImage:[UIImage imageNamed:@"me_Icon"] options:SDWebImageProgressiveDownload | SDWebImageRetryFailed];
    }
    
    
    [headImage.layer setCornerRadius:headImage.height/2];
    [headImage.layer setMasksToBounds:YES];
    [_defaultView addSubview:headImage];
    
    
    //拍照按钮
    UIButton * photoBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [photoBtn setFrame:CGRectMake(headImage.right - 25, headImage.bottom - 25, 20, 20)];
    [photoBtn setImage:[UIImage imageNamed:@"sign_photoNor"] forState:UIControlStateNormal];
    [photoBtn addTarget:self action:@selector(photoAction) forControlEvents:(UIControlEventTouchUpInside)];
    [_defaultView addSubview:photoBtn];

    NSArray * titleArray = [[NSArray alloc]initWithObjects:@"用户名",@"生日",@"居住地", nil];
    NSArray * txtArray   = [[NSArray alloc]initWithObjects:@"请输入您的用户名",@"请选择出生日期",@"如山东青岛", nil];
    

    for (int i = 0; i < 3; i++)
    {
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(10, (headImage.bottom + 50) + i*40 , App_Frame_Width - 10, 40)];
        view.backgroundColor = [UIColor clearColor];
        [_defaultView addSubview:view];
        
        CALayer * layer = [CALayer layer];
        layer.frame = CGRectMake(0, view.height-1, view.width, 1);
        layer.backgroundColor = [UIColor grayColor].CGColor;
        [view.layer addSublayer:layer];
        
        
        UILabel * titlelbl       = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 39)];
        titlelbl.font            = [UIFont systemFontOfSize:14];
        titlelbl.textAlignment   = NSTextAlignmentLeft;
        titlelbl.backgroundColor = [UIColor clearColor];
        titlelbl.textColor       = [UIColor blackColor];
        titlelbl.text            = [titleArray objectAtIndex:i];
        [view addSubview:titlelbl];
        
        
        UITextField * txt = [[UITextField alloc]initWithFrame:CGRectMake(titlelbl.right + 10 , 0, view.width - titlelbl.right -10 - 100, 39)];
        txt.delegate    = self;
        txt.tag         = 100+i;
        txt.borderStyle = UITextBorderStyleNone;
        txt.placeholder = txtArray[i];
        if ([User sharedInstance].loginName.length>0 && i == 0 )
        {
            txt.text = [User sharedInstance].loginName;
            txt.returnKeyType = UIReturnKeyDone;
        }
        if ([User sharedInstance].address.length>0 && i == 2)
        {
            txt.text = [User sharedInstance].address;
            txt.returnKeyType = UIReturnKeyDone;
        }
        if (user.birthday.length > 0 && i == 1)
        {
            txt.text = user.birthday;
        }
        txt.backgroundColor = [UIColor clearColor];

        [view addSubview:txt];
        
        if (i == 0)
        {
            self.sexBtnArray = [[NSMutableArray alloc] init];
            
            NSArray * sexArray = [[NSArray alloc]initWithObjects:@"男",@"女", nil];
            for (int j = 2; j > 0; j--)
            {
                UIButton * button = [UIButton buttonWithType:(UIButtonTypeCustom)];
                button.tag = j;
                [button setFrame:CGRectMake(view.width - 10 - j*30 , 10, 30, 20)];
                [button setBackgroundColor:[UIColor clearColor]];
                [button setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
                [button setTitle:sexArray[j-1] forState:(UIControlStateNormal)];
                [button.layer setBorderColor:ButtonColorC.CGColor];
                [button.layer setBorderWidth:0.5];
                [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
                [button addTarget:self action:@selector(sexAction:) forControlEvents:(UIControlEventTouchUpInside)];
                [view addSubview:button];
                
                
                [self.sexBtnArray addObject:button];
                
 
                if ([user.sex isEqualToString:@"1"] && j == 1)
                {
                    button.selected = YES;
                    [button setBackgroundColor:ButtonColorC];
                    [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
                }
                else if ([user.sex isEqualToString:@"0"] && j == 2)
                {
                    button.selected = YES;
                    [button setBackgroundColor:ButtonColorC];
                    [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
                }
            }
        }
    }
    
    
    if ([user.sex isEqualToString:@"1"])
    {
        self.sexSelected = @"1";
    }
    else
    {
        self.sexSelected = @"0";
    }
    
}

-(void)photoAction
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
    [sheet showInView:self.view];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag == 101) {
        [CustomPickerView showPickerViewInView:self.view WithDataArr:nil AndSelectBlock:^(NSString *selectStr) {
            textField.text = selectStr;
        }];
        return NO;
    }
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 ||buttonIndex == 1 )
    {
        //先设定sourceType为相机，然后判断相机是否可用（ipod）没相机，不可用将sourceType设定为相片库
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if (buttonIndex == 1) {
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        else
        {
            sourceType = UIImagePickerControllerSourceTypeCamera; //照相机
        }
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
        picker.delegate      = self;
        picker.allowsEditing = YES;//设置可编辑
        picker.sourceType    = sourceType;
        [self presentViewController:picker animated:YES completion:^{
        }];//进入照相界面
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image  = [info valueForKey:UIImagePickerControllerEditedImage];
    headImage.image = image;


    NSString *key = [NSString stringWithFormat:@"userId=%@&path=head",[User sharedInstance].userid];
    [Interface serialize:UIImageJPEGRepresentation(image, .1) to:key];
    

    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - button action 
- (void)doneAction
{
    [SVProgressHUD showWithOwner:@"EditPersonViewController"];
    

    NSString *key    = [NSString stringWithFormat:@"userId=%@&path=head",[User sharedInstance].userid];
    NSData *headData = [Interface deserializeFrom:key];


    if (headData)
    {
        __weak __typeof(self)weakSelf = self;
        [Interface updateHeadImg:headData result:^(CommonActionStatus *response, NSError *error)
         {
             __strong __typeof(weakSelf)strongSelf = weakSelf;
             
             if (!strongSelf)
             {
                 return;
             }
             
             if (!response || response.status != 0)
             {
                 [SVProgressHUD dismissFromOwner:@"EditPersonViewController"];
         
                 [UWindowHud hudWithType:kToastType withContentString:@"上传头像失败，请重试！"];
                 
                 return;
             }
             
             [strongSelf uploadSimpleData];

         }];
    }
    else
    {
        [self uploadSimpleData];
    }
}


- (void)uploadSimpleData
{
    UITextField *nameTf    = (UITextField *)[self.view viewWithTag:100];
    UITextField *birthTf   = (UITextField *)[self.view viewWithTag:101];
    UITextField *addressTf = (UITextField *)[self.view viewWithTag:102];
    
    __weak __typeof(self)weakSelf = self;
    [Interface updateInfoAction:[User sharedInstance].userid loginName:nameTf.text birth:birthTf.text.length == 0? @"" : birthTf.text address:addressTf.text sex:self.sexSelected result:^(CommonActionStatus *response, NSError *error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!strongSelf)
        {
            return;
        }
        
        [SVProgressHUD dismissFromOwner:@"EditPersonViewController"];
        if (response.status == 0)
        {
            User *uu = [User sharedInstance];
            uu.sex = strongSelf.sexSelected;
            if (birthTf.text.length != 0)
            {
                uu.birthday = birthTf.text;
            }
            
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
            
            NSInteger currentYear = [components year];
            
            NSArray *birthArray = [uu.birthday componentsSeparatedByString:@"-"];
            if (birthArray.count > 0)
            {
                uu.age = [NSString stringWithFormat:@"%d", (int)currentYear - [birthArray[0] intValue]];
            }

            
            uu.address = addressTf.text;
            
            [User synchronize];
            
            [UWindowHud hudWithType:kToastType withContentString:@"保存成功，返回个人中心！"];
            
            
            [strongSelf.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [UWindowHud hudWithType:kToastType withContentString:@"资料保存失败，请重试！"];
            
            return;
        }
        
    }];
}

- (void)sexAction:(UIButton *)sender
{
    for (UIButton * button in self.sexBtnArray)
    {
        button.selected = NO;
        [button setBackgroundColor:[UIColor clearColor]];
        [button setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    }
    
    if (sender.tag == 1)
    {
       self.sexSelected = @"1";
    }
    else
    {
       self.sexSelected = @"0";
    }
    sender.selected = YES;
    [sender setBackgroundColor:ButtonColorC];
    [sender setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
