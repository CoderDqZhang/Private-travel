#import "CustomPickerView.h"
#define Btn_Bg_Color    [UIColor colorWithRed:20.0/255.0 green:154.0/255.0 blue:251.0/255.0 alpha:1]
@implementation CustomPickerView

+ (void)showPickerViewInView:(UIView *)baseView WithDataArr:(NSArray *)array AndSelectBlock:(void(^)(NSString *selectStr))selectBlock
{
    CustomPickerView *vv = [[CustomPickerView alloc] initWithFrame:baseView.bounds andDataArr:array];
    vv.SelectBlock       = selectBlock;
    [baseView addSubview:vv];
}


- (id)initWithFrame:(CGRect)frame andDataArr:(NSArray *)arr
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, App_Frame_Width, 260)];
        _bgView.backgroundColor     = Btn_Bg_Color;
        _bgView.layer.shadowColor   = [UIColor blackColor].CGColor;
        _bgView.layer.shadowOpacity = .3;
        _bgView.layer.shadowOffset  = CGSizeMake(0, -1);
        [self addSubview:_bgView];
        
        UILabel *titleL        = [[UILabel alloc] initWithFrame:CGRectMake((App_Frame_Width - 140)/2, 0, 140, 40)];
        titleL.backgroundColor = [UIColor clearColor];
        titleL.font            = [UIFont systemFontOfSize:17];
        titleL.textColor       = [UIColor whiteColor];
        if (arr.count == 0)
        {
            titleL.text = @"请选择日期";
        }
        else if (arr.count == 11)
        {
            titleL.text = @"请选择时间";
        }
        else
        {
            titleL.text = @"请选择城市";
        }
        
//        titleL.text = arr.count == 0? @"请选择日期" : @"请选择时间";
        [_bgView addSubview:titleL];
        
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmBtn.backgroundColor = [UIColor whiteColor];
        confirmBtn.frame = CGRectMake(App_Frame_Width - 65, 5, 50, 30);
        [confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
        [confirmBtn setTitleColor:Btn_Bg_Color forState:UIControlStateNormal];
        [confirmBtn addTarget:self action:@selector(confirmBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_bgView addSubview:confirmBtn];

        if (arr.count != 0)
        {
            _dataArr = [NSArray arrayWithArray:arr];
            _pickerView                 = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, App_Frame_Width, 216)];
            _pickerView.backgroundColor = [UIColor whiteColor];
            _pickerView.delegate        = self;
            _pickerView.dataSource      = self;
            [_bgView addSubview:_pickerView];

        }
        else
        {
            _datePicker                 = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, App_Frame_Width, 100)];
            _datePicker.backgroundColor = [UIColor whiteColor];
            _datePicker.datePickerMode  = UIDatePickerModeDate;
            
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setDay:1];
            [comps setMonth:1];
            [comps setYear:1990];
            NSCalendar *date1990 = [[NSCalendar alloc]
                                     initWithCalendarIdentifier:NSGregorianCalendar];
            _datePicker.date = [date1990 dateFromComponents:comps];
            
            _datePicker.maximumDate = [NSDate date];
            
            //_datePicker.minimumDate = [NSDate date];
            [_datePicker addTarget:self action:@selector(datePickerAction) forControlEvents:UIControlEventValueChanged];
            [_bgView addSubview:_datePicker];
        }
    }
    
    self.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeSelfAction)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    [self performSelector:@selector(showSelfAction) withObject:nil afterDelay:0];
    return self;
}

//确认按钮
- (void)confirmBtnAction
{
    if (_tempTime == nil || [_tempTime isEqualToString:@""])
    {
        if(_dataArr.count == 0)
        {
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSString *dateStr = [formatter stringFromDate:[NSDate date]];
            _tempTime = dateStr;
        }
        else
        {
            _tempTime = _dataArr[0];
        }
    }
    if (self.SelectBlock)
    {
        self.SelectBlock(_tempTime);
        [self removeSelfAction];
    }
}

- (void)showSelfAction
{
    __weak __typeof(self)weakSelf = self;
   [UIView animateWithDuration:0.2 animations:^{
       __strong __typeof(weakSelf)strongSelf = weakSelf;
       
       if (!strongSelf)
       {
           return;
       }
       strongSelf->_bgView.transform = CGAffineTransformMakeTranslation(0, -260);
   } completion:^(BOOL finished) {
       
   }];
}

- (void)removeSelfAction
{
    __weak __typeof(self)weakSelf = self;
   [UIView animateWithDuration:0.2 animations:^{
       __strong __typeof(weakSelf)strongSelf = weakSelf;
       
       if (!strongSelf)
       {
           return;
       }
       
       strongSelf->_bgView.transform  = CGAffineTransformIdentity;
       
   } completion:^(BOOL finished) {
       
       [self removeFromSuperview];
   }];
}

#pragma mark datepicker  方法
- (void)datePickerAction
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:_datePicker.date];
    _tempTime = dateStr;
}

#pragma mark  pickerview  delegate
//返回显示的列数
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
//返回当前列显示的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_dataArr count];
}


//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_dataArr objectAtIndex:row];
}

-(void) pickerView: (UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent: (NSInteger)component
{
    _tempTime = _dataArr[row];
}
-(CGFloat) pickerView:(UIPickerView *)pickerView rowHeightForComponent: (NSInteger) component
{
    return 40;
}

#pragma tap  delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (CGRectContainsPoint(_bgView.frame, point)) {
        return NO;
    }
    
    return YES;
}
@end



