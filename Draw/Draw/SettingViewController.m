//
//  SettingViewController.m
//  Draw
//
//  Created by ZJW on 2017/9/27.
//  Copyright © 2017年 ZJW. All rights reserved.
//

#import "SettingViewController.h"
#import "ZJWDrawView.h"
#import <Masonry/Masonry.h>

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define IS_IPAD      (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //是否是ipad

@interface SettingViewController ()<ZJWDrawViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) ZJWDrawView *drawView;
@property (strong, nonatomic) NSMutableArray *datas;
@property (strong, nonatomic) UILabel *pointLabel;
@property (nonatomic, strong) UITableView *myTableView;

@end

@implementation SettingViewController

#pragma mark    - lifecycle
-(NSMutableArray *)datas {
    if (_datas == nil) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"设置";
    
    [self.datas addObject:@"未连接蓝牙"];
    
    self.pointLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    self.pointLabel.textAlignment = NSTextAlignmentRight;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.pointLabel];
    
    UITableView *tableViewL = [[UITableView alloc] initWithFrame: CGRectZero
                                                           style: UITableViewStylePlain];
    tableViewL.delegate      = self;
    tableViewL.dataSource    = self;
    [tableViewL setBackgroundColor: [UIColor clearColor]];
    [tableViewL setSeparatorColor: [UIColor clearColor]];
    [tableViewL setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    [self.view addSubview: tableViewL];
    self.myTableView = tableViewL;
    
    [self.myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(64);
        make.height.mas_equalTo(105);
    }];
    
    self.drawView = [[ZJWDrawView alloc]init];
    self.drawView.delegte = self;
    [self.view addSubview:self.drawView];
    [self.drawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(self.myTableView.mas_bottom);
    }];
    
    WS(weakSelf)
    self.managerBluetoothTypeBlock = ^(BluetoothType type) {
        switch (type) {
            case BluetoothTypeSuccess: {
                [weakSelf.datas replaceObjectAtIndex:0 withObject:@"连接成功"];
            }
                break;
            case BluetoothTypeFail: {
                [weakSelf.datas replaceObjectAtIndex:0 withObject:@"连接失败"];
            }
                break;
            case BluetoothTypeDisconnect: {
                [weakSelf.datas removeAllObjects];
                [weakSelf.datas addObject:@"断开蓝牙"];
            }
                break;
                
            default:
                break;
        }
        [weakSelf.myTableView reloadData];
    };
    self.managerNotificationBlock = ^(IpenManager *ipenManager) {
        [weakSelf.datas removeAllObjects];
        [weakSelf.datas addObject:@"连接成功"];
//        NSMutableString *string = [NSMutableString stringWithString:@"touch: "];
//
//        NSMutableArray *touchDatas = [NSMutableArray array];
////            touchDatas = [NSMutableArray arrayWithObjects:@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1", nil];
//        [touchDatas addObjectsFromArray:[ipenManager getRawAdcData]];
//        [touchDatas addObjectsFromArray:[ipenManager getGsensorData]];
        [weakSelf.datas addObject:[NSString stringWithFormat:@"%d",[ipenManager getTouchState]]];
        [weakSelf.datas addObject:[NSString stringWithFormat:@"Xdata: %d",[ipenManager getXdata]]];
        [weakSelf.datas addObject:[NSString stringWithFormat:@"Ydata: %d",[ipenManager getYdata]]];
        [weakSelf.datas addObject:[NSString stringWithFormat:@"Zdata: %d",[ipenManager getZdata]]];
        [weakSelf.datas addObject:[NSString stringWithFormat:@"raw data: %d",[ipenManager getRawdata]]];
        [weakSelf.datas addObject:[NSString stringWithFormat:@"base data: %d",[ipenManager getBasedata]]];
        [weakSelf.datas addObject:[NSString stringWithFormat:@"HvState: %d",[ipenManager getHvState]]];

        //touch数组 12字节
//        for (int i = 0; i < touchDatas.count; i++) {
//            NSString *value = touchDatas[i];
//            [string appendFormat:@"%@,",value];
//            NSString * newString = [string substringWithRange:NSMakeRange(0, [string length] - 1)];
//
//            if (i == 0) {
//                [weakSelf.datas addObject:newString];
//                string = [NSMutableString stringWithString:@"Xdata: "];
//            }else if (i == 2) {
//                [weakSelf.datas addObject:newString];
//                string = [NSMutableString stringWithString:@"Ydata:"];
//            }else if (i == 4) {
//                [weakSelf.datas addObject:newString];
//                string = [NSMutableString stringWithString:@"Zdata: "];
//            }else if (i == 6) {
//                [weakSelf.datas addObject:newString];
//                string = [NSMutableString stringWithString:@"raw data: "];
//            }else if (i == 8) {
//                [weakSelf.datas addObject:newString];
//                string = [NSMutableString stringWithString:@"base data: "];
//            }else if (i == 10) {
//                [weakSelf.datas addObject:newString];
//                string = [NSMutableString stringWithString:@"HvState: "];
//            }else if (i == 11) {
//                [weakSelf.datas addObject:newString];
//            }
//        }
//            [weakSelf.datas addObject:[NSString stringWithFormat:@"电池电量：%d",1]];
//            [weakSelf.datas addObject:[NSString stringWithFormat:@"设备名称：%@",@"as"]];
//            [weakSelf.datas addObject:[NSString stringWithFormat:@"公司名称：%@",@"as"]];
//            [weakSelf.datas addObject:[NSString stringWithFormat:@"固件版本：%@",@"Xstar-System Co.mLtd."]];
//            [weakSelf.datas addObject:[NSString stringWithFormat:@"软件版本：%@",@"as"]];
    
        [weakSelf.datas addObject:[NSString stringWithFormat:@"电池电量：%d",[ipenManager getBatteryState]]];
        [weakSelf.datas addObject:[NSString stringWithFormat:@"设备名称：%@",[ipenManager getModel]]];
        [weakSelf.datas addObject:[NSString stringWithFormat:@"公司名称：%@",[ipenManager getManufacturer]]];
        [weakSelf.datas addObject:[NSString stringWithFormat:@"固件版本：%@",[ipenManager getFirmware]]];
        [weakSelf.datas addObject:[NSString stringWithFormat:@"软件版本：%@",[ipenManager getSoftware]]];
        [weakSelf.datas addObject:[NSString stringWithFormat:@"App版本：%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
        [weakSelf.myTableView reloadData];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark    - ZJWDrawViewDelegate
- (void)drawPoint:(CGPoint)point {
    CGPoint p = CGPointMake((int)point.x, (int)point.y);
    self.pointLabel.text = NSStringFromCGPoint(p);
}

#pragma mark    - UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.datas.count+1)/2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"BluetoothTypeCell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *title = [[UILabel alloc]init];
        title.tag = 100;
        title.textAlignment = NSTextAlignmentLeft;
        title.font = [UIFont systemFontOfSize:(IS_IPAD?16:10)];
        [cell.contentView addSubview:title];
        [title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.contentView).offset(30);
            make.centerY.equalTo(cell.contentView);
            make.width.mas_equalTo(IS_IPAD?280:180);
        }];
        
        UILabel *title1 = [[UILabel alloc]init];
        title1.tag = 101;
        title1.font = [UIFont systemFontOfSize:(IS_IPAD?16:10)];
        title1.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:title1];
        [title1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(cell.contentView).offset(100);
            make.centerY.equalTo(cell.contentView);
            make.width.mas_equalTo(IS_IPAD?280:180);
        }];
    }
    if (self.datas.count > indexPath.row*2) {
        NSString *value = self.datas[indexPath.row*2];
        ((UILabel *)[cell.contentView viewWithTag:100]).text = value;
    }
    if (self.datas.count > indexPath.row*2+1) {
        NSString *value1 = self.datas[(indexPath.row*2+1)];
        ((UILabel *)[cell.contentView viewWithTag:101]).text = value1;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
