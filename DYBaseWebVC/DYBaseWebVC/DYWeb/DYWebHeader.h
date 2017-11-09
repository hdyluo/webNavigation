//
//  DYWebHeader.h
//  DYBaseWebVC
//
//  Created by 黄德玉 on 2017/11/9.
//  Copyright © 2017年 none. All rights reserved.
//

#ifndef DYWebHeader_h
#define DYWebHeader_h




#ifdef DEBUG
#define WBLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define WBLog(...)
#endif

#define WB_SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define WB_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define WB_PROGRESS_LAYER_HEIGHT 3                          //进度条高度

#define WB_PROGRESS_START_COLOR [UIColor redColor]        //进度条颜色

#define WB_PROGRESSS_END_COLOR [UIColor redColor]           //进度条颜色

#define WB_USE_TIMER_PROGRESS 0                             //进度条进度方式，定时器驱动方式还是网页加载进度方式,定时器加载现在有问题，不要使用



#endif /* DYWebHeader_h */
