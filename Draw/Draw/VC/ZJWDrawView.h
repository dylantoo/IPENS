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
@property (nonatomic, assign, readonly) BOOL isHavePath;//是否有画图路径
@property (nonatomic, assign) BOOL isConnectBluetooth;//是否链接蓝牙
@property (nonatomic, assign) NSInteger toucheID;//0 没有再屏幕上 1 在屏幕上

//存储绘制的path
@property (nonatomic,strong) NSMutableArray *paths;

- (void)clear;

- (void)deleteLast;

- (void)lineWidthWithFloat:(CGFloat)width;

- (void)lineColorWithColor:(UIColor *)color;

- (void)erase;

//获取到新的图片
@property (nonatomic,strong)UIImage *image;


@end
