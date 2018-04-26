//
//  ZJWCoverView.m
//  Draw
//
//  Created by ZJW on 2017/9/11.
//  Copyright © 2017年 ZJW. All rights reserved.
//

#import "ZJWCoverView.h"
#import "ZJWButton.h"
#define btnCount 7

// RGB颜色
#define RGBColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

// 随机色
#define ZJWRandomColor RGBColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))
@implementation ZJWCoverView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //创建按钮
        
        [self setButton];
    }
    
    return self;
}


//创建按钮
- (void)setButton
{
    //创建buton
    CGFloat coverW = self.frame.size.width;
    CGFloat margin = 10;
    CGFloat btnH = 30;
    CGFloat btnW = (coverW - margin * (btnCount + 1)) / btnCount;
    for (int i = 0; i < btnCount; i++) {
        ZJWButton *btn = [ZJWButton buttonWithType:UIButtonTypeCustom];
        //        btn.backgroundColor = []
        //设置颜色
        //        btn.backgroundColor = RandomColor;
//        [btn setImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateNormal];
//        [btn setImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateHighlighted];
//        [btn setBackgroundColor:ZJWRandomColor];
        [self addSubview:btn];
        
        CGFloat btnX = margin + (margin + btnW) * i;
        CGFloat btnY = 0 ;
        if (i == 0 || i ==6) {
            btnY = 80;
        }
        else if (i == 1 || i == 5 )
        {
            btnY = 50;
        }
        else if (i == 2 || i == 4)
        {
            btnY = 32;
        }
        else{
            btnY = 20;
        }
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        
        //btn的点击可以由控制器去监听
//        [btn addTarget:self action:@selector(btnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
}




@end
