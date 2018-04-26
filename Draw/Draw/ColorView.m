//
//  ColorView.m
//  Draw
//
//  Created by ZJW on 2017/9/11.
//  Copyright © 2017年 ZJW. All rights reserved.
//

#import "ColorView.h"
#import <Masonry/Masonry.h>
#import "UIColor+HexColor.h"

@interface ColorView()

@property (nonatomic, strong) NSArray *colors;
@end


@implementation ColorView

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (NSArray *)colors {
    if (_colors == nil) {
        return @[[UIColor colorWithHex:0xB0171F],[UIColor colorWithHex:0xE3170D],[UIColor colorWithHex:0xFF0000],[UIColor colorWithHex:0xFA8072],[UIColor colorWithHex:0xFF8000],[UIColor colorWithHex:0xFFD700],[UIColor colorWithHex:0xFFFF00],[UIColor colorWithHex:0xFF7F50],[UIColor colorWithHex:0xFF6100],[UIColor colorWithHex:0xF0E68C],[UIColor colorWithHex:0x87CEEB],[UIColor colorWithHex:0xD2691E],[UIColor colorWithHex:0xBDFCC9],[UIColor colorWithHex:0x00FF00],[UIColor colorWithHex:0x00C957],[UIColor colorWithHex:0x228B22],[UIColor colorWithHex:0xB0E0E6],[UIColor colorWithHex:0x1E90FF],[UIColor colorWithHex:0x0000FF],[UIColor colorWithHex:0x00C78C],[UIColor colorWithHex:0x191970],[UIColor colorWithHex:0x9933FA],[UIColor colorWithHex:0xA066D3],[UIColor colorWithHex:0xA020F0],[UIColor colorWithHex:0xDDA0DD],[UIColor colorWithHex:0xFFC0CB],[UIColor colorWithHex:0xFAF0E6],[UIColor colorWithHex:0xFFFFCD],[UIColor colorWithHex:0x292421],[UIColor colorWithHex:0x808A87],[UIColor colorWithHex:0xFFFFFF],[UIColor colorWithHex:0x000000]];
    }
    return _colors;
}

- (void)setupView {
    self.backgroundColor = [UIColor colorWithHex:0x292421];
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    for (int i = 0; i < self.colors.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = self.colors[i];
        btn.tag = 100+i;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.left.right.equalTo(self);
            make.height.mas_equalTo(ColorViewWidth);
            make.top.mas_equalTo(i*ColorViewWidth);
            if (i == self.colors.count-1) {
                make.bottom.equalTo(self);
            }
        }];
    }
}

- (void)btnClick:(UIButton *)sender {
    if (self.colorBlock) {
        self.colorBlock(self.colors[sender.tag-100]);
    }
}

@end
