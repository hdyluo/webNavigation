//
//  DYWebViewLoadingView.m
//  DiaoDiao
//
//  Created by 黄德玉 on 2017/8/28.
//  Copyright © 2017年 none. All rights reserved.
//

#import "DYWebViewLoadingView.h"
#import "DYWebHeader.h"



@interface DYWebViewLoadingView ()

@property(nonatomic,strong) CAGradientLayer * mLayer;
@property (nonatomic,strong) NSTimer * timer;

@end

@implementation DYWebViewLoadingView

- (instancetype)init{
    if (self = [super init]) {
        self.mLayer = [[CAGradientLayer alloc] init];
        self.mLayer.colors =  @[(__bridge id)WB_PROGRESS_START_COLOR.CGColor,(__bridge id)WB_PROGRESSS_END_COLOR.CGColor];
        self.mLayer.startPoint = CGPointMake(0, .5);
        self.mLayer.endPoint = CGPointMake(1, .5);
        self.mLayer.frame = CGRectMake(0, 0,0,WB_PROGRESS_LAYER_HEIGHT);
        self.mLayer.cornerRadius = 2.0;
        [self.layer addSublayer:self.mLayer];
    }
    return self;
}

- (void)dealloc{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}


-(void)startLoading{
    self.alpha = 1;
    [self loadProgress:0];
}

- (void)loadProgress:(CGFloat)progess{
    
    if (WB_USE_TIMER_PROGRESS) {
        if (!self.timer) {
            __weak typeof(self) weakSelf = self;
            __block CGFloat currentValue = 0;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (currentValue < 0.7) {
                    currentValue += 0.01;
                     strongSelf.mLayer.frame =  CGRectMake(0, 0,WB_SCREEN_WIDTH * currentValue, WB_PROGRESS_LAYER_HEIGHT);
                }
            }];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        }
        return;
    }
    if (progess < 0) {
        progess = 0;
    }
    if (progess > 1) {
        progess = 1;
    }
    self.mLayer.frame =  CGRectMake(0, 0,WB_SCREEN_WIDTH * progess, WB_PROGRESS_LAYER_HEIGHT);
}

-(void)endLoading{
    self.mLayer.frame =  CGRectMake(0, 0,WB_SCREEN_WIDTH, WB_PROGRESS_LAYER_HEIGHT);
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
//        [self removeFromSuperview];
    }];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
