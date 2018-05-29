//
//  PathManager+Utility.m
//  Draw
//
//  Created by HuangPeng on 2018/5/29.
//  Copyright © 2018年 ZJW. All rights reserved.
//

#import "PathManager+Utility.h"

@implementation PathManager (Utility)

- (BOOL)mh_isNullOrNil:(id)obj {
    return !obj || [obj isKindOfClass:[NSNull class]];
    
}

- (NSTimeInterval)nowTimeStamp {
    NSProcessInfo *info = [NSProcessInfo processInfo];
    NSTimeInterval now = info.systemUptime;
    return now;
}

- (CGFloat)distanceFrom:(CGPoint)point1 toPoint:(CGPoint)point2 {
    return sqrtf((point1.x-point2.x)*(point1.x-point2.x)+(point1.y-point2.y)*(point1.y-point2.y));
}

- (BOOL)isPalmTouch:(DHTouch *)dhtouch {
    CGFloat cent = dhtouch.touch.majorRadius/dhtouch.touch.majorRadiusTolerance;
    if (cent<PalmRadius&&cent>PalmRadiusMin) {
        return YES;
    }
    else {
        return NO;
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

@end
