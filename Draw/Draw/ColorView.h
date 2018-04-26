//
//  ColorView.h
//  Draw
//
//  Created by ZJW on 2017/9/11.
//  Copyright © 2017年 ZJW. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //是否是ipad
#define ColorViewWidth (IS_IPAD?50:25)

typedef void(^ColorBlock)(UIColor *color);

@interface ColorView : UIScrollView

@property (nonatomic, copy) ColorBlock colorBlock;

- (void)setupView;

@end
