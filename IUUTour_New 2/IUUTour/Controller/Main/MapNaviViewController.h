#import "BaseViewController.h"

#import <AMapNaviKit/MAMapKit.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import <AVFoundation/AVFoundation.h>
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySetting.h"

@interface MapNaviViewController : BaseViewController

@property (nonatomic,retain ) ScenicArea            * data;
@property (nonatomic, strong) IFlySpeechSynthesizer *iFlySpeechSynthesizer;
@property (nonatomic, strong) AMapNaviManager       *naviManager;
@property (nonatomic, strong) MAPolyline            *polyline;
@property (nonatomic        ) BOOL                  calRouteSuccess;// 指示是否算路成功

@end
