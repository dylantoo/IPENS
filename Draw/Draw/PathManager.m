//
//  PathManager.m
//  Draw
//
//  Created by HuangPeng on 2018/5/7.
//  Copyright © 2018年 ZJW. All rights reserved.
//

#import "PathManager.h"
#import "DHTouch.h"

#define BlueToothDelay  0.3
#define MaxDistance     60

static PathManager *sharedObj = nil;

@interface PathManager()

/*
 一定是上一个currentTouch的值
 */
@property (nonatomic, strong) DHTouch *lastTouch;

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

- (DHTouch *)lastTouch {
    if(!_lastTouch) {
        _lastTouch = [[DHTouch alloc] init];
    }
    return _lastTouch;
}

- (NSArray *)paths {
    if (!_paths) {
        _paths = [[NSMutableArray alloc] init];
    }
    return _paths;
}

- (NSMutableDictionary *)holdTouches {
    if (!_holdTouches) {
        _holdTouches = [[NSMutableDictionary alloc] init];
    }
    return _holdTouches;
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
            self.currentTouch = [self currentTouchByAlgorithm];
        }
        
    }
}

- (void)setCurrentTouch:(UITouch *)currentTouch {
    if (!currentTouch) {
        self.lastTouch.touch = _currentTouch;
        self.lastTouch.lastPoint = [_currentTouch locationInView:_currentTouch.view];
        self.lastTouch.lastTimeStamp = _currentTouch.timestamp;
        self.path = nil;
    }
    else {
        CGPoint point = [currentTouch locationInView:currentTouch.view];
        NSString *content = [NSString stringWithFormat:@"书写信息:当前点位{%f,%f}",point.x,point.y];
        self.contentBlock(content);
        
        
        
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
        
        //删除其他touch感应
        for (DHTouch *touch in self.holdTouches.allValues) {
            if(![touch.touch isEqual:currentTouch]) {
                [self removeTouchObject:touch.touch];
            }
        }
        
    }
    
    _currentTouch = currentTouch;
}


#pragma mark - Touch

- (void)touchesBegin:(NSArray *)touches {
    if (self.isConnectedBlueTooth) {
        for (UITouch *touch in touches) {
            if ((touch.phase == UITouchPhaseBegan)&&![self isTouchExist:touch]) {
                NSLog(@"stypel...:%ld",(long)touch.type);
                [self addTouchObject:touch];
            }
        }
    }
    else {
        
    }
}

- (void)touchesMove:(NSArray *)touches {
    for (UITouch *touch in touches) {
        if ([touch isEqual:self.currentTouch]) {
            CGPoint point = [touch locationInView:touch.view];
            self.contentBlock([NSString stringWithFormat:@"书写信息:当前点位{%f,%f}",point.x,point.y]);
            
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
    
    UITouch *existtouch = ((DHTouch *)[self.holdTouches objectForKey:@(touch.hash)]).touch;
    if (existtouch) {
        return YES;
    }
    else {
        return NO;
    }
}

/*
 获取当前currentTouch
 */
- (UITouch *)currentTouchByAlgorithm {
    if (self.holdTouches.allValues.count==1) {
        NSLog(@"Only one touch!!!!!!!!");
        return ((DHTouch*)self.holdTouches.allValues[0]).touch;
    }
    
    if (self.paths.count>0) {
        return [self currentTouchFromLastTouch];
    }
    
    return [self currentTouchFromLeastInterval];
}


/*
 根据蓝牙笔触上报时间距离最近的为 currentTouch
 */
- (UITouch *)currentTouchFromLeastInterval {
        //系统开机时间
    NSProcessInfo *info = [NSProcessInfo processInfo];
    NSTimeInterval now = info.systemUptime;
    NSLog(@"%f", info.systemUptime);
    NSLog(@"aaaaaaaaaaarray:%@",self.holdTouches);
    int index = 0;
    for (int i =1; i<self.holdTouches.allKeys.count; i++) {
        //时间戳最接近蓝牙笔触上报时间点
        NSTimeInterval first = ((DHTouch *)self.holdTouches.allValues[index]).beginTimStamp;
        NSTimeInterval second = ((DHTouch *)self.holdTouches.allValues[i]).beginTimStamp;
        NSLog(@"touch time:%f,%f",first,second);
        if (fabs(first-now) <= fabs(second-now)) {
//            index = i;
        }
        else {
            index = i;
        }
        NSLog(@"self.holdTouches.allValues:%d",index);
        
        /*
         右手握笔 判定左边点
         */
        
        /*
        UITouch *touch1 = (UITouch *)self.holdTouches.allValues[i];
        UITouch *touch2 = (UITouch *)self.holdTouches.allValues[i+1];
        if ([touch1 locationInView:touch1.view].x<[touch2 locationInView:touch2.view].x) {
            index = i;
        }
        else {
            index = i+1;
        }
         */
    }
    return ((DHTouch *)self.holdTouches.allValues[index]).touch;
}

/*
 已经画过，如果前一个点，与当前点，时间和距离足够近，取当前touch
 */
- (UITouch *)currentTouchFromLastTouch {
    NSLog(@"currentTouchFromLastTouch+++++++++++++++");
    for (DHTouch *touch in self.holdTouches.allValues) {
        CGPoint tPoint = [touch.touch locationInView:touch.touch.view];
        CGFloat sinterval = fabs(touch.touch.timestamp-self.lastTouch.lastTimeStamp);
        CGFloat slength = sqrtf((self.lastTouch.lastPoint.x-tPoint.x)*(self.lastTouch.lastPoint.x-tPoint.x)+(self.lastTouch.lastPoint.y-tPoint.y)*(self.lastTouch.lastPoint.y-tPoint.y));
        if ((sinterval<BlueToothDelay) && (slength<MaxDistance)) {
            return touch.touch;
        }
    }
    
    //如果不是相近点，还是走触电时间的
    return [self currentTouchFromLeastInterval];
}


/*
 touches 存储变化的时候
 */
- (void)addTouchObject:(UITouch *)touch {
    if (!self.isPenWriting&&!self.currentTouch) {//
        DHTouch *dhtouch = [[DHTouch alloc] init];
        dhtouch.touch = touch;
        dhtouch.beginTimStamp = touch.timestamp;
        [self.holdTouches setObject:dhtouch forKey:@(touch.hash)];
    }
}

- (void)removeTouchObject:(UITouch *)touch {
    [self.holdTouches removeObjectForKey:@(touch.hash)];
}

@end
