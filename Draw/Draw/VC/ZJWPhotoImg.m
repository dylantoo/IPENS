//
//  ZJWPhotoImg.m
//  Draw
//
//  Created by ZJW on 2017/9/11.
//  Copyright © 2017年 ZJW. All rights reserved.
//

#import "ZJWPhotoImg.h"


@interface ZJWPhotoImg () <UIGestureRecognizerDelegate>

@property  (nonatomic,weak) UIImageView *imageV;

@end

@implementation ZJWPhotoImg

- (UIImageView *)imageV
{
    if (!_imageV) {
        UIImageView *imageV = [[UIImageView alloc]initWithFrame:self.bounds];
        imageV.backgroundColor = [UIColor purpleColor];
        imageV.userInteractionEnabled = YES;
        [self addSubview:imageV];
        _imageV = imageV;
    }
    
    return _imageV;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    //初始化设置
    [self setUp];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    
    return self;
}


//初始化设置
- (void)setUp
{
    //设置自己为透明色
    self.backgroundColor = [UIColor clearColor];
    
    //添加手势
    [self addGestureRecognizer];
    

}

//添加手势
- (void)addGestureRecognizer
{
    //添加手势,拖拽
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [self.imageV addGestureRecognizer:pan];
    
    //捏合
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinch:)];
    pinch.delegate = self;
    [self.imageV addGestureRecognizer:pinch];
    
    //旋转
    UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotate:)];
    rotate.delegate = self;
    [self.imageV addGestureRecognizer:rotate];
    
}


//处理捏合手势
- (void)pinch:(UIPinchGestureRecognizer  *)pinch
{
    CGFloat scale = pinch.scale;
    self.imageV.transform = CGAffineTransformScale(self.imageV.transform, scale, scale);
    
    //每次形变之后都要复位
    pinch.scale = 1;
}

//处理拖拽手势
- (void)pan:(UIPanGestureRecognizer *)pan
{
    CGPoint offSet = [pan translationInView:pan.view];
    self.imageV.transform = CGAffineTransformTranslate(self.imageV.transform, offSet.x, offSet.y);
    
    [pan setTranslation:CGPointZero inView:pan.view];
}

//处理旋转手势
- (void)rotate:(UIRotationGestureRecognizer *)rotate
{
    self.imageV.transform = CGAffineTransformRotate(self.imageV.transform, rotate.rotation) ;
    
    rotate.rotation = 0;
                         
}

-(void)drawImage {
    
    //开启位图上下文，将图片渲染到位图上下文
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self.layer  renderInContext:ctx];
    
    UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    //获取到图片后，要想画到画板上，需要将得到的图片传给drawView,这里用代理传；
    if ([self.delegte respondsToSelector:@selector(photoImg:withImage:)]) {
        [self.delegte photoImg:self withImage:newImg];
    }
    
    //移除
    [self removeFromSuperview];
}


//是否允许多个手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{

    return YES;
}



//重写set方法用来外界传值
- (void)setImage:(UIImage *)image
{
    _image = image;
    
    //外界给我传一张图片就可以显示出来了
    self.imageV.image = image;
}

@end

