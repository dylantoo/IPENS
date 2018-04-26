//
//  CoreBluetoothViewController.m
//  Draw
//
//  Created by ZJW on 2017/9/18.
//  Copyright © 2017年 ZJW. All rights reserved.
//

#import "CoreBluetoothViewController.h"
#import <Masonry/Masonry.h>

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface CoreBluetoothViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) IpenManager *ipenManager;
@property (nonatomic, copy) NSArray *datas;

@end

@implementation CoreBluetoothViewController

#pragma mark    - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self setupCoreBluetooth];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark    - setupView
- (void)setupView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"查找蓝牙设备";
    
    UITableView *tableViewL = [[UITableView alloc] initWithFrame: CGRectZero
                                                           style: UITableViewStyleGrouped];
    tableViewL.delegate      = self;
    tableViewL.dataSource    = self;
    [tableViewL setBackgroundColor: [UIColor clearColor]];
    [tableViewL setSeparatorColor: [UIColor clearColor]];
    [tableViewL setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    [self.view addSubview: tableViewL];
    self.myTableView = tableViewL;
    
    [self.myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];

}

#pragma mark    - setupCoreBluetooth
- (void)setupCoreBluetooth {
    self.ipenManager = [IpenManager new];
    [self.ipenManager startDeviceDiscovery];
    WS(weakSelf)
    [self.ipenManager getDevices:^(NSArray *devices) {
        weakSelf.datas = devices;
        [weakSelf.myTableView reloadData];
    }];
}

#pragma mark    - UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.datas.count == 0) {
        return 1;
    }else {
        return self.datas.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CoreBluetoothCell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (self.datas.count == 0) {
        cell.textLabel.text = @"正在搜索设备";
    }else {
        if (self.datas.count > indexPath.row) {
            CBPeripheral *peripheral = self.datas[indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"蓝牙设备名称:%@",peripheral.name];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.datas.count <= indexPath.row) return;
    CBPeripheral *peripheral = self.datas[indexPath.row];
    
    self.peripheral = peripheral;
    if (self.linkBlock) {
        self.linkBlock(peripheral,self.ipenManager);
    }
    [self.navigationController popViewControllerAnimated:YES];

}



@end
