//
//  PathManager+Utility.h
//  Draw
//
//  Created by HuangPeng on 2018/5/29.
//  Copyright © 2018年 ZJW. All rights reserved.
//

#import "PathManager.h"

@interface PathManager (Utility)

- (BOOL)mh_isNullOrNil:(id)obj;


/*
 当前时间戳, 系统时间戳，不是1970,与touch.timestamp匹配
 */
- (NSTimeInterval)nowTimeStamp;

/**
 两点之间的直线距离
 */
- (CGFloat)distanceFrom:(CGPoint)point1 toPoint:(CGPoint)point2;

/**
 判断是否为手掌touch 通过majorRadius 和 majorRadiusTorlence
 */
- (BOOL)isPalmTouch:(DHTouch *)dhtouch;


@end
