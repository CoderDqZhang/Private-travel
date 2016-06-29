#import "BaseViewController.h"
#import "ImageSpinner.h"


typedef enum {
    Waiting,
    Unzipping,
    Progressing,
    Others
} KDownStatus;


@interface DetailViewController : BaseViewController

@property(nonatomic,strong)ScenicArea         *data;
@property(nonatomic,strong)ScenicIntroduction *infoData;
@property(nonatomic,retain)ScenicTransport    *tranData;
@property(nonatomic,retain)ScenicTips         *tipsData;

@end
