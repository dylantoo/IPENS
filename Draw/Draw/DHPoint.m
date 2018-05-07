//
//  DHPoint.m
//  Draw
//
//  Created by HuangPeng on 2018/5/7.
//  Copyright © 2018年 ZJW. All rights reserved.
//

#import "DHPoint.h"

@implementation DHPoint

+ (DHPoint *)dhPointWithCGPoint:(CGPoint)point {
    DHPoint *dh = [[DHPoint alloc] init];
    dh.xValue = [NSString stringWithFormat:@"%f",point.x];
    dh.yValue = [NSString stringWithFormat:@"%f",point.y];
    return dh;
}

- (CGPoint)cgPoint {
    return CGPointMake(self.xValue.floatValue, self.yValue.floatValue);
}

- (NSString *)pointDescription {
   return [NSString stringWithFormat:@"pointDescription:%f,%f",self.xValue.floatValue,self.yValue.floatValue];
}

@end
