//
//  PathManager+Algorithms.h
//  Draw
//
//  Created by HuangPeng on 2018/5/29.
//  Copyright © 2018年 ZJW. All rights reserved.
//

#import "PathManager.h"

@interface PathManager (Algorithms)

/*
 获取当前currentTouch
 */
- (DHTouch *)currentTouchByAlgorithm;


/**
 根据蓝牙笔触上报时间距离最近的为 currentTouch
 */
- (DHTouch *)currentTouchFromLeastInterval;


/*
 滤波平滑算法点位转化
 */
- (CGPoint)LMSalgorithm:(CGPoint)point;

@end
