//
//  DHPoint.h
//  Draw
//
//  Created by HuangPeng on 2018/5/7.
//  Copyright © 2018年 ZJW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHPoint : UITouch

@property (nonatomic, strong) NSString *xValue;
@property (nonatomic, strong) NSString *yValue;

+ (DHPoint *)dhPointWithCGPoint:(CGPoint)point;
- (CGPoint)cgPoint;
- (NSString *)pointDescription;

@end
