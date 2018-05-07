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


@property (nonatomic) BOOL isConnectedBlueTooth;  //蓝牙是否连接
@property (nonatomic) BOOL isPenWriting;          //蓝牙笔是否在写

@property (nonatomic, strong) UITouch *comingTouch;
@property (nonatomic, strong) UITouch *currentTouch;


@property (nonatomic,strong) NSMutableArray *paths;
@property (nonatomic,strong) ZJWBezierPath *path;

+ (PathManager *)sharedInstance;

- (void)setComingTouchWithBuffer:(UITouch *)touch;

@end
