//
//  DYBaseWebVC.m
//  DYBaseWebVC
//
//  Created by 黄德玉 on 2017/11/9.
//  Copyright © 2017年 none. All rights reserved.
//

#import "DYBaseWebVC.h"

@interface _LeakAvoider:NSObject<WKScriptMessageHandler>
//https://stackoverflow.com/questions/26383031/wkwebview-causes-my-view-controller-to-leak
@property (nonatomic,weak) id<WKScriptMessageHandler> scriptDelegate;
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;
@end

@interface DYBaseWebVC ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property (nonatomic,strong) id urlData;
@property (nonatomic,strong) WKWebView * webView;
@property (nonatomic,strong) WKUserContentController * contentController;
@property (nonatomic,strong) DYWebViewLoadingView * loadingView;
@end

@implementation DYBaseWebVC

- (instancetype)initWithData:(id)data{
    if (self = [super init]) {
        self.urlData = data;
    }
    return self;
}

- (void)dealloc{
    WBLog(@"webView释放");
    NSArray * message = [self.urlData objectForKey:@"handleMessage"];
    if (message && [message isKindOfClass:[NSArray class]]) {
        for (NSInteger i = 0; i < message.count; i++) {
            [_contentController removeScriptMessageHandlerForName:message[i]];
        }
    }
    [_webView removeObserver:self forKeyPath:@"loading" context:nil];//移除kvo
    [_webView removeObserver:self forKeyPath:@"title" context:nil];
    [_webView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.loadingView];
    self.loadingView.frame = CGRectMake(0, 64, WB_SCREEN_WIDTH, WB_PROGRESS_LAYER_HEIGHT);
    [self _addOberserver];
    NSString * urlStr = [self.urlData objectForKey:@"url"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [self.webView loadRequest:request];
    [self _addCloseBtn];
}

- (void)_addCloseBtn{
    
    UIBarButtonItem * item0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    item0.width = -20;
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    UIBarButtonItem * item1 = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIButton * btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn2 setTitle:@"关闭" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(closeClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * item2 = [[UIBarButtonItem alloc] initWithCustomView:btn2];
    self.navigationItem.leftBarButtonItems = @[item0,item1,item2];
    item2.customView.hidden = YES;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;   //解决设置导航栏leftItem 无法侧滑返回的问题
    }
}

- (void)backClicked{
    WBLog(@"返回点击");
    if (self.webView.canGoBack) {
         [self.webView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)closeClicked{
     [self.navigationController popViewControllerAnimated:YES];
}

- (void)_dealWithCloseBtn{
    if (self.webView.backForwardList.backList.count > 0) {
        self.navigationItem.leftBarButtonItems[2].customView.hidden = NO;
    }else{
        self.navigationItem.leftBarButtonItems[2].customView.hidden = YES;
    }
}

- (void)_addOberserver{
    [self.webView addObserver:self
                   forKeyPath:@"loading"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    
    [self.webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    
    [self.webView addObserver:self
                   forKeyPath:@"estimatedProgress"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
}

#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context{
    if ([keyPath isEqualToString:@"loading"]){
        WBLog(@"加载中");
    } else if ([keyPath isEqualToString:@"title"]){
        WBLog(@"设置标题");
        [self _dealWithCloseBtn];//经过多次尝试，发现关闭按钮的显示时机在这里设置最合适
        NSString * title = self.webView.title;
        if (title.length > 5) {
            title = [title substringToIndex:4];
            title = [NSString stringWithFormat:@"%@...",title];
        }
        self.title = title;
    } else if ([keyPath isEqualToString:@"estimatedProgress"]){
        if (!WB_USE_TIMER_PROGRESS) {
            [self.loadingView loadProgress:self.webView.estimatedProgress];
            if (self.webView.estimatedProgress >= 1.0) {
                [self.loadingView endLoading];
            }
        }
    }
}

#pragma mark - WKNavigationDelegate
// 在发送请求之前，决定是否跳转 第一步
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    [self.loadingView startLoading];
    WBLog(@"-------decidePolicyForNavigationAction-------")
//    NSLog(@"%@",navigationAction.request.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
}
// 页面开始加载时调用Called when web content begins to load in a web view. 第二部
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    WBLog(@"---------didStartProvisionalNavigation--------");
}
// 在收到响应后，决定是否跳转 第三部
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    WBLog(@"------decidePolicyForNavigationResponse------")
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}
// 当内容开始返回时调用Called when the web view begins to receive web content. 第四部
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    WBLog(@"------didCommitNavigation------");
}
// 页面加载完成之后调用Called when the navigation is complete. 第五不
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self.loadingView endLoading];
    WBLog(@"------didFinishNavigation------")
//    if (self.webView.estimatedProgress >= 1.0) {
//        [self _dealWithCloseBtn];
//    }
    //OC执行js的时机，最早也是在这里
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    [self.loadingView endLoading];
    WBLog(@"------didFailProvisionalNavigation------");
//    if (self.webView.estimatedProgress >= 1.0) {
//        [self _dealWithCloseBtn];
//    }
}
// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    WBLog(@"------didReceiveServerRedirectForProvisionalNavigation-------")
}



#pragma mark - WKUIDelegate

// 创建新的webview
// 可以指定配置对象、导航动作对象、window特性
//- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
//
//}

// webview关闭时回调
- (void)webViewDidClose:(WKWebView *)webView NS_AVAILABLE(10_11, 9_0){
}

// 调用JS的alert()方法
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    WBLog(@"拦截js的alert()方法");
}

// 调用JS的confirm()方法
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    WBLog(@"拦截js的confirm()方法");
}

// 调用JS的prompt()方法
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    WBLog(@"拦截js的prompt()方法");
}


#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
     NSArray * msg = [self.urlData objectForKey:@"handleMessage"];
    if (msg && [msg isKindOfClass:[NSArray class]]) {
        for (NSInteger i = 0; i < msg.count; i++) {
            if ([message.name isEqualToString:msg[i]]) {
                NSLog(@"%@", message.body);
            }
        }
    }
}



#pragma mark - 初始化

- (WKWebView *)webView{
    if (!_webView) {
        WKWebViewConfiguration *config = [WKWebViewConfiguration new];
        self.contentController = [[WKUserContentController alloc] init];
        config.userContentController = self.contentController;
        NSArray * msg = [self.urlData objectForKey:@"handleMessage"];
        if (msg && [msg isKindOfClass:[NSArray class]]) {
            for (NSInteger i = 0; i < msg.count; i++) {
                 [config.userContentController addScriptMessageHandler:[[_LeakAvoider alloc] initWithDelegate:self] name:msg[i]];
            }
        }
        
        //初始化偏好设置属性：preferences
        config.preferences = [WKPreferences new];
        //The minimum font size in points default is 0;
        config.preferences.minimumFontSize = 10;
        //是否支持JavaScript
        config.preferences.javaScriptEnabled = YES;
        //不通过用户交互，是否可以打开窗口
        config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
        _webView.UIDelegate = self;             //对于js的alert ,confirm,prompt 原生可以通过这个代理监听
        _webView.navigationDelegate = self;
        _webView.allowsBackForwardNavigationGestures = YES;
        
        _webView.scrollView.maximumZoomScale = 1.0;
        _webView.scrollView.minimumZoomScale   = 1.0;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        _webView.scrollView.showsVerticalScrollIndicator = NO;
    }
    return _webView;
}

- (DYWebViewLoadingView *)loadingView{
    if (!_loadingView) {
        _loadingView = [[DYWebViewLoadingView alloc] init];
    }
    return _loadingView;
}
@end




@implementation _LeakAvoider

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate{
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end

