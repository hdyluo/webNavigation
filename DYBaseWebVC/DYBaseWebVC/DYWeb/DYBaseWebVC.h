//
//  DYBaseWebVC.h
//  DYBaseWebVC
//
//  Created by 黄德玉 on 2017/11/9.
//  Copyright © 2017年 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "DYWebViewLoadingView.h"
#import "DYWebHeader.h"

@interface DYBaseWebVC : UIViewController

/**
 初始化方式：需要提供基本的url参数，需要响应的js消息，需要执行的Js方法
 {
     @"url":@"https://www.baidu.com",       //url是必须的
     @"handleMessage":@[@"submitClicked"],     //非必须，如果需要原生响应js方法可以用：
                                            //window.webkit.messageHandlers.submitClicked.postMessage({body: 'sender message'});
     @"executeJS":@"sayHi",                 // [self.webView evaluateJavaScript:@"sayHi('par1','par2')" completionHandler:
     @"executeJSParameter":@[@"key1",@"key2"]//执行js的时机和交互相关~~
 }

 @param data 参数
 @return 返回值
 */
- (instancetype)initWithData:(id)data;

@end
