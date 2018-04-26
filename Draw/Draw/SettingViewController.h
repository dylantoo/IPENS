//
//  SettingViewController.h
//  Draw
//
//  Created by ZJW on 2017/9/27.
//  Copyright © 2017年 ZJW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
//#import <IpenManager/IpenManager.h>
#import "IpenManager.h"

typedef void(^ManagerBluetoothTypeBlock)(BluetoothType type);
typedef void(^ManagerNotificationBlock)(IpenManager *ipenManager);

@interface SettingViewController : UIViewController

@property (nonatomic, copy) ManagerBluetoothTypeBlock managerBluetoothTypeBlock;
@property (nonatomic, copy) ManagerNotificationBlock managerNotificationBlock;


@end
