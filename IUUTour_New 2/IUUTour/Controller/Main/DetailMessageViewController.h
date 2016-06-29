#import "BaseViewController.h"

@interface DetailMessageViewController : BaseViewController
{
    UIView     * bgView;
    UITextView * _textView;
    BOOL       isShouldRefesh;
    float      y;
}
@property(nonatomic,retain)ScenicArea * data;

@end
