//
//  ZJWDrawView.h
//  Draw
//
//  Created by ZJW on 2017/9/11.
//  Copyright © 2017年 ZJW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZJWDrawView;

@protocol ZJWDrawViewDelegate <NSObject>

@optional
- (void)drawBegan;
- (void)drawBeganAnimate;
- (void)drawEnd;
- (void)drawPoint:(CGPoint)point;

@end

@interface ZJWDrawView : UIView

@property (nonatomic, weak) id<ZJWDrawViewDelegate>delegte;


- (void)clear;

- (void)deleteLast;

- (void)lineWidthWithFloat:(CGFloat)width;

- (void)lineColorWithColor:(UIColor *)color;

- (void)erase;

//获取到新的图片
@property (nonatomic,strong)UIImage *image;


@end
