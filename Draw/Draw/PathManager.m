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

#pragma mark -Property

- (NSArray *)paths {
    if (!_paths) {
        _paths = [[NSMutableArray alloc] init];
    }
    return _paths;
}

- (NSMutableArray *)holdTouches {
    if (!_holdTouches) {
        _holdTouches = [[NSMutableArray alloc] init];
    }
    return _holdTouches;
}

- (NSMutableArray *)bufferPaths {
    if (!_bufferPaths) {
        _bufferPaths = [[NSMutableArray alloc] init];
    }
    return _bufferPaths;
}

- (void)setIsConnectedBlueTooth:(BOOL)isConnectedBlueTooth {
    _isConnectedBlueTooth = isConnectedBlueTooth;
}

- (void)setIsPenWriting:(BOOL)isPenWriting {
    
    if (_isPenWriting == isPenWriting) {
        return;
    }
    
    _isPenWriting = isPenWriting;
    
    
    
    NSLog(@"pen is writing....:%d",isPenWriting);
    if (_isPenWriting) {
        
        if (self.holdTouches.count>0) {
            self.currentTouch = [self currentTouchFromLeastInterval];
        }
        
    }
}


- (void)setComingTouchWithBuffer:(UITouch *)touch {
    NSLog(@"setComingTouchWithBuffer.........++++++++++++++++++++++++");
    [self.bufferPaths removeAllObjects];
    self.isBuffering = YES;
    self.comingTouch = touch;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, BlueToothDelay), dispatch_get_main_queue(), ^{
        self.isBuffering = NO;
    });
    
}


- (void)setComingTouch:(UITouch *)comingTouch {
    if (!comingTouch) {
//        _comingTouch = nil;
        self.currentTouch = nil;
        self.path = nil;
        return;
    }
    
    
//    _comingTouch = comingTouch;
    
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
                        [self addLineToPoint:[dhpoint cgPoint]];
                    }
                }

                [self.bufferPaths removeAllObjects];
            }
            
            if (!self.currentTouch) {
                self.currentTouch = comingTouch;
            }
            else {
                CGPoint curPoint = [self.currentTouch locationInView:self.currentTouch.view];
            
                [self addLineToPoint:curPoint];
            
                
            }
        }
        else {
//            _comingTouch = nil;
        }
    }
    else {
        
    }
    
}

- (void)setCurrentTouch:(UITouch *)currentTouch {
    _currentTouch = currentTouch;

    if (!currentTouch) {
        self.path = nil;
    }
    else {
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
}


#pragma mark - Touch

- (void)touchesBegin:(NSArray *)touches {
    if (self.isConnectedBlueTooth) {
        for (UITouch *touch in touches) {
            if ((touch.phase == UITouchPhaseBegan)&&![self isTouchExist:touch]) {
                [self addTouchObject:touch];
            }
        }
        
//        if (self.holdTouches.count>0&&self.isPenWriting) {
//            self.currentTouch = self.holdTouches[0];
//        }
    }
    else {
        
    }
}

- (void)touchesMove:(NSArray *)touches {
    for (UITouch *touch in touches) {
        if ([touch isEqual:self.currentTouch]) {
            CGPoint curPoint = [self.currentTouch locationInView:self.currentTouch.view];
            [self addLineToPoint:curPoint];
        }
    }
}

- (void)touchesEnded:(NSArray *)touches {
    for (UITouch *touch in touches) {
        if ((touch.phase == UITouchPhaseEnded)&&[self isTouchExist:touch]) {
            [self removeTouchObject:touch];
            
            if ([touch isEqual:self.currentTouch]) {
                self.currentTouch = nil;
            }
        }
    }
}

- (void)touchesCancel:(NSArray *)touches {
    for (UITouch *touch in touches) {
        if ((touch.phase == UITouchPhaseCancelled)&&[self isTouchExist:touch]) {
            [self removeTouchObject:touch];
            
            if ([touch isEqual:self.currentTouch]) {
                self.currentTouch = nil;
            }
        }
    }
}

/*
- (void)setBeginTouches:(NSArray *)touches {
    if (self.isPenWriting) {
        NSLog(@"beingggggggg penwritttttting....");
    }
    else {
        NSLog(@"begin touches ssssssssss:%@",touches);
        for (int i =0 ; i<touches.count; i++) {
            UITouch *touch = touches[i];
            if (touch.phase == UIPressPhaseBegan) {
                BOOL isexist = NO;
                for (UITouch *existTouch in self.timeTouches) {
                    
                    if ([existTouch isEqual:touch]) { //||(existTouch.timestamp==touch.timestamp)
                        isexist = YES;
                    }
                }
                if (!isexist) {
                    [self.timeTouches addObject:touch];
                    [self.touchesTimeArray addObject:[NSString stringWithFormat:@"%f",touch.timestamp]];
                }
            }
        }
        NSLog(@"begin edn touches ssssssssss:%@",self.timeTouches);
    }
}

- (void)setMoveTouches:(NSArray *)touches {
    NSLog(@"moooooooooooove touches:%@",touches);
    if (self.currentTouch) {
        for (UITouch *touch in touches) {
            if ([touch isEqual:self.currentTouch]) {
                CGPoint curPoint = [touch locationInView:touch.view];
                
                    [self addLineToPoint:curPoint];
                
            }
        }
        return;
    }
    
    NSLog(@"move indexllflldl:%ld",(long)self.touchesIndex);
    if (self.isPenWriting&&self.touchesIndex<self.touchesTimeArray.count) {
        self.comingTouch = self.timeTouches[self.touchesIndex];
    }
}

- (void)touchesEnded:(NSArray *)touches {
    for (UITouch *touch in touches) {
        if ([touch isEqual:self.currentTouch]) {
            NSLog(@"end the same touch..........");
//            self.currentTouch = nil;
            self.comingTouch = nil;
//            self.path = nil;
            self.touchesIndex = 0;
            [self.touchesTimeArray removeAllObjects];
            [self.timeTouches removeAllObjects];
        }
    }
}

- (void)touchesCancel:(NSArray *)touches {
    for (UITouch *touch in touches) {
        if ([touch isEqual:self.currentTouch]) {
            NSLog(@"cancel..end the same touch..........");
                //            self.currentTouch = nil;
            self.comingTouch = nil;
//            self.path = nil;
            self.touchesIndex = 0;
            [self.touchesTimeArray removeAllObjects];
            [self.timeTouches removeAllObjects];
        }
    }
}
 */


#pragma mark - algorithm
/*
    point 不能为原点  与 上一个点不能距离过长
 */
- (void)addLineToPoint:(CGPoint)point {
    if (point.x>1&&point.y>1) {
        if (!self.path) {
            return;
        }
        
        if (self.paths.count>0) {
            ZJWBezierPath *bPath = self.paths.lastObject;
            
            CGPoint lastPoint = bPath.currentPoint;
            CGFloat a = fabs(lastPoint.x-point.x);
            CGFloat b = fabs(lastPoint.y-point.y);
            if (sqrtf(a*a+b*b)>50) {
                return;
            }

            
            [bPath addLineToPoint:point];
        }
        
    }
}

/*
 判断新的touch是否已经存在队列中
 */
- (BOOL)isTouchExist:(UITouch *)touch {
    BOOL isexist = NO;
    for (UITouch *existTouch in self.holdTouches) {
        if ([existTouch isEqual:touch]) {
            isexist = YES;
        }
    }
    return isexist;
}

/*
 根据蓝牙笔触上报时间距离最近的为 currentTouch
 */
- (UITouch *)currentTouchFromLeastInterval {
        //系统开机时间
    NSProcessInfo *info = [NSProcessInfo processInfo];
    NSTimeInterval now = info.systemUptime;
    NSLog(@"%f", info.systemUptime);
    NSLog(@"array:%@",self.holdTouches);
    int index = 0;
    for (int i =0; i<self.holdTouches.count-1; i++) {
        /* 时间戳最接近蓝牙笔触上报时间点, 记得count-1
        NSTimeInterval first = ((UITouch *)self.holdTouches[i]).timestamp;
        NSTimeInterval second = ((UITouch *)self.holdTouches[i+1]).timestamp;
        NSLog(@"touch time:%f,%f",first,second);
        if (fabs(first-now) < fabs(second-now)) {
            index = i;
        }
        else {
            index = i+1;
        }
         */
        
        /*
         右手握笔 判定左边点
         */
        UITouch *touch1 = (UITouch *)self.holdTouches[i];
        UITouch *touch2 = (UITouch *)self.holdTouches[i+1];
        if ([touch1 locationInView:touch1.view].x<[touch2 locationInView:touch2.view].x) {
            index = i;
        }
        else {
            index = i+1;
        }
    }
    return self.holdTouches[index];
     
}


/*
 touches 存储变化的时候
 */
- (void)addTouchObject:(UITouch *)touch {
    if (!self.isPenWriting&&!self.currentTouch) {
        [self.holdTouches addObject:touch];
    }
}

- (void)removeTouchObject:(UITouch *)touch {
    [self.holdTouches removeObject:touch];
}

@end
