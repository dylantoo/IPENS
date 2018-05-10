//
//  ZJWDrawView.m
//  Draw
//
//  Created by ZJW on 2017/9/11.
//  Copyright © 2017年 ZJW. All rights reserved.
//

#import "ZJWDrawView.h"
#import "ZJWBezierPath.h"
#import "PathManager.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface ZJWDrawView () 
{

}

@end

@implementation ZJWDrawView

#pragma mark - Life
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupView];
}

-(void)setupView {
    self.multipleTouchEnabled = YES;
        //设置画板颜色
    self.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];

}

#pragma mark - Property





#pragma mark - Operation

//清除
- (void)clear
{
    [PATHMANAGER.paths removeAllObjects];
    [self setNeedsDisplay];
}

//撤销
- (void)deleteLast
{
    [PATHMANAGER.paths removeLastObject];
    [self setNeedsDisplay];
}

//设置线宽
- (void)lineWidthWithFloat:(CGFloat)width
{
    
}

//设置颜色
- (void)lineColorWithColor:(UIColor *)color
{
    
}

//橡皮擦
- (void)erase
{
    [self lineColorWithColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
}

#pragma mark - Core
- (void)drawRect:(CGRect)rect
{
    for (ZJWBezierPath *path in PATHMANAGER.paths) {
        if ([path isKindOfClass:[UIImage class]]) {
            UIImage *image = (UIImage *)path;
            [image drawInRect:rect];
        }
        else{
            [path.pathColor set];
            [path stroke];
        }
    }
}



#pragma mark - Touch Events

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesBegan.........:%@",event);

    NSSet *allTouches = [event allTouches];
    NSArray *arr = [allTouches allObjects];
    
    [PATHMANAGER touchesBegin:arr];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"Moved");
    NSArray *arr = [touches allObjects];
    [PATHMANAGER touchesMove:arr];
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touche.....endddddddddddddddd:%@",touches);
    [PATHMANAGER touchesEnded:[touches allObjects]];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"==========>>>>>>>>>>>>>>>>>>>>>>>Cancelled:%@",event);
    [PATHMANAGER touchesCancel:[touches allObjects]];
}

@end
