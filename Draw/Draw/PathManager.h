//
//  PathManager.h
//  Draw
//
//  Created by HuangPeng on 2018/5/7.
//  Copyright © 2018年 ZJW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZJWBezierPath.h"
#import "DHTouch.h"

#define PATHMANAGER [PathManager sharedInstance]

@interface PathManager : NSObject

/*
 蓝牙是否连接
 */
@property (nonatomic) BOOL isConnectedBlueTooth;

/*
 接收到笔触信号 , 蓝牙笔是否在写
 */
@property (nonatomic) BOOL isPenWriting;

/*
 当前认定的触电
 */
@property (nonatomic, strong) UITouch *currentTouch;

/*
 当前触屏的所有touch
 */
@property (nonatomic, strong) NSMutableArray *holdTouches;

/*
 保存所有画线
 */
@property (nonatomic,strong) NSMutableArray *paths;

/*
 当前画线
 */
@property (nonatomic,strong) ZJWBezierPath *path;



+ (PathManager *)sharedInstance;


- (void)touchesBegin:(NSArray *)touches;
- (void)touchesMove:(NSArray *)touches;
- (void)touchesEnded:(NSArray *)touches;
- (void)touchesCancel:(NSArray *)touches;

@end
