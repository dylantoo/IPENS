//
//  PathManager.m
//  Draw
//
//  Created by HuangPeng on 2018/5/7.
//  Copyright © 2018年 ZJW. All rights reserved.
//

#import "PathManager.h"

#define MaxDistance     60
//判定笔书写的最短距离
#define MinDistance     20

//判定掌控的值
#define PalmRadius      13

    /// 屏幕尺寸相关
#define MH_SCREEN_WIDTH  ([[UIScreen mainScreen] bounds].size.width)
#define MH_SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

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
        NSProcessInfo *info = [NSProcessInfo processInfo];
        NSTimeInterval now = info.systemUptime;
        self.writingTimeStamp = now;
        NSLog(@"pen writing time:%f",self.writingTimeStamp);
        
        
        if (self.holdTouches.allValues.count>0) {
            NSLog(@"currentTouchcurrentTouchcurrentTouch:%@",self.curDHTouch);
            DHTouch *algoriTouch = [self currentTouchByAlgorithm];
            if (algoriTouch) {
                self.curDHTouch = algoriTouch;
            }
        }
        else {
            //笔触信号先到达
//            WS(weakSelf)
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(BlueToothDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                if (self.holdTouches.allValues.count>0) {
//                    NSLog(@"currentTouchcurrentTouchcurrentTouch:%@",weakSelf.curDHTouch);
//                    DHTouch *algoriTouch = [weakSelf currentTouchByAlgorithm];
//                    if (algoriTouch) {
//                        weakSelf.curDHTouch = algoriTouch;
//                    }
//                }
//            });
            
        }
        NSLog(@"afterrrrrrcurrentTouchcurrentTouchcurrentTouch:%@",self.curDHTouch);
    }
    else {
        self.writingTimeStamp = 0.0;
        //新增考虑，需要增加，不然会有飞线的可能
        self.curDHTouch = nil;
    }
}

- (void)setCurDHTouch:(DHTouch *)curDHTouch {
    _curDHTouch = curDHTouch;
    if (curDHTouch) {
        NSLog(@"zzzzzzzzzzzzzzzzzzzzzzz;%@",self.path);
        if (!self.path) {
            NSLog(@"createcatet path");
        
            ZJWBezierPath *path = [ZJWBezierPath bezierPath];
                //path创建好后，就可以设置其线宽，颜色等属性
            [path moveToPoint:[curDHTouch.points[0] cgPoint]];
            path.lineCapStyle = kCGLineCapRound;
            path.lineJoinStyle = kCGLineJoinRound;
            path.pathColor = [UIColor blueColor];
            path.lineWidth = 4;
            self.path = path;
            [self.paths addObject:self.path];
            
            
            for (DHPoint *dhpoint in curDHTouch.points) {
                [self.path addLineToPoint:[dhpoint cgPoint]];
            }
        }
    }
    else {
        self.path = nil;
        [self.holdTouches removeAllObjects];
        self.isPenWriting = NO;
    }
}



#pragma mark - Touch

- (void)touchesBegin:(NSArray *)touches {
    if (!self.isConnectedBlueTooth) {
        return;
    }
    
    for (UITouch *touch in touches) {
        if ((touch.phase == UITouchPhaseBegan)) {//&&![self isTouchExist:touch]
            NSLog(@"touchsBegin事件时间戳:%f", touch.timestamp);
            NSLog(@"majorRadius begin:%f %f",touch.majorRadius,touch.majorRadiusTolerance);///
            NSLog(@"begin touch:%@",touch);
            [self addTouchObject:touch];
        }
    }
    

}

- (void)touchesMove:(NSArray *)touches {
    if (!self.isConnectedBlueTooth) {
        return;
    }
    
//    NSLog(@"touchsmove事件时间戳:%f", first.timestamp);
    
//    NSLog(@"majorRadius move:%f %f",first.majorRadius,first.majorRadiusTolerance);///
    
    for (UITouch *touch in touches) {
        if (touch.phase==UITouchPhaseMoved) {
            NSLog(@"majorRadius move:%f %f",touch.majorRadius,touch.majorRadiusTolerance);///
            NSLog(@"begin move:%@",touch);
            DHTouch *existDTouch = (DHTouch *)[self.holdTouches objectForKey:@(touch.hash)];
//            NSLog(@"touch:%@",touch);
            if (existDTouch) {
                CGPoint point = [touch locationInView:touch.view];
                [existDTouch.points addObject:[DHPoint dhPointWithCGPoint:point]];
            }
        }
        
//        if (self.isPenWriting&&!self.curDHTouch) {
//            NSLog(@"!self.isPenWriting&&!self.curDHTouch");
//            DHTouch *distanceTouch = [self currentFromLineDistance];
//            if (distanceTouch) {
//                self.curDHTouch = distanceTouch;
//            }
//        }
        
        
        if (self.curDHTouch) {
            CGPoint curPoint = [[self.curDHTouch.points lastObject] cgPoint];
            NSString *blockStr = [NSString stringWithFormat:@"书写信息:当前点位{%f,%f}",curPoint.x,curPoint.y];
            self.contentBlock(blockStr);
            [self addLineToPoint:curPoint];
        }
    }
}

- (void)touchesEnded:(NSArray *)touches {
    for (UITouch *touch in touches) {
        if ((touch.phase == UITouchPhaseEnded)&&[self isTouchExist:touch]) {
            [self removeTouchObject:touch];
        }
    }
    NSLog(@"touchesEndedtouchesEndedtouchesEnded:%lu",self.holdTouches.allKeys.count);
}

- (void)touchesCancel:(NSArray *)touches {
    for (UITouch *touch in touches) {
        if ((touch.phase == UITouchPhaseCancelled)&&[self isTouchExist:touch]) {
            [self removeTouchObject:touch];
        }
    }
    NSLog(@"touchesCanceltouchesCanceltouchesCancel:%lu",self.holdTouches.allKeys.count);
}

#pragma mark - algorithm
/*
 根据touch 划线距离判断
 */
- (DHTouch *)currentFromLineDistance {
    NSLog(@"currentFromLineDistanceBegin");
    int index = 0;
    BOOL isHasPenWriting = NO;
    for (int i =0; i<self.holdTouches.allValues.count; i++) {
        DHTouch *dhtouch = self.holdTouches.allValues[i];
        if (dhtouch.points.count>2) {
            DHPoint *dpoint1 = dhtouch.points[dhtouch.points.count-1];
            DHPoint *dpoint2 = dhtouch.points[0];
            
            CGPoint point1 = [dpoint1 cgPoint];
            CGPoint point2 = [dpoint2 cgPoint];
            
            if ( sqrtf((point1.x-point2.x)*(point1.x-point2.x)+(point1.y-point2.y)*(point1.y-point2.y))>MinDistance)  {
                index = i;
                isHasPenWriting = YES;
            }
        }
    }
    
    if (isHasPenWriting) {
        return self.holdTouches.allValues[index];
    }
    
    NSLog(@"currentFromLineDistanceAfter");
    return nil;
}

/*
 是否在手写
 touch事件必须大于2
 */
- (BOOL)isHandWriting {
    DHTouch *dhtouch = self.holdTouches.allValues[0];
    DHTouch *dhtouch1 = self.holdTouches.allValues[1];
    CGPoint point = [(DHPoint *)dhtouch.points[0] cgPoint];
    CGPoint point1 = [(DHPoint *)dhtouch1.points[0] cgPoint];
    if ((point.x>MH_SCREEN_WIDTH/2.0&&point.y>MH_SCREEN_HEIGHT/2.0)&&(point1.x>MH_SCREEN_WIDTH/2.0&&point1.y>MH_SCREEN_HEIGHT/2.0)) {
        return YES;
    }
    else {
        return NO;
    }
}

/*
 手写取最左侧的touch
 */
- (DHTouch *)currentFromRightHandWrite {
    int index = 0;
    for (int i =1; i<self.holdTouches.allValues.count; i++) {
        
        
        /*
         右手握笔 判定左边点
         */
        
        DHTouch *dhtouch1 = (DHTouch *)self.holdTouches.allValues[index];
        DHTouch *dhtouch2 = (DHTouch *)self.holdTouches.allValues[i];
        CGPoint point1 = [dhtouch1.points[0] cgPoint];
        CGPoint point2 = [dhtouch2.points[0] cgPoint];
        if (point1.x<point2.x) {
            
        }
        else {
            index = i;
        }
    }
    return (DHTouch *)self.holdTouches.allValues[index];
}


/*
    point 不能为原点  与 上一个点不能距离过长
 */
- (void)addLineToPoint:(CGPoint)point {
    if (point.x>1&&point.y>1) {
        if (!self.path) {
            return;
        }
        
        [self.path addLineToPoint:point];
//        if (self.paths.count>0) {
//            ZJWBezierPath *bPath = self.paths.lastObject;
//
//            CGPoint lastPoint = bPath.currentPoint;
//            CGFloat a = fabs(lastPoint.x-point.x);
//            CGFloat b = fabs(lastPoint.y-point.y);
////            if (sqrtf(a*a+b*b)>50) {
////                return;
////            }
//
//
//            [bPath addLineToPoint:point];
//        }
        
    }
}

/*
 判断新的touch是否已经存在队列中
 */
- (BOOL)isTouchExist:(UITouch *)touch {
    
    DHTouch *existtouch = (DHTouch *)[self.holdTouches objectForKey:@(touch.hash)];
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
- (DHTouch *)currentTouchByAlgorithm {
    if (self.holdTouches.allValues.count==1) {
        NSLog(@"Only one touch!!!!!!!!");
        
            //TODO: 是否还需要加入其它判断
        
        DHTouch *dhtouch = ((DHTouch*)self.holdTouches.allValues[0]);
        
        CGFloat abs = fabs(dhtouch.beginTimStamp-self.writingTimeStamp);
        NSLog(@"only .....%f",abs);
        
        CGFloat cent = dhtouch.touch.majorRadius/dhtouch.touch.majorRadiusTolerance;
        NSLog(@"only major :%f %f %f",dhtouch.touch.majorRadius,dhtouch.touch.majorRadiusTolerance,cent);
        
        
        if ((abs<BlueToothDelay)&&(cent<PalmRadius)) {
            return dhtouch;
        }
        NSLog(@"only return nil");
        return nil;
    }
    else if(self.holdTouches.allValues.count>1) {
        //有多点
        DHTouch *leastTouch = [self currentTouchFromLeastInterval];
        if (leastTouch) {
            return leastTouch;
        }
    }
    return nil;
}


/**
 根据蓝牙笔触上报时间距离最近的为 currentTouch
 */
- (DHTouch *)currentTouchFromLeastInterval {
   
    NSLog(@"aaaaaaaaaaarray::::");
    

    int index = 0;
    
    //进行第一批筛选去掉时间区域外和掌控明显的
    NSMutableArray *realArray = [NSMutableArray array];
    for (DHTouch *t in self.holdTouches.allValues) {
        NSLog(@"%@ time:%f hash:%@",t.touch,t.beginTimStamp,@(t.hash));
        if ((fabs(t.beginTimStamp-self.writingTimeStamp)<BlueToothDelay)&&((t.touch.majorRadius/t.touch.majorRadiusTolerance)<PalmRadius)) {
            [realArray addObject:t];
        }
        
    }
    
    if (realArray.count==0) {
        return nil;
    }
    
    for (int i = index+1; i<realArray.count; i++) {
        //时间戳最接近蓝牙笔触上报时间点
        DHTouch *dtouch1 = (DHTouch *)realArray[index];
        DHTouch *dtouch2 = (DHTouch *)realArray[i];
        NSTimeInterval first = dtouch1.beginTimStamp;
        NSTimeInterval second = dtouch2.beginTimStamp;
        NSLog(@"touch time:%f,%f",first,second);
        if (fabs(first-self.writingTimeStamp) < fabs(second-self.writingTimeStamp)) {
//            index = i;
        }
        else if (fabs(first-self.writingTimeStamp) == fabs(second-self.writingTimeStamp)) {
            //如果时间相同 左撇子靠左的点
            CGFloat x1 = [dtouch1.points[0] cgPoint].x;
            CGFloat x2 = [dtouch2.points[0] cgPoint].x;
            if (x1<x2) {
                
            }
            else {
                index = i;
            }
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
    return ((DHTouch *)realArray[index]);
}


/*
 touches 存储变化的时候
 */
- (void)addTouchObject:(UITouch *)touch {
//    if (!self.isPenWriting&&[self mh_isNullOrNil:self.currentTouch]) {//
    NSLog(@"addTouchObjectaddTouchObjectaddTouchObject:%f",touch.timestamp);
    DHTouch *dhtouch = [[DHTouch alloc] init];
    dhtouch.touch = touch;
    dhtouch.beginTimStamp =  touch.timestamp;
    CGPoint point = [touch locationInView:touch.view];
    [dhtouch.points addObject:[DHPoint dhPointWithCGPoint:point]];
    [self.holdTouches setObject:dhtouch forKey:@(touch.hash)];
    
    
    if (self.isPenWriting&&!self.curDHTouch) {
        DHTouch *algoriTouch = [self currentTouchByAlgorithm];
        if (algoriTouch) {
            self.curDHTouch = algoriTouch;
        }
    }
    
    if (self.isPenWriting&&self.curDHTouch) {
        DHTouch *algoriTouch = [self currentTouchByAlgorithm];
        if (algoriTouch&&(dhtouch.touch.hash !=self.curDHTouch.touch.hash)) {
            
            //时长内多个点取左侧点
            
            CGPoint alpoint = [[algoriTouch.points firstObject] cgPoint];
            CGPoint curpoint = [[self.curDHTouch.points firstObject] cgPoint];
            
            if (alpoint.x<curpoint.x) {
                self.path = nil;
                [self.paths removeLastObject];
                self.curDHTouch = algoriTouch;
            }
        }
    }

}

- (void)removeTouchObject:(UITouch *)touch {
    DHTouch *dhtouch = self.holdTouches[@(touch.hash)];
    if (self.curDHTouch) {
        if (dhtouch.touch.hash ==self.curDHTouch.touch.hash) {
            self.curDHTouch = nil;
        }
    }
    [self.holdTouches removeObjectForKey:@(touch.hash)];
}

- (BOOL)mh_isNullOrNil:(id)obj {
    return !obj || [obj isKindOfClass:[NSNull class]];
    
}

@end
