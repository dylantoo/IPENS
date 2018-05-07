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
    NSDate *beginDate;
    NSDate *endDate;
    BOOL isDrawConnectLast;//是否连接后画上次的线；
    BOOL isTimeDate;//是否正在time延迟中
    BOOL isDraw;//是否画线；
    
    
    
    //多点触碰
    BOOL isDraw1;//是否画线；

}

@property (nonatomic,strong) NSMutableArray *connectPaths;//连接蓝牙后的轨迹
@property (nonatomic,strong) NSMutableArray *touchs;//touch=1后100ms的touch
@property (nonatomic, strong) UITouch *drawTouch;

@property (nonatomic,strong) ZJWBezierPath *path;

//用来存放path的线宽属性
@property (nonatomic,assign) CGFloat lineW;

@property (nonatomic,strong) UIColor *lineColor;


@property (nonatomic, strong) PathManager *pathManager;;

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
    isDraw = YES;
    self.multipleTouchEnabled = YES;
        //设置画板颜色
    self.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
    
    
        //最开始不设置的话，一进来画线宽度为0；
    self.lineW = 2;
    self.lineColor = [UIColor blackColor];
}

#pragma mark - Property

- (PathManager *)pathManager {
    if (_pathManager) {
        _pathManager = [[PathManager alloc] init];
    }
    return _pathManager;
}

- (NSMutableArray *)connectPaths
{
    if (!_connectPaths) {
        _connectPaths = [NSMutableArray array];
    }
    return _connectPaths;
}
- (NSMutableArray *)touchs
{
    if (!_touchs) {
        _touchs = [NSMutableArray array];
    }
    return _touchs;
}

- (void)setPaths:(NSMutableArray *)paths {
    if (!self.paths) {
        self.paths = [NSMutableArray array];
    }
    [self.paths addObjectsFromArray:paths];
    [self setNeedsDisplay];
}

-(BOOL)isHavePath {
    return self.paths.count > 0;
}


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
    self.lineW = width;
}

//设置颜色
- (void)lineColorWithColor:(UIColor *)color
{
    self.lineColor = color;
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
    
    return;
    
    
    if (self.isConnectBluetooth) {
        for (ZJWBezierPath *path in self.paths) {
            if ([path isKindOfClass:[UIImage class]]) {
                UIImage *image = (UIImage *)path;
                [image drawInRect:rect];
            }
            else{
                [path.pathColor set];
                [path stroke];
            }
        }
        if (self.toucheID == 1) {
            if (isDrawConnectLast) {
                isDrawConnectLast = NO;
                if (self.connectPaths.count > 0) {
                    ZJWBezierPath *path = self.connectPaths.lastObject;
                    [self.paths addObject:path];
                    if ([path isKindOfClass:[UIImage class]]) {
                        UIImage *image = (UIImage *)path;
                        [image drawInRect:rect];
                    }
                    else{
                        [path.pathColor set];
                        [path stroke];
                    }
                    [self.connectPaths removeAllObjects];
                }
            }
        }
    }else {
        for (ZJWBezierPath *path in self.paths) {
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
}



#pragma mark - Touch Events

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesBegan.........");

    NSSet *allTouches = [event allTouches];
    NSArray *arr = [allTouches allObjects];
    
    if (arr.count>1) {
        //右手书写习惯 取最左点
        
        UITouch *finalTouch = nil;
        for (int i = 0; i < arr.count-1; i++) {
            UITouch *x = arr[i];
            CGPoint point = [x locationInView:[x view]];
            
            UITouch *x1 = arr[i+1];
            CGPoint point1 = [x1 locationInView:[x1 view]];
            
            if (point.y > point1.y) {
                
                finalTouch = x1;
            }else {
                
                finalTouch = x;
            }
        }
//        PATHMANAGER.comingTouch = finalTouch;
        [PATHMANAGER setComingTouchWithBuffer:finalTouch];
        
    }
    else {
//        PATHMANAGER.comingTouch = arr[0];
        [PATHMANAGER setComingTouchWithBuffer:arr[0]];
    }
    
    
    
    return;
    
    
    if (isDraw1 == YES) {
        return;
    }
    NSLog(@"began");

    
    
    
    if (_isConnectBluetooth && self.toucheID == 1) {
        NSLog(@"is connetcttt.t.... blue tooth");
        BOOL isHaveTouch = NO;
        for (UITouch *touch in arr) {
            if ([touch isEqual:self.drawTouch]) {
                isHaveTouch = YES;
                NSLog(@"============>>>>>>>>have touch");
            }
        }
        
        if (isHaveTouch) {
            NSLog(@"connet return");
            return;
        }
    }
    
    if (!_isConnectBluetooth) {
        self.drawTouch = arr[0];
            //    NSLog(@"%@",self.drawTouch);
        if (arr.count > 1) {
            for (int i = 0; i < arr.count-1; i++) {
                UITouch *x = arr[i];
                CGPoint point = [x locationInView:[x view]];
                
                UITouch *x1 = arr[i+1];
                CGPoint point1 = [x1 locationInView:[x1 view]];
                
                if (point.y > point1.y) {
                    NSLog(@"touch drwoafadfaf:%@",x1);
                    self.drawTouch = x1;
                }else {
                    NSLog(@"touch dasfdsafdaslewree:%@",x);
                    self.drawTouch = x;
                }
            }
        }
    }
    
    CGPoint curP = [self.drawTouch locationInView:[self.drawTouch view]];
    if ([self.delegte respondsToSelector:@selector(drawPoint:)]) {
        [self.delegte drawPoint:curP];
    }

    if (self.isConnectBluetooth) {
        NSLog(@"isConnectBluetooth...");
        //通过贝塞尔曲线来画图
        ZJWBezierPath *path = [ZJWBezierPath bezierPath];

        //path创建好后，就可以设置其线宽，颜色等属性
        [path moveToPoint:curP];
        path.lineCapStyle = kCGLineCapRound;
        path.lineJoinStyle = kCGLineJoinRound;
        path.pathColor = self.lineColor;
        path.lineWidth = self.lineW;

        self.path = path;
//        isBeginConnect = NO;
        if (self.toucheID == 1) {
            NSLog(@"....touch id");
//            self.drawTouch = nil;
            [self.connectPaths addObjectsFromArray:self.paths];
            [self touchTime:nil];
//            if (isTimeDate == NO) {
//                isTimeDate = YES;
//                NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(touchTime:) userInfo:nil repeats:NO];
//                isDraw = NO;
//                [[NSRunLoop currentRunLoop] addTimer: timer forMode: NSRunLoopCommonModes];
//            }

//            isBeginConnect = YES;
//            [self.paths addObject:self.path];
//            beginDate = [NSDate date];
//            if ([self.delegte respondsToSelector:@selector(drawBegan)]) {
//                [self.delegte drawBegan];
//            }
        }else {
//            [self.touchs removeAllObjects];
//            [self.connectPaths addObject:self.path];
            
            
            
        }
    }else {
        ZJWBezierPath *path = [ZJWBezierPath bezierPath];

        //path创建好后，就可以设置其线宽，颜色等属性
        [path moveToPoint:curP];
        path.lineCapStyle = kCGLineCapRound;
        path.lineJoinStyle = kCGLineJoinRound;
        path.pathColor = self.lineColor;
        path.lineWidth = self.lineW;

        self.path = path;

        [self.paths addObject:self.path];

        beginDate = [NSDate date];
        if ([self.delegte respondsToSelector:@selector(drawBegan)]) {
            [self.delegte drawBegan];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"Moved");
    
    
    
    
    
    NSArray *arr = [touches allObjects];
    
    if (arr.count>1) {
            //右手书写习惯 取最左点
        
        UITouch *finalTouch = nil;
        for (int i = 0; i < arr.count-1; i++) {
            UITouch *x = arr[i];
            CGPoint point = [x locationInView:[x view]];
            
            UITouch *x1 = arr[i+1];
            CGPoint point1 = [x1 locationInView:[x1 view]];
            
            if (point.y > point1.y) {
                
                finalTouch = x1;
            }else {
                
                finalTouch = x;
            }
        }
        PATHMANAGER.comingTouch = finalTouch;
        
    }
    else {
        PATHMANAGER.comingTouch = arr[0];
    }
    
    [self setNeedsDisplay];
    return;
    for (UITouch *touch in arr) {
        if ([touch isEqual:PATHMANAGER.currentTouch]) {
            PATHMANAGER.comingTouch = touch;
        }
    }
    
    [self setNeedsDisplay];
    
    return;
    
    
    BOOL isHaveTouch = NO;
    isHaveTouch = YES;
    
    if (isHaveTouch == NO) {
        return;
    }
    if (self.drawTouch == nil) {
        return;
    }
    

    CGPoint curP = [self.drawTouch locationInView:[self.drawTouch view]];

    if (self.isConnectBluetooth) {
        
        if (self.toucheID == 1) {
            if (isDraw) {
                if (beginDate != nil) {
                    NSDate *changeDate = [NSDate date];
                    NSTimeInterval interval = [changeDate timeIntervalSinceDate:beginDate];
                    if (interval > 0.3) {
                        beginDate = nil;
                        if ([self.delegte respondsToSelector:@selector(drawBeganAnimate)]) {
                            [self.delegte drawBeganAnimate];
                        }
                    }
                }
                if (self.connectPaths.count > 0) {
                    isDrawConnectLast = YES;
                }
                [self.path addLineToPoint:curP];
                //每次拖动都需要重绘
                [self setNeedsDisplay];
            }
        }

    }else {
//        isDraw1 = YES;
        if (beginDate != nil) {
            NSDate *changeDate = [NSDate date];
            NSTimeInterval interval = [changeDate timeIntervalSinceDate:beginDate];
            if (interval > 0.3) {
                beginDate = nil;
                if ([self.delegte respondsToSelector:@selector(drawBeganAnimate)]) {
                    [self.delegte drawBeganAnimate];
                }
            }
        }
        [self.path addLineToPoint:curP];
        //每次拖动都需要重绘
        [self setNeedsDisplay];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    PATHMANAGER.comingTouch = nil;
    
//    NSArray *arr = [touches allObjects];
//    for (UITouch *touch in arr) {
//        if ([touch isEqual:PATHMANAGER.currentTouch]) {
//
//        }
//
//    }
    
    return;
        
        /*
        if ([self.touchs containsObject:touch]) {
            [self.touchs removeObject:touch];
        }
        if ([touch isEqual:self.drawTouch]) {
            NSLog(@"Ended");
            
            isTimeDate = NO;
            self.drawTouch = nil;
            isDraw1 = NO;
            
            if (self.isConnectBluetooth) {
                [self.connectPaths removeAllObjects];
            }
            endDate = [NSDate date];
            if (beginDate == nil) {
                if ([self.delegte respondsToSelector:@selector(drawEnd)]) {
                    [self.delegte drawEnd];
                }
            }
            
            break;
        }
         */
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"==========>>>>>>>>>>>>>>>>>>>>>>>Cancelled");
}

- (void)touchTime:(NSTimer *)timer {
    
    NSLog(@"draw touch:%@",self.drawTouch);
    NSArray *arr = self.touchs;
    if (self.isConnectBluetooth && self.toucheID == 1) {
        
    }
    else {
        self.drawTouch = arr[0];
        if (arr.count > 1) {
            for (int i = 0; i < arr.count-1; i++) {
                UITouch *x = arr[i];
                CGPoint point = [x locationInView:[x view]];
                
                UITouch *x1 = arr[i+1];
                CGPoint point1 = [x1 locationInView:[x1 view]];
                if (point.y > point1.y) {
                    self.drawTouch = x1;
                }else {
                    self.drawTouch = x;
                }
            }
        }
    }
    NSLog(@"draw sss touch:%@",self.drawTouch);
    CGPoint curP = [self.drawTouch locationInView:[self.drawTouch view]];

    ZJWBezierPath *path = [ZJWBezierPath bezierPath];

    //path创建好后，就可以设置其线宽，颜色等属性
    [path moveToPoint:curP];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    path.pathColor = self.lineColor;
    path.lineWidth = self.lineW;

    self.path = path;
    [self.paths addObject:self.path];

    //通过贝塞尔曲线来画图
    if (beginDate != nil) {
        NSDate *changeDate = [NSDate date];
        NSTimeInterval interval = [changeDate timeIntervalSinceDate:beginDate];
        if (interval > 0.3) {
            beginDate = nil;
            if ([self.delegte respondsToSelector:@selector(drawBeganAnimate)]) {
                [self.delegte drawBeganAnimate];
            }
        }
    }
    if (self.connectPaths.count > 0) {
        isDrawConnectLast = YES;
    }
    [self.path addLineToPoint:curP];
    //每次拖动都需要重绘,出发drawRect
    [self setNeedsDisplay];

    isDraw = YES;
}

@end
