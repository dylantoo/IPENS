//
//  ZJWBezierPath.h
//  Draw
//
//  Created by ZJW on 2017/9/11.
//  Copyright © 2017年 ZJW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJWBezierPath : UIBezierPath

@property (nonatomic,strong) UIColor *pathColor;

//结束时的时间戳
@property (nonatomic) NSTimeInterval endTimeStamp;

//结束时点位
@property (nonatomic) CGPoint endPoint;

//是否正在书写
@property (nonatomic) BOOL isWriting;

@end
