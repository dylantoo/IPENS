//
//  ZJWButton.m
//  Draw
//
//  Created by ZJW on 2017/9/11.
//  Copyright © 2017年 ZJW. All rights reserved.
//

#import "ZJWButton.h"

// RGB颜色
#define RGBColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

// 随机色
#define ZJWRandomColor RGBColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

@implementation ZJWButton


//往button里绘制圆形的颜色
- (void)drawRect:(CGRect)rect {
    // Drawing code
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    self.btnColor = ZJWRandomColor;
    [self.btnColor set];
    [path fill];
    
}



@end
