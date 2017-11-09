//
//  ViewController.m
//  DYBaseWebVC
//
//  Created by 黄德玉 on 2017/11/9.
//  Copyright © 2017年 none. All rights reserved.
//

#import "ViewController.h"
#import "DYBaseWebVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    DYBaseWebVC * vc = [[DYBaseWebVC alloc] initWithData:@{@"url":@"https://www.baidu.com",
                                                           @"handleMessage":@[@"helloworld"]
                                                           }];
    [self.navigationController pushViewController:vc animated:YES];
}



@end
