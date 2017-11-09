//
//  DYWebViewLoadingView.h
//  DiaoDiao
//
//  Created by 黄德玉 on 2017/8/28.
//  Copyright © 2017年 none. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DYWebViewLoadingView : UIView

-(void)startLoading;

- (void)loadProgress:(CGFloat)progess;

-(void)endLoading;


@end
