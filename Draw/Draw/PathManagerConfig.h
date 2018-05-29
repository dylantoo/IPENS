//
//  PathManagerConfig.m
//  Draw
//
//  Created by HuangPeng on 2018/5/29.
//  Copyright © 2018年 ZJW. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PATHMANAGER [PathManager sharedInstance]

//蓝牙延迟时间
#define BlueToothDelay  0.3

#define MaxDistance     60
    //判定笔书写的最短距离
#define MinDistance     20

    //判定掌控的值
#define PalmRadius      8.1
#define PalmRadiusMin      4

    //连续写时间距离间隔
#define ContinueMaxDistance  50
#define ContinueMaxTime      0.3


    /// 屏幕尺寸相关
#define MH_SCREEN_WIDTH  ([[UIScreen mainScreen] bounds].size.width)
#define MH_SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
