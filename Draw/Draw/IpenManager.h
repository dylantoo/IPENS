//
//  IpenManager.h
//  IpenManager
//
//  Created by ZJW on 2017/9/18.
//  Copyright © 2017年 ZJW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BluetoothType) {
    BluetoothTypeSuccess,
    BluetoothTypeFail,
    BluetoothTypeDisconnect,
};

typedef void(^RegisterBlock)(CBPeripheral *peripheral, CBCharacteristic *characteristic);
typedef void(^DevicesBlock)(NSArray *devices);
typedef void(^BluetoothBlock)(BluetoothType type);

@interface IpenManager : NSObject

/**
 获取蓝牙连接状态
 
 @param block BluetoothBlock
 */
- (void)bluetoothTypeBlock:(BluetoothBlock)block;

/**
 开始设备搜索
 */
- (void)startDeviceDiscovery;

/**
 获取蓝牙设备
 
 @param block 蓝牙设备数组
 */
- (void)getDevices:(DevicesBlock)block;

/**
 停止设备搜索
 */
- (void)stopDeviceDiscovery;

/**
 选择设备
 
 @param peripheral 选定一个蓝牙设备并连接设备。可以接收此设备发送的数据
 */
- (void)selectDevice:(CBPeripheral *)peripheral;

/**
 放弃选择设备,放弃之前选定的蓝牙设备，断开连接。
 */
- (void)deselectDevice;

/**
 获取已选择设备
 
 @return CBPeripheral
 */
- (CBPeripheral *)getSelectDevice;

/**
 清除存储设备
 */
- (void)clearStoredDevice;

/**
 重新连接设备
 */
- (void)reconnectToStoredDevices;

/**
 注册通知消息
 
 @param block 注册通知消息
 */
- (void)registerForNotification:(RegisterBlock)block;

/**
 不注册通知消息
 */
- (void)deregisterForNotification;

/**
 获取笔状态
 
 @return  1、笔与屏幕接触 0、笔离开屏幕
 */
- (int)getTouchState;

/**
 获取电池电量
 
 @return 0-100
 */
- (int)getBatteryState;

/**
 获取设备名称
 
 @return 获取设备名称
 */
- (NSString *)getModel;

/**
 获取公司名称
 
 @return 获取公司名称
 */
- (NSString *)getManufacturer;

/**
 获取固件版本
 
 @return 获取固件版本
 */
- (NSString *)getFirmware;

/**
 获取软件版本
 
 @return 获取软件版本
 */
- (NSString *)getSoftware;

/**
 获取RAWData
 
 @return 获取RAWData
 */
- (NSArray *)getRawAdcData;

/**
 获取GsensorData
 
 @return 获取GsensorData
 */
- (NSArray *)getGsensorData;

/**
 获取Xdata
 
 @return Xdata
 */
- (int)getXdata;

/**
 获取Ydata
 
 @return  Ydata
 */
- (int)getYdata;

/**
 获取Zdata
 
 @return  Zdata
 */
- (int)getZdata;

/**
 获取Rawdata
 
 @return  Rawdata
 */
- (int)getRawdata;

/**
 获取Basedata
 
 @return  Basedata
 */
- (int)getBasedata;

/**
 获取HvState
 
 @return  HvState
 */
- (int)getHvState;

@end
