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
    
    
        //进行第一批筛选去掉时间区域外和掌控明显的
    NSMutableArray *realArray = [NSMutableArray array];
    for (DHTouch *t in self.holdTouches.allValues) {
        NSLog(@"%@ time:%f hash:%@",t.touch,t.beginTimStamp,@(t.hash));
        if ((fabs(t.beginTimStamp-self.writingTimeStamp)<BlueToothDelay)&&self.writingTimeStamp>0&&[self isPalmTouch:t]) {
            NSLog(@"初步条件筛选成功");
            if (self.paths.count == 0) {
                [realArray addObject:t];
                break;
            }
            
            if (self.holdTouches.count==1) {
                [realArray addObject:t];
                break;
            }
            
            ZJWBezierPath *lastPath = [self.paths lastObject];
            CGPoint lastPoint = lastPath.currentPoint;
            CGFloat fabsinteval = fabs(lastPath.endTimeStamp-t.beginTimStamp);
            NSLog(@"两笔之间间隔的时间：%f",fabsinteval);
            
            
            
            if (fabsinteval<ContinueMaxTime) {
                NSLog(@"当前点与之前的点时间间隔太近了。。。。。");
                if ([self distanceFrom:lastPoint toPoint:[[t.points firstObject] cgPoint]]<ContinueMaxDistance) {
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
    
    NSLog(@"初步筛选符合条件的点位还剩下:%d",realArray.count);
    
    int index = 0;
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
            NSLog(@"时间相同 左撇子靠左的点");
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


/**
 根据蓝牙笔触上报时间距离最近的为 currentTouch
 */



@end
