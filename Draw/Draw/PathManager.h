//
//  PathManager.h
//  Draw
//
//  Created by HuangPeng on 2018/5/7.
//  Copyright © 2018年 ZJW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PathManagerConfig.h"

#import "ZJWBezierPath.h"
#import "DHTouch.h"



typedef void(^RegisterContentBlock)(NSString *content);
typedef void(^MajorContentBlock)(NSString *content);

@interface PathManager : NSObject

/*
 蓝牙是否连接
 */
@property (nonatomic) BOOL isConnectedBlueTooth;

/*
 接收到笔触信号 , 蓝牙笔是否按压在屏幕上
 */
@property (nonatomic) BOOL isPenWriting;

/*
 蓝牙上报时的timestamp，用于比较晚到的touch,
 */
@property (nonatomic) NSTimeInterval writingTimeStamp;

/*
 当前认定的触电
 */
@property (nonatomic, strong) DHTouch *curDHTouch;

/*
 当前触屏的所有touch
 */
@property (nonatomic, strong) NSMutableDictionary *holdTouches;



/*
 保存所有画线
 */
@property (nonatomic,strong) NSMutableArray *paths;

/*
 当前画线
 */
@property (nonatomic,strong) ZJWBezierPath *path;

/*
 反馈消息block
 */
@property (nonatomic, copy) RegisterContentBlock contentBlock;
@property (nonatomic, copy) MajorContentBlock majorBlock;

+ (PathManager *)sharedInstance;

- (void)touchesBegin:(NSArray *)touches;
- (void)touchesMove:(NSArray *)touches;
- (void)touchesEnded:(NSArray *)touches;
- (void)touchesCancel:(NSArray *)touches;


@end
