//
//  PathManager+Algorithms.m
//  Draw
//
//  Created by HuangPeng on 2018/5/29.
//  Copyright © 2018年 ZJW. All rights reserved.
//

#import "PathManager+Algorithms.h"
#import "PathManager+Utility.h"

@implementation PathManager (Algorithms)

/*
 获取当前currentTouch
 */
- (DHTouch *)currentTouchByAlgorithm {
    if (self.holdTouches.allValues.count==0) {
        NSLog(@"还没有touch预存！！！！");
        return nil;
    }
    else if (self.holdTouches.allValues.count==1) {
        NSLog(@"Only one touch!!!!!!!!");
        
            //TODO: 是否还需要加入其它判断
        
        DHTouch *dhtouch = ((DHTouch*)self.holdTouches.allValues[0]);
        
        CGFloat abs = fabs(dhtouch.beginTimStamp-self.writingTimeStamp);
        NSLog(@"only .....%f",abs);
        
        if (![self isPalmTouch:dhtouch]) {
            return nil;
        }
        
        
//        if ((abs<BlueToothDelay)) {//
        
            ZJWBezierPath *lastPath = [self.paths lastObject];
            CGPoint lastPoint = lastPath.currentPoint;
            
            if (fabs(lastPath.endTimeStamp-dhtouch.beginTimStamp)<ContinueMaxTime) {
                NSLog(@"当前点与之前的点时间间隔太近了。。。。。:%f  %f",lastPath.endTimeStamp,dhtouch.beginTimStamp);
                if ([self distanceFrom:lastPoint toPoint:[[dhtouch.points lastObject] cgPoint]]<ContinueMaxDistance) {
                    NSLog(@"当前点与之前的点在特定距离之内。。。。");
                    return dhtouch;
                }
            }
            else {
                    //                NSLog(@"正常点位书写......");
                return dhtouch;
            }
            
            
//        }
//        else {
//            return dhtouch;
//        }
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
    
//    if (self.path.isWriting&&self.curDHTouch) {
//        return nil;
//    }
    
    
    int index = 0;
    
        //进行第一批筛选去掉时间区域外和掌控明显的
    NSMutableArray *realArray = [NSMutableArray array];
    for (DHTouch *t in self.holdTouches.allValues) {
        NSLog(@"%@ time:%f hash:%@",t.touch,t.beginTimStamp,@(t.hash));
        if ([self isPalmTouch:t]) {//(fabs(t.beginTimStamp-self.writingTimeStamp)<BlueToothDelay)&&
            
//            [realArray addObject:t];
            
            ZJWBezierPath *lastPath = [self.paths lastObject];
            CGPoint lastPoint = lastPath.currentPoint;
            
            
            if (fabs(lastPath.endTimeStamp-t.beginTimStamp)<ContinueMaxTime) {
                NSLog(@"当前点与之前的点时间间隔太近了。。。。。");
                if ([self distanceFrom:lastPoint toPoint:[[t.points lastObject] cgPoint]]<ContinueMaxDistance) {
                    NSLog(@"当前点与之前的点在特定距离之内。。。。");
                    [realArray addObject:t];
                }
            }
            else {
                NSLog(@"正常点位书写......");
                [realArray addObject:t];
            }
            
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
        NSLog(@"touch time:%f,%f writing:%f",first,second,self.writingTimeStamp);
        if (fabs(first-self.writingTimeStamp) < fabs(second-self.writingTimeStamp)) {
            
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
    }
    return ((DHTouch *)realArray[index]);
}

- (CGPoint)LMSalgorithm:(CGPoint)point {
    return CGPointZero;
}

@end
