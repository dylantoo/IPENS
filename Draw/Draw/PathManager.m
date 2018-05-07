//
//  PathManager.m
//  Draw
//
//  Created by HuangPeng on 2018/5/7.
//  Copyright © 2018年 ZJW. All rights reserved.
//

#import "PathManager.h"
#import "DHPoint.h"

#define BlueToothDelay  0.3

static PathManager *sharedObj = nil;

@interface PathManager()

//由于蓝牙信号延迟的关系需要预存之前的touch  延迟时间定为300ms
@property (nonatomic, strong) NSMutableArray *bufferPaths;

//判定在缓存中
@property (nonatomic) BOOL isBuffering;


@end

@implementation PathManager

+ (PathManager *)sharedInstance {
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedObj = [[PathManager alloc] init];
    });
    return sharedObj;
}

- (NSArray *)paths {
    if (!_paths) {
        _paths = [[NSMutableArray alloc] init];
    }
    return _paths;
}

- (NSMutableArray *)bufferPaths {
    if (!_bufferPaths) {
        _bufferPaths = [[NSMutableArray alloc] init];
    }
    return _bufferPaths;
}

- (void)setIsPenWriting:(BOOL)isPenWriting {
    _isPenWriting = isPenWriting;
    NSLog(@"pen is writing....:%d",isPenWriting);
}


- (void)setComingTouchWithBuffer:(UITouch *)touch {
    [self.bufferPaths removeAllObjects];
    self.isBuffering = YES;
    self.comingTouch = touch;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, BlueToothDelay), dispatch_get_main_queue(), ^{
        self.isBuffering = NO;
    });
    
}

- (void)setComingTouch:(UITouch *)comingTouch {
    if (!comingTouch) {
        _comingTouch = nil;
        self.currentTouch = nil;
        self.path = nil;
        return;
    }
    
    
    _comingTouch = comingTouch;
    
    if (self.isConnectedBlueTooth) {
        if (self.isBuffering) {

                //如果在缓冲过程中，先预存
            CGPoint touchPoint = [comingTouch locationInView:comingTouch.view];
            DHPoint *point = [DHPoint dhPointWithCGPoint:touchPoint];
//            NSLog(@"%@",[point pointDescription]);
            [self.bufferPaths addObject:point];
            return;
        }
        
        //蓝牙连接时屏蔽所有手指操作
        if (self.isPenWriting) {//
            if (self.bufferPaths.count>0) {
                for (int i = 0; i<self.bufferPaths.count; i++) {
                    DHPoint *dhpoint = (DHPoint *)self.bufferPaths[i];
                    if (i==0) {
                        if (!self.path) {
                            ZJWBezierPath *path = [ZJWBezierPath bezierPath];
                                //path创建好后，就可以设置其线宽，颜色等属性
                            [path moveToPoint:[dhpoint cgPoint]];
                            path.lineCapStyle = kCGLineCapRound;
                            path.lineJoinStyle = kCGLineJoinRound;
                            path.pathColor = [UIColor blueColor];
                            path.lineWidth = 4;
                            self.path = path;
                            [self.paths addObject:self.path];
                        }
                    }
                    else {
                        NSLog(@"%@",[dhpoint pointDescription]);
                        [self.path addLineToPoint:[dhpoint cgPoint]];
                    }
                }

                [self.bufferPaths removeAllObjects];
            }
            
            if (!self.currentTouch) {
                self.currentTouch = comingTouch;
            }
            else {
                [self.path addLineToPoint:[comingTouch locationInView:comingTouch.view]];
            }
        }
        else {
            _comingTouch = nil;
        }
    }
    else {
        
    }
    
}

- (void)setCurrentTouch:(UITouch *)currentTouch {
    _currentTouch = currentTouch;
    
    if (!self.path) {
        ZJWBezierPath *path = [ZJWBezierPath bezierPath];
            //path创建好后，就可以设置其线宽，颜色等属性
        [path moveToPoint:[currentTouch locationInView:currentTouch.view]];
        path.lineCapStyle = kCGLineCapRound;
        path.lineJoinStyle = kCGLineJoinRound;
        path.pathColor = [UIColor blueColor];
        path.lineWidth = 4;
        self.path = path;
        [self.paths addObject:self.path];
    }
}


@end
