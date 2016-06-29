#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleView.hidden = NO;
    [self initWithBackBtn];
    self.titleLabel.text  = self.titles;
    
    _webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleView.frame), App_Frame_Width, CGRectGetHeight(_defaultView.frame) - CGRectGetMaxY(self.titleView.frame))];
    _webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webview.backgroundColor  = [UIColor whiteColor];
    [_defaultView addSubview:_webview];
    _webview.delegate = self;
    
    if (self.loadLocalHtmlPath != nil)
    {
        NSURL *url = [NSURL fileURLWithPath:self.loadLocalHtmlPath];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_webview loadRequest:request];
    }
    else
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
        [_webview loadRequest:request];
    }

}



-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
