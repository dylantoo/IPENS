//
//  DHTouch.m
//  Draw
//
//  Created by HuangPeng on 2018/5/10.
//  Copyright © 2018年 ZJW. All rights reserved.
//

#import "DHTouch.h"

@implementation DHTouch

- (NSMutableArray *)points {
    if (!_points) {
        _points = [[NSMutableArray alloc] init];
    }
    return _points;
}

@end
