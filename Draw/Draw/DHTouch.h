//
//  DHTouch.h
//  Draw
//
//  Created by HuangPeng on 2018/5/10.
//  Copyright © 2018年 ZJW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHPoint.h"

@interface DHTouch : NSObject

@property (nonatomic, strong) UITouch *touch;

/*
 begin时候的 timestamp
 */
@property (nonatomic) NSTimeInterval beginTimStamp;

/*
 结束时候的 timestamp   end or cancel
 */
@property (nonatomic) NSTimeInterval lastTimeStamp;

/*
 point  end or cancel
 */
@property (nonatomic) CGPoint lastPoint;

/*
 points array
 store DHPoint 
 */
@property (nonatomic, strong) NSMutableArray *points;

@end
