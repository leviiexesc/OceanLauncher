#import <WebKit/WebKit.h>
#import "LauncherMenuViewController.h"
#import "LauncherNewsViewController.h"
#import "LauncherPreferences.h"
#import "utils.h"

@interface LauncherNewsViewController()<WKNavigationDelegate>
@end

@implementation LauncherNewsViewController
WKWebView *webView;
UIEdgeInsets insets;

- (id)init {
    self = [super init];
    self.title = localize(@"News", nil);
    return self;
}

- (NSString *)imageName {
    return @"MenuNews";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIBarButtonItem *feedback = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"square.and.pencil"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(showFeedbackForm)];
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                target:self
                                                                                action:@selector(refreshNews)];
    self.navigationItem.rightBarButtonItems = @[[sidebarViewController drawAccountButton], feedback, refresh];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGSize size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    insets = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://wiki.angelauramc.dev/patchnotes/changelogs/IOS.html"]];

    WKWebViewConfiguration *webConfig = [[WKWebViewConfiguration alloc] init];
    webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:webConfig];
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    webView.navigationDelegate = self;
    webView.opaque = NO;
    [self adjustWebViewForSize:size];
    webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    NSString *javascript = @"var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *nozoom = [[WKUserScript alloc] initWithSource:javascript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [webView.configuration.userContentController addUserScript:nozoom];
    [webView.scrollView setShowsHorizontalScrollIndicator:NO];
    [webView loadRequest:request];
    [self.view addSubview:webView];

    UIBarButtonItem *feedback = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"square.and.pencil"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(showFeedbackForm)];
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                target:self
                                                                                action:@selector(refreshNews)];
    self.navigationItem.rightBarButtonItems = @[feedback, refresh];

    if(!isJailbroken && getPrefBool(@"warnings.limited_ram_warn") && (roundf(NSProcessInfo.processInfo.physicalMemory / 0x1000000) < 3900)) {
        // "This device has a limited amount of memory available."
        [self showWarningAlert:@"limited_ram" hasPreference:YES exitWhenCompleted:NO];
    }

    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.rightBarButtonItem = [sidebarViewController drawAccountButton];
    self.navigationItem.leftItemsSupplementBackButton = true;
}

- (void)refreshNews {
    [webView reload];
}

- (void)showFeedbackForm {
    UIAlertController *form = [UIAlertController alertControllerWithTitle:@"Send feedback"
                                                                       message:@"Help improve Ocean Launcher"
                                                                preferredStyle:UIAlertControllerStyleAlert];
    [form addTextFieldWithConfigurationHandler:^(UITextField *field) {
        field.placeholder = @"What should we improve?";
        field.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    [form addAction:[UIAlertAction actionWithTitle:localize(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [form addAction:[UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *feedback = form.textFields.firstObject.text;
        if (feedback.length == 0) return;
        UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:@[feedback] applicationActivities:nil];
        share.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItems.firstObject;
        [self presentViewController:share animated:YES completion:nil];
    }]];
    [self presentViewController:form animated:YES completion:nil];
}

-(void)showWarningAlert:(NSString *)key hasPreference:(BOOL)isPreferenced exitWhenCompleted:(BOOL)shouldExit {
    UIAlertController *warning = [UIAlertController
                                      alertControllerWithTitle:localize([NSString stringWithFormat:@"login.warn.title.%@", key], nil)
                                      message:localize([NSString stringWithFormat:@"login.warn.message.%@", key], nil)
                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action;
    if(isPreferenced) {
        action = [UIAlertAction actionWithTitle:localize(@"OK", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            setPrefBool([NSString stringWithFormat:@"warnings.%@_warn", key], NO);
        }];
    } else if(shouldExit) {
        action = [UIAlertAction actionWithTitle:localize(@"OK", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            [UIApplication.sharedApplication performSelector:@selector(suspend)];
            usleep(100*1000);
            exit(0);
        }];
    } else {
        action = [UIAlertAction actionWithTitle:localize(@"OK", nil) style:UIAlertActionStyleCancel handler:nil];
    }
    warning.popoverPresentationController.sourceView = self.view;
    warning.popoverPresentationController.sourceRect = self.view.bounds;
    [warning addAction:action];
    [self presentViewController:warning animated:YES completion:nil];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > 0)
        scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self adjustWebViewForSize:size];
}

- (void)adjustWebViewForSize:(CGSize)size {
    BOOL isPortrait = size.height > size.width;
    if (isPortrait) {
        webView.scrollView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + insets.top, 0, self.navigationController.navigationBar.frame.size.height + insets.bottom, 0);
    } else {
        webView.scrollView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height, 0, self.navigationController.navigationBar.frame.size.height, 0);
    }
}

- (void)webView:(WKWebView *)webView 
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction 
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
     if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        openLink(self, navigationAction.request.URL);
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"[News] Could not load changelog: %@", error.localizedDescription);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"News unavailable"
                                                                       message:@"The live changelog could not be loaded. Check your connection and try refresh."
                                                                preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:localize(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
