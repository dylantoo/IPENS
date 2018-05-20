//
//  PathManager.m
//  Draw
//
//  Created by HuangPeng on 2018/5/7.
//  Copyright © 2018年 ZJW. All rights reserved.
//

#import "PathManager.h"


#define BlueToothDelay  0.3
#define MaxDistance     60
//判定笔书写的最短距离
#define MinDistance     20

    /// 屏幕尺寸相关
#define MH_SCREEN_WIDTH  ([[UIScreen mainScreen] bounds].size.width)
#define MH_SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

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
            NSLog(@"currentTouchcurrentTouchcurrentTouch:%@",self.curDHTouch);
            if (self.paths.count==0) {
                NSLog(@"第一笔");
                self.curDHTouch = [self currentTouchByAlgorithm];
            }
            else if(self.paths.count>0) {
                NSLog(@"中间的某笔");
                self.curDHTouch = [self currentFromRightHandWrite];
            }
        }
        else {
            //笔触信号先到达
        }
        NSLog(@"afterrrrrrcurrentTouchcurrentTouchcurrentTouch:%@",self.curDHTouch);
    }
    else {
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
            NSLog(@"stypel...:%ld",(long)touch.type);
            [self addTouchObject:touch];
        }
    }
    NSLog(@"touchesBegintouchesBegintouchesBegin:%lu",(unsigned long)self.holdTouches.allValues.count);

}

- (void)touchesMove:(NSArray *)touches {
    
    for (UITouch *touch in touches) {
        if (touch.phase==UITouchPhaseMoved) {
            DHTouch *existDTouch = (DHTouch *)[self.holdTouches objectForKey:@(touch.hash)];
            NSLog(@"existDTouchexistDTouchexistDTouch:%@",existDTouch);
            if (existDTouch) {
                CGPoint point = [touch locationInView:touch.view];
                [existDTouch.points addObject:[DHPoint dhPointWithCGPoint:point]];
            }
        }
        
        if (self.isPenWriting&&!self.curDHTouch) {
            NSLog(@"!self.isPenWriting&&!self.curDHTouch");
            DHTouch *distanceTouch = [self currentFromLineDistance];
            if (distanceTouch) {
                self.curDHTouch = distanceTouch;
            }
        }
        
        
        if (self.curDHTouch) {
            CGPoint curPoint = [[self.curDHTouch.points lastObject] cgPoint];
            NSString *blockStr = [NSString stringWithFormat:@"书写信息:当前点位{%f,%f}",curPoint.x,curPoint.y];
            NSLog(@"moviiiiiiiiiiiingg:%@",blockStr);
            self.contentBlock(blockStr);
                //                self.currentTouch = touch;
            
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
        return ((DHTouch*)self.holdTouches.allValues[0]);
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
        //系统开机时间
    NSProcessInfo *info = [NSProcessInfo processInfo];
    NSTimeInterval now = info.systemUptime;
//    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSLog(@"%f", now);
   
    NSLog(@"aaaaaaaaaaarray::::");
    for (DHTouch *t in self.holdTouches.allValues) {
        NSLog(@"%@ time:%f hash:%@",t.touch,t.beginTimStamp,@(t.hash));
    }

    int index = 0;
    
    BOOL isHasPenWriting = NO;
    for (int j=0; j<self.holdTouches.allValues.count; j++) {
        NSTimeInterval first = ((DHTouch *)self.holdTouches.allValues[j]).beginTimStamp;
        NSLog(@"fabbbbbbbbs:%f",fabs(first-now));
        if (fabs(first-now)<BlueToothDelay) {
            index = j;
            isHasPenWriting = YES;
            break;
        }
    }
    
    if (!isHasPenWriting) {
        return nil;
    }
    for (int i = index+1; i<self.holdTouches.allKeys.count; i++) {
        //时间戳最接近蓝牙笔触上报时间点
        DHTouch *dtouch1 = (DHTouch *)self.holdTouches.allValues[index];
        DHTouch *dtouch2 = (DHTouch *)self.holdTouches.allValues[i];
        NSTimeInterval first = dtouch1.beginTimStamp;
        NSTimeInterval second = dtouch2.beginTimStamp;
        NSLog(@"touch time:%f,%f",first,second);
        if (fabs(first-now) < fabs(second-now)) {
//            index = i;
        }
        else if (fabs(first-now) == fabs(second-now)) {
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
    return ((DHTouch *)self.holdTouches.allValues[index]);
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
//    if (!self.isPenWriting&&[self mh_isNullOrNil:self.currentTouch]) {//
    NSLog(@"addTouchObjectaddTouchObjectaddTouchObject:%f",touch.timestamp);
    DHTouch *dhtouch = [[DHTouch alloc] init];
    dhtouch.touch = touch;
    dhtouch.beginTimStamp =  touch.timestamp;
    CGPoint point = [touch locationInView:touch.view];
    [dhtouch.points addObject:[DHPoint dhPointWithCGPoint:point]];
    [self.holdTouches setObject:dhtouch forKey:@(touch.hash)];
//    }
//    else if(self.isPenWriting && !self.currentTouch) {
//        //短暂提笔 写第二笔的情况
//        DHTouch *dhtouch = [[DHTouch alloc] init];
//        dhtouch.touch = touch;
//        dhtouch.beginTimStamp = touch.timestamp;
//        [self.holdTouches setObject:dhtouch forKey:@(touch.hash)];
//    }
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
