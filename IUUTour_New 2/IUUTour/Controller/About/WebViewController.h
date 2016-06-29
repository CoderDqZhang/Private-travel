#import "BaseViewController.h"

@interface WebViewController : BaseViewController<UIWebViewDelegate>
{
    UIWebView *_webview;
}

@property(nonatomic,strong)NSString *titles;
@property (nonatomic, copy)NSString *loadLocalHtmlPath;
@property (nonatomic,retain)NSURL   *url;

@end
