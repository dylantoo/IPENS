//
//  ZJWDrawView.m
//  Draw
//
//  Created by ZJW on 2017/9/11.
//  Copyright © 2017年 ZJW. All rights reserved.
//

#import "ZJWDrawView.h"
#import "ZJWBezierPath.h"


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
@property (nonatomic,strong) NSMutableArray *paths;
@property (nonatomic,strong) NSMutableArray *connectPaths;//连接蓝牙后的轨迹
@property (nonatomic,strong) NSMutableArray *touchs;//touch=1后100ms的touch
@property (nonatomic, strong) UITouch *drawTouch;

@property (nonatomic,strong) ZJWBezierPath *path;

//用来存放path的线宽属性
@property (nonatomic,assign) CGFloat lineW;

@property (nonatomic,strong) UIColor *lineColor;

@end

@implementation ZJWDrawView

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

//懒加载
- (NSMutableArray *)paths
{
    if (!_paths) {
        _paths = [NSMutableArray array];
    }
    return _paths;
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

/**
 *  首先实现画线的功能，再慢慢完成其他功能
 */
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
    //初始化操作，画线需通过手势来完成，这里用pan手势来完成
//        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
//        pan.minimumNumberOfTouches = 1;
//        pan.maximumNumberOfTouches = 1;
//        [self addGestureRecognizer:pan];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
//    tap.numberOfTapsRequired = 1;
//    [self addGestureRecognizer:tap];
    
    //最开始不设置的话，一进来画线宽度为0；
    self.lineW = 2;
    self.lineColor = [UIColor blackColor];
}

- (void)tap:(UITapGestureRecognizer *)tap {
    
    if (self.isConnectBluetooth && self.toucheID == 1) {
        CGPoint curP = [tap locationInView:tap.view];
        if ([self.delegte respondsToSelector:@selector(drawPoint:)]) {
            [self.delegte drawPoint:curP];
        }
        ZJWBezierPath *path = [ZJWBezierPath bezierPath];
        
        [path moveToPoint:curP];
        path.lineCapStyle = kCGLineCapRound;
        path.lineJoinStyle = kCGLineJoinRound;
        path.pathColor = self.lineColor;
        path.lineWidth = self.lineW;
        
        self.path = path;
        [self.path addLineToPoint:curP];
        [self setNeedsDisplay];
        
        [self.paths addObject:self.path];
        if ([self.delegte respondsToSelector:@selector(drawEnd)]) {
            [self.delegte drawEnd];
        }

    }else {
        if (isDraw1) {
            return;
        }

        CGPoint curP = [tap locationInView:tap.view];
        if ([self.delegte respondsToSelector:@selector(drawPoint:)]) {
            [self.delegte drawPoint:curP];
        }
        ZJWBezierPath *path = [ZJWBezierPath bezierPath];
        
        [path moveToPoint:curP];
        path.lineCapStyle = kCGLineCapRound;
        path.lineJoinStyle = kCGLineJoinRound;
        path.pathColor = self.lineColor;
        path.lineWidth = self.lineW;
        
        self.path = path;
        [self.path addLineToPoint:curP];
        [self setNeedsDisplay];
        
        [self.paths addObject:self.path];
        if ([self.delegte respondsToSelector:@selector(drawEnd)]) {
            [self.delegte drawEnd];
        }
    }
}

//- (void)pan:(UIPanGestureRecognizer *)pan
//{
//    CGPoint curP = [pan locationInView:pan.view];
//    if ([self.delegte respondsToSelector:@selector(drawPoint:)]) {
//        [self.delegte drawPoint:curP];
//    }
//
//    if (self.isConnectBluetooth) {
//        //通过贝塞尔曲线来画图
//        if (pan.state == UIGestureRecognizerStateBegan) {
//            ZJWBezierPath *path = [ZJWBezierPath bezierPath];
//
//            //path创建好后，就可以设置其线宽，颜色等属性
//            [path moveToPoint:curP];
//            path.lineCapStyle = kCGLineCapRound;
//            path.lineJoinStyle = kCGLineJoinRound;
//            path.pathColor = self.lineColor;
//            path.lineWidth = self.lineW;
//
//            self.path = path;
//            isBeginConnect = NO;
//            if (self.toucheID == 1) {
//                isBeginConnect = YES;
//                [self.paths addObject:self.path];
//                beginDate = [NSDate date];
//                if ([self.delegte respondsToSelector:@selector(drawBegan)]) {
//                    [self.delegte drawBegan];
//                }
//            }else {
//                [self.connectPaths addObject:self.path];
//            }
//
//        } else if (pan.state == UIGestureRecognizerStateChanged) {
//            if (beginDate != nil) {
//                NSDate *changeDate = [NSDate date];
//                NSTimeInterval interval = [changeDate timeIntervalSinceDate:beginDate];
//                if (interval > 0.3) {
//                    beginDate = nil;
//                    if ([self.delegte respondsToSelector:@selector(drawBeganAnimate)]) {
//                        [self.delegte drawBeganAnimate];
//                    }
//                }
//            }
//            if (self.connectPaths.count > 0) {
//                isDrawConnectLast = YES;
//            }
//            [self.path addLineToPoint:curP];
//            //每次拖动都需要重绘
//            [self setNeedsDisplay];
//
//        } else if (pan.state == UIGestureRecognizerStateEnded) {
//            [self.connectPaths removeAllObjects];
//            endDate = [NSDate date];
//            if (beginDate == nil) {
//                if ([self.delegte respondsToSelector:@selector(drawEnd)]) {
//                    [self.delegte drawEnd];
//                }
//            }
//        }
//    }else {
//        //通过贝塞尔曲线来画图
//        NSLog(@"%@   %@",NSStringFromCGPoint(curP),pan);
//
//        if (pan.state == UIGestureRecognizerStateBegan) {
//
//            ZJWBezierPath *path = [ZJWBezierPath bezierPath];
//
//            //path创建好后，就可以设置其线宽，颜色等属性
//            [path moveToPoint:curP];
//            path.lineCapStyle = kCGLineCapRound;
//            path.lineJoinStyle = kCGLineJoinRound;
//            path.pathColor = self.lineColor;
//            path.lineWidth = self.lineW;
//
//            self.path = path;
//
//            [self.paths addObject:self.path];
//
//            beginDate = [NSDate date];
//            if ([self.delegte respondsToSelector:@selector(drawBegan)]) {
//                [self.delegte drawBegan];
//            }
//        } else if (pan.state == UIGestureRecognizerStateChanged) {
//            if (beginDate != nil) {
//                NSDate *changeDate = [NSDate date];
//                NSTimeInterval interval = [changeDate timeIntervalSinceDate:beginDate];
//                if (interval > 0.3) {
//                    beginDate = nil;
//                    if ([self.delegte respondsToSelector:@selector(drawBeganAnimate)]) {
//                        [self.delegte drawBeganAnimate];
//                    }
//                }
//            }
//            [self.path addLineToPoint:curP];
//            //每次拖动都需要重绘
//            [self setNeedsDisplay];
//
//        } else if (pan.state == UIGestureRecognizerStateEnded) {
//            endDate = [NSDate date];
//            if (beginDate == nil) {
//                if ([self.delegte respondsToSelector:@selector(drawEnd)]) {
//                    [self.delegte drawEnd];
//                }
//            }
//        }
//    }
//
//}

-(BOOL)isHavePath {
    return self.paths.count > 0;
}

//清除
- (void)clear
{
    [self.paths removeAllObjects];
    [self setNeedsDisplay];
}

//撤销
- (void)deleteLast
{
    [self.paths removeLastObject];
    [self setNeedsDisplay];
}

- (void)deleteAll
{
    [self.paths removeAllObjects];
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

- (void)drawRect:(CGRect)rect
{
//    NSLog(@"drawPath:%@",self.paths);
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

//重写newImage方法进行传值
- (void)setImage:(UIImage *)image
{
    _image = image;
    
    [self.paths addObject:image];
    
    [self setNeedsDisplay];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (isDraw1 == YES) {
        return;
    }
    NSLog(@"began");

    NSSet *allTouches = [event allTouches];
    NSArray *arr = [allTouches allObjects];
    
    
    if (_isConnectBluetooth && self.toucheID == 1) {
        BOOL isHaveTouch = NO;
        for (UITouch *touch in arr) {
            if ([touch isEqual:self.drawTouch]) {
                isHaveTouch = YES;
                NSLog(@"============>>>>>>>>have touch");
            }
        }
        
        if (isHaveTouch) {
            return;
        }
    }
    
    
    
    
//    NSLog(@"touchs  arr:%@",arr);
    self.drawTouch = arr[0];
//    NSLog(@"%@",self.drawTouch);
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
            [self.touchs addObjectsFromArray:arr];
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
            [self.touchs removeAllObjects];
            [self.connectPaths addObject:self.path];
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
    BOOL isHaveTouch = NO;
    NSArray *arr = [touches allObjects];
    for (UITouch *touch in arr) {
        if ([touch isEqual:self.drawTouch]) {
            isHaveTouch = YES;
        }
    }
    if (isHaveTouch == NO) {
        return;
    }
    if (self.drawTouch == nil) {
        return;
    }
    NSLog(@"Moved");

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
        isDraw1 = YES;
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
    NSArray *arr = [touches allObjects];
    for (UITouch *touch in arr) {
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
    }
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
    //每次拖动都需要重绘
    [self setNeedsDisplay];

    isDraw = YES;
}

@end
