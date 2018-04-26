//
//  CoreBluetoothViewController.h
//  Draw
//
//  Created by ZJW on 2017/9/18.
//  Copyright © 2017年 ZJW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
//#import <IpenManager/IpenManager.h>
#import "IpenManager.h"

typedef void(^LinkBlock)(CBPeripheral *peripheral,IpenManager *ipenManager);

@interface CoreBluetoothViewController : UIViewController

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, copy) LinkBlock linkBlock;

@end
