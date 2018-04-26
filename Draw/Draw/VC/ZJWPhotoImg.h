//
//  ZJWPhotoImg.h
//  Draw
//
//  Created by ZJW on 2017/9/11.
//  Copyright © 2017年 ZJW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZJWPhotoImg;

@protocol ZJWPhotoImgDelegate <NSObject>

@optional
- (void)photoImg:(ZJWPhotoImg *)phohoImg withImage:(UIImage *)image;

@end

@interface ZJWPhotoImg : UIView

@property (nonatomic,strong)UIImage *image;
@property (nonatomic,weak)id<ZJWPhotoImgDelegate>delegte;

-(void)drawImage;

@end
