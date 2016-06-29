#import <UIKit/UIKit.h>

@interface CustomPickerView : UIView<UIPickerViewDataSource,UIPickerViewDelegate,UIGestureRecognizerDelegate>
{
    UIPickerView * _pickerView;
    UIDatePicker * _datePicker;
    UIView       * _bgView;
    NSString     * _tempTime;
    
}

@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) void(^SelectBlock)(NSString *selectIndexStr);

- (id)initWithFrame:(CGRect)frame andDataArr:(NSArray *)arr;
+ (void)showPickerViewInView:(UIView *)baseView WithDataArr:(NSArray *)array AndSelectBlock:(void(^)(NSString *selectStr))selectBlock;

@end
