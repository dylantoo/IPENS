//
//  PathManager+Utility.h
//  Draw
//
//  Created by HuangPeng on 2018/5/29.
//  Copyright © 2018年 ZJW. All rights reserved.
//

#import "PathManager.h"

@interface PathManager (Utility)

- (BOOL)mh_isNullOrNil:(id)obj;

- (NSTimeInterval)nowTimeStamp;

- (CGFloat)distanceFrom:(CGPoint)point1 toPoint:(CGPoint)point2;

@end
