//
//  PathManager.m
//  Draw
//
//  Created by HuangPeng on 2018/5/7.
//  Copyright © 2018年 ZJW. All rights reserved.
//

#import "PathManager.h"
#import "PathManager+Utility.h"
#import "PathManager+Algorithms.h"


static PathManager *sharedObj = nil;

@interface PathManager()

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
        NSLog(@"currentTouchcurrentTouchcurrentTouch:%@",self.curDHTouch);
        DHTouch *algoriTouch = [self currentTouchByAlgorithm];
        if (algoriTouch) {
            self.curDHTouch = algoriTouch;
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
                [self addLineToPoint:[dhpoint cgPoint]];
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
    
    for (UITouch *touch in touches) {
        if (touch.phase==UITouchPhaseMoved) {
            NSLog(@"majorRadius move:%f %f",touch.majorRadius,touch.majorRadiusTolerance);///
            NSLog(@"begin move:%@",touch);
            DHTouch *existDTouch = (DHTouch *)[self.holdTouches objectForKey:@(touch.hash)];
            if (existDTouch) {
                CGPoint point = [touch locationInView:touch.view];
                [existDTouch.points addObject:[DHPoint dhPointWithCGPoint:point]];
            }
        }
        
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
}

- (void)touchesCancel:(NSArray *)touches {
    for (UITouch *touch in touches) {
        if ((touch.phase == UITouchPhaseCancelled)&&[self isTouchExist:touch]) {
            [self removeTouchObject:touch];
        }
    }
}

#pragma mark - Methods
/*
    point 不能为原点  与 上一个点不能距离过长
 */
- (void)addLineToPoint:(CGPoint)point {
    if (point.x>1&&point.y>1) {
        if (!self.path) {
            return;
        }
        
        NSProcessInfo *info = [NSProcessInfo processInfo];
        NSTimeInterval now = info.systemUptime;
        self.path.endTimeStamp = now;
        self.path.endPoint = point;
        [self.path addLineToPoint:point];
        
    }
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


@end
