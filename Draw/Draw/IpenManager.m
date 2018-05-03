//
//  IpenManager.m
//  IpenManager
//
//  Created by ZJW on 2017/9/18.
//  Copyright © 2017年 ZJW. All rights reserved.
//

#import "IpenManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define ALERT(title,msg) [[[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show]

@interface IpenManager ()<CBCentralManagerDelegate, CBPeripheralDelegate>
{
    BOOL isStartSearchDevice;
}
@property (nonatomic, strong) CBCentralManager *cMgr;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, strong) NSMutableArray *nServices;
@property (nonatomic, copy) RegisterBlock registerBlock;
@property (nonatomic, copy) DevicesBlock devicesBlock;
@property (nonatomic, copy) BluetoothBlock bluetoothBlock;

@property (nonatomic, assign) int touchState; //1、笔与屏幕接触 0、笔离开屏幕
@property (nonatomic, assign) int batteryState; //0-100
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSString *manufacturer;
@property (nonatomic, copy) NSString *firmware;
@property (nonatomic, copy) NSString *software;
@property (nonatomic, strong) NSMutableArray *rawAdcData;
@property (nonatomic, strong) NSMutableArray *gsensorData;
@property (nonatomic, assign) int xData;
@property (nonatomic, assign) int yData;
@property (nonatomic, assign) int zData;
@property (nonatomic, assign) int hvStateData;
@property (nonatomic, assign) int rawData;
@property (nonatomic, assign) int baseData;

@end

@implementation IpenManager

#pragma mark    - lifecycle
-(instancetype)init {
    self = [super init];
    if (self) {
        isStartSearchDevice = NO;
        [self initialization];
    }
    return self;
}

- (NSMutableArray *)datas {
    if (_datas == nil) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

- (NSMutableArray *)rawAdcData {
    if (_rawAdcData == nil) {
        _rawAdcData = [NSMutableArray array];
    }
    return _rawAdcData;
}

- (NSMutableArray *)gsensorData {
    if (_gsensorData == nil) {
        _gsensorData = [NSMutableArray array];
    }
    return _gsensorData;
}

- (void)initialization {
    self.cMgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

#pragma mark    - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case 0:
            NSLog(@"CBCentralManagerStateUnknown");
            break;
        case 1:
            NSLog(@"CBCentralManagerStateResetting");
            break;
        case 2:
            NSLog(@"CBCentralManagerStateUnsupported");//不支持蓝牙
            break;
        case 3:
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        case 4:
        {
            NSLog(@"CBCentralManagerStatePoweredOff");//蓝牙未开启
            ALERT(@"", @"请打开蓝牙");
        }
            break;
        case 5:
        {
            NSLog(@"CBCentralManagerStatePoweredOn");//蓝牙已开启
            if (isStartSearchDevice) {
                [self startDeviceDiscovery];
            }
        }
            break;
        default:
            break;
    }
}

// 发现外设后调用的方法
- (void)centralManager:(CBCentralManager *)central // 中心管理者
 didDiscoverPeripheral:(CBPeripheral *)peripheral // 外设
     advertisementData:(NSDictionary *)advertisementData // 外设携带的数据
                  RSSI:(NSNumber *)RSSI // 外设发出的蓝牙信号强度
{
    NSLog(@"发现外设后调用的方法 %s, line = %d, cetral = %@,peripheral = %@, advertisementData = %@, RSSI = %@", __FUNCTION__, __LINE__, central, peripheral, advertisementData, RSSI);
    
    if ([peripheral.name hasPrefix:@"iPens"]) {
        if (![self.datas containsObject:peripheral]) {
            [self.datas addObject:peripheral];
            if (self.devicesBlock) {
                self.devicesBlock(self.datas);
            }
        }
    }
}

// 中心管理者连接外设成功
- (void)centralManager:(CBCentralManager *)central // 中心管理者
  didConnectPeripheral:(CBPeripheral *)peripheral // 外设
{
    NSLog(@"中心管理者连接外设成功 %s, line = %d, %@=连接成功", __FUNCTION__, __LINE__, peripheral.name);
    if (self.bluetoothBlock) {
        self.bluetoothBlock(BluetoothTypeSuccess);
    }
    
    // 连接成功之后,可以进行服务和特征的发现
    
    //    //  设置外设的代理
    self.peripheral.delegate = self;
    //
    //    // 外设发现服务,传nil代表不过滤
    //    // 这里会触发外设的代理方法 - (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
    [self.peripheral discoverServices:nil];
}
// 外设连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"外设连接失败 %s, line = %d, %@=连接失败", __FUNCTION__, __LINE__, peripheral.name);
    if (self.bluetoothBlock) {
        self.bluetoothBlock(BluetoothTypeFail);
    }
}

// 丢失连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"丢失连接 %s, line = %d, %@=断开连接", __FUNCTION__, __LINE__, peripheral.name);
    if (self.bluetoothBlock) {
        self.bluetoothBlock(BluetoothTypeDisconnect);
    }
}
#pragma mark    - CBPeripheralDelegate
//我们在连接成功的方法中开始扫描外部设备的服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    NSLog(@"我们在连接成功的方法中开始扫描外部设备的服务-    %@",peripheral);
    for (CBService *s in peripheral.services) {
        //发现服务
        [peripheral discoverCharacteristics:nil forService:s];
    }
}

// 发现外设服务里的特征的时候调用的代理方法(这个是比较重要的方法，你在这里可以通过事先知道UUID找到你需要的特征，订阅特征，或者这里写入数据给特征也可以)
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"发现特征的服务:%@ \n %@ (%@)",service,service.UUID.data ,service.UUID);
    for (CBCharacteristic *cha in service.characteristics) {
        [peripheral readValueForCharacteristic:cha];
        
        [peripheral setNotifyValue:YES forCharacteristic:cha];
    }
}

// 更新特征的value的时候会调用 （凡是从蓝牙传过来的数据都要经过这个回调，简单的说这个方法就是你拿数据的唯一方法） 你可以判断是否
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSString *result =[[ NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
//    NSLog(@"%@ \n %@ \n %@",characteristic,result,characteristic.UUID.UUIDString);
    
    if ([characteristic.UUID.UUIDString isEqualToString:@"2A29"]) {
        self.manufacturer = result;
    }else if ([characteristic.UUID.UUIDString isEqualToString:@"2A26"]) {
        self.firmware = result;
    }else if ([characteristic.UUID.UUIDString isEqualToString:@"2A28"]) {
        self.software = result;
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A19"]]) {
        NSData *data = characteristic.value;
        NSUInteger len = [data length];
        Byte *byteData = (Byte*)malloc(len);
        memcpy(byteData, [data bytes], len);
        for (int i = 0; i<len; i++) {
            if (i == 0) {
                self.batteryState = byteData[i];
            }
        }
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"00001524-1212-EFDE-1523-785FEABCD123"]]) {
        [self.rawAdcData removeAllObjects];
        [self.gsensorData removeAllObjects];
        
        NSData *data = characteristic.value;
        NSUInteger len = [data length];
        Byte *byteData = (Byte*)malloc(len);
        memcpy(byteData, [data bytes], len);

        self.touchState = [self bytesByInt:byteData begin:0 count:1];
        self.xData = [self bytesByInt:byteData begin:1 count:2];
        self.yData = [self bytesByInt:byteData begin:3 count:2];
        self.zData = [self bytesByInt:byteData begin:5 count:2];
        self.rawData = [self bytesByInt:byteData begin:7 count:2];
        self.baseData = [self bytesByInt:byteData begin:9 count:2];
        self.hvStateData = [self bytesByInt:byteData begin:11 count:1];

        for (int i = 0; i<len; i++) {
            //            NSLog(@"%d",byteData[i]);
//            if (i == 0) {
//                self.touchState = byteData[i];
//            }
            if (i < 6) {
                [self.rawAdcData addObject:[NSString stringWithFormat:@"%hhu",byteData[i]]];
            }else if (i >= 6 && i < 12) {
                [self.gsensorData addObject:[NSString stringWithFormat:@"%hhu",byteData[i]]];
            }
        }
        //        NSLog(@"\n");
    }
    self.model = peripheral.name;
    
    if (self.registerBlock) {
        self.registerBlock(peripheral, characteristic);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError *)error {
    
    NSLog(@"+++   %@",peripheral);
}

- (void)bytesplit2byte:(Byte[])src orc:(Byte[])orc begin:(NSInteger)begin count:(NSInteger)count{
    memset(orc, 0, sizeof(char)*count);
    for (NSInteger i = begin; i < begin+count; i++){
        orc[i-begin] = src[i];
    }
}

-(int)bytesByInt:(Byte[])src begin:(int)begin count:(int)count {
    Byte byteData1[count];
    
    [self bytesplit2byte:src orc:byteData1 begin:begin count:count];
    NSData *adata = [[NSData alloc] initWithBytes:byteData1 length:count];
    
    Byte *bytes = (Byte *)[adata bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[adata length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff]; ///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    NSString *temp10=[NSString stringWithFormat:@"%lu",strtoul([hexStr UTF8String],0,16)];
    return [temp10 intValue];
}

#pragma mark    - 功能

/**
 获取蓝牙连接状态
 
 @param block BluetoothBlock
 */
- (void)bluetoothTypeBlock:(BluetoothBlock)block {
    self.bluetoothBlock = block;
}

/**
 开始设备搜索
 */
- (void)startDeviceDiscovery {
    isStartSearchDevice = YES;
    [self.cMgr scanForPeripheralsWithServices:nil // 通过某些服务筛选外设
                                      options:nil]; // dict,条件
}

/**
 获取蓝牙设备
 
 @param block 蓝牙设备数组
 */
- (void)getDevices:(DevicesBlock)block {
    self.devicesBlock = block;
}


/**
 停止设备搜索
 */
- (void)stopDeviceDiscovery {
    isStartSearchDevice = NO;
    [self.cMgr stopScan];
}

/**
 选择设备
 
 @param peripheral 选定一个蓝牙设备并连接设备。可以接收此设备发送的数据
 */
- (void)selectDevice:(CBPeripheral *)peripheral {
    self.peripheral = peripheral;
    [self.cMgr connectPeripheral:self.peripheral options:nil];
}

/**
 放弃选择设备,放弃之前选定的蓝牙设备，断开连接。
 */
- (void)deselectDevice {
    [self.cMgr cancelPeripheralConnection:self.peripheral];
}

/**
 获取已选择设备
 
 @return CBPeripheral
 */
- (CBPeripheral *)getSelectDevice {
    return self.peripheral;
}

/**
 清除存储设备
 */
- (void)clearStoredDevice {
    [self.datas removeAllObjects];
}

/**
 重新连接设备
 */
- (void)reconnectToStoredDevices {
    [self.cMgr connectPeripheral:self.peripheral options:nil];
}

/**
 注册通知消息
 */
- (void)registerForNotification:(RegisterBlock)block {
    self.registerBlock = block;
}

/**
 不注册通知消息
 */
- (void)deregisterForNotification {
    self.registerBlock = nil;
}

/**
 获取笔状态
 
 @return  1、笔与屏幕接触 0、笔离开屏幕
 */
- (int)getTouchState {
    return self.touchState;
}

/**
 获取电池电量
 
 @return 0-100
 */
- (int)getBatteryState {
    return self.batteryState;
}

/**
 获取设备名称
 
 @return 获取设备名称
 */
- (NSString *)getModel {
    return self.model;
}

/**
 获取公司名称
 
 @return 获取公司名称
 */
- (NSString *)getManufacturer {
    return self.manufacturer;
}

/**
 获取固件版本
 
 @return 获取固件版本
 */
- (NSString *)getFirmware {
    return self.firmware;
}

/**
 获取软件版本
 
 @return 获取软件版本
 */
- (NSString *)getSoftware {
    return self.software;
}

/**
 获取RAWData
 
 @return 获取RAWData
 */
- (NSArray *)getRawAdcData {
    return self.rawAdcData;
}

/**
 获取GsensorData
 
 @return 获取GsensorData
 */
- (NSArray *)getGsensorData {
    return self.gsensorData;
}

/**
 获取Xdata
 
 @return Xdata
 */
- (int)getXdata {
    return self.xData;
}

/**
 获取Ydata
 
 @return  Ydata
 */
- (int)getYdata {
    return self.yData;
}

/**
 获取Zdata
 
 @return  Zdata
 */
- (int)getZdata {
    return self.zData;
}

/**
 获取Rawdata
 
 @return  Rawdata
 */
- (int)getRawdata {
    return self.rawData;
}

/**
 获取Basedata
 
 @return  Basedata
 */
- (int)getBasedata {
    return self.baseData;
}

/**
 获取HvState
 
 @return  HvState
 */
- (int)getHvState {
    return self.hvStateData;
}


@end
