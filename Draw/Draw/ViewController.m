//
//  ViewController.m
//  Draw
//
//  Created by ZJW on 2017/9/11.
//  Copyright © 2017年 ZJW. All rights reserved.
//

#import "ViewController.h"
#import "ZJWButton.h"
#import "ZJWCoverView.h"
#import "ZJWDrawView.h"
#import "ZJWPhotoImg.h"
#import <Masonry/Masonry.h>
#import "ColorView.h"
#import "UIkitBlockAdditions.h"
#import "CoreBluetoothViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "SettingViewController.h"

#import "IpenManager.h"
#import "PathManager.h"

#define ALERT(title,msg) [[[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show]

typedef NS_ENUM(NSInteger, BluetoothConnectOnTheScreenType) {
    BluetoothConnectOnTheScreenTypeisNotConnect,//蓝牙未连接
    BluetoothConnectOnTheScreenTypeisConnectAndOnTheScreen,//蓝牙连接并在屏幕上
    BluetoothConnectOnTheScreenTypeisConnectAndNotOnTheScreen,//蓝牙连接不在屏幕上
};

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,ZJWPhotoImgDelegate,ZJWDrawViewDelegate>

@property (assign, nonatomic) BOOL isShowColorView;
@property (weak, nonatomic) IBOutlet UIView *topToolView;
@property (weak, nonatomic) IBOutlet UIView *bottomImageToolView;
@property (weak, nonatomic) IBOutlet ZJWDrawView *drawView;
@property (weak, nonatomic) IBOutlet UILabel *bluetooth;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UIButton *deleteLineBtn;
@property (weak, nonatomic) IBOutlet UISlider *lineWidthSlider;

@property (nonatomic, strong) UILabel *contentLbl;
@property (nonatomic, strong) UILabel *majorLbl;

@property (assign, nonatomic) BluetoothConnectOnTheScreenType bluetoothConnectOnTheScreenType;


@property (nonatomic, strong) CBPeripheral *peripheral;

@property (strong, nonatomic) ZJWPhotoImg *photoView;
@property (strong, nonatomic) ColorView *pickerColorView;

@property (nonatomic, strong) SettingViewController *settingVC;


@property (nonatomic, strong) IpenManager *ipenManager;

@end

@implementation ViewController

#pragma mark    -lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnLong:)];
    longPress.minimumPressDuration = 1; //定义按的时间
    [self.deleteLineBtn addGestureRecognizer:longPress];
    self.deleteLineBtn.enabled = YES;
    
    self.isShowColorView = NO;
    self.drawView.delegte = self;
    [self setBluetoothType:BluetoothConnectOnTheScreenTypeisNotConnect];
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.settingVC) {
        self.settingVC = nil;
    }
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark    - setupView
- (void)setupView {
    self.pickerColorView = [[ColorView alloc]init];
    [self.pickerColorView setupView];
    [self.view addSubview:self.pickerColorView];
    [self.pickerColorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(ColorViewWidth);
        make.top.equalTo(self.topToolView.mas_bottom);
        make.bottom.equalTo(self.view);
        make.width.mas_equalTo(ColorViewWidth);
    }];
    WS(weakSelf)
    self.pickerColorView.colorBlock = ^(UIColor *color) {
        if (color != nil) {
            [weakSelf.drawView lineColorWithColor:color];
            weakSelf.colorView.backgroundColor = color;
            weakSelf.isShowColorView = NO;
            [weakSelf changeColorViewAniment:weakSelf.isShowColorView];
        }
    };

    self.bluetooth.tappedBlock = ^(UITapGestureRecognizer *tap) {
        [weakSelf gotoCoreBluetoothVC];
    };
    self.bluetooth.text = @"未连接蓝牙";
    self.contentLbl = [[UILabel alloc] init];
    self.contentLbl.backgroundColor = [UIColor clearColor];
    self.contentLbl.textColor = [UIColor blackColor];
    self.contentLbl.font = [UIFont systemFontOfSize:14];
    self.contentLbl.text = @"书写信息:";
    [self.view addSubview:self.contentLbl];
    
    [self.contentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(weakSelf.view);
        make.height.equalTo(@(30));
        make.bottom.equalTo(weakSelf.bottomImageToolView.mas_top);
    }];
    
    PATHMANAGER.contentBlock = ^(NSString *content) {
        weakSelf.contentLbl.text = content;
    };
    
    
    self.majorLbl = [[UILabel alloc] init];
    self.majorLbl.backgroundColor = [UIColor clearColor];
    self.majorLbl.textColor = [UIColor blackColor];
    self.majorLbl.font = [UIFont systemFontOfSize:14];
    self.majorLbl.text = @"major信息:";
    [self.view addSubview:self.majorLbl];
    
    [self.majorLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(weakSelf.view);
        make.height.equalTo(@(30));
        make.bottom.equalTo(weakSelf.contentLbl.mas_top);
    }];
    
    PATHMANAGER.majorBlock = ^(NSString *content) {
        if ([content isEqualToString:RemoveCurTouchTip]) {
            self.majorLbl.backgroundColor = [UIColor redColor];
        }
        else {
            self.majorLbl.backgroundColor = [UIColor clearColor];
        }
        
        weakSelf.majorLbl.text = content;
    };
}

#pragma mark    - method
- (void)changeDeleteBtnTpye {
//    if (self.drawView.isHavePath) {
//        self.deleteLineBtn.enabled = YES;
//    }else {
//        self.deleteLineBtn.enabled = NO;
//    }
}

- (void)changeColorViewAniment:(BOOL)isShow {
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat right = ColorViewWidth;
        if (isShow) {
            right = 0;
        }
        [self.pickerColorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view).offset(right);
        }];
        
        [self.pickerColorView.superview layoutIfNeeded];
    }];
}

- (void)reduction {
    self.lineWidthSlider.alpha = 0;
    if (self.isShowColorView) {
        self.isShowColorView = NO;
        [self changeColorViewAniment:self.isShowColorView];
    }
}

- (void)initIpenManager:(IpenManager *)ipenManager {
    self.ipenManager = ipenManager;
    WS(weakSelf)
    [self.ipenManager registerForNotification:^(CBPeripheral *peripheral, CBCharacteristic *characteristic) {
        
        
        weakSelf.bluetooth.text = [self getBluetoothString:[weakSelf.ipenManager getTouchState]];
        BOOL PenState = [weakSelf.ipenManager getTouchState];
        
        if (PenState) {
            NSProcessInfo *info = [NSProcessInfo processInfo];
            NSTimeInterval now = info.systemUptime;
            NSLog(@"蓝牙上报时间戳:%f", now);
        }
//        NSLog(@"ipenManager getTouchState:%d",PenState);
        PATHMANAGER.isPenWriting = PenState;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(BlueToothDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            PATHMANAGER.isPenWriting = PenState;
//        });
        
        if (PenState) {
            weakSelf.bluetooth.backgroundColor = [UIColor yellowColor];
        }
        else {
            weakSelf.bluetooth.backgroundColor = [UIColor clearColor];
        }
        
        if (weakSelf.settingVC.managerNotificationBlock) {
            weakSelf.settingVC.managerNotificationBlock(weakSelf.ipenManager);
        }
    }];
    [self.ipenManager bluetoothTypeBlock:^(BluetoothType type) {
        if (weakSelf.settingVC.managerBluetoothTypeBlock) {
            weakSelf.settingVC.managerBluetoothTypeBlock(type);
        }
        switch (type) {
            case BluetoothTypeSuccess: {
                weakSelf.bluetooth.text = @"连接成功";
//                weakSelf.drawView.isConnectBluetooth = YES;
                PATHMANAGER.isConnectedBlueTooth = YES;
            }
                break;
            case BluetoothTypeFail: {
                weakSelf.bluetooth.text = @"连接失败";
                PATHMANAGER.isConnectedBlueTooth = NO;
//                weakSelf.drawView.isConnectBluetooth = NO;
                [weakSelf setBluetoothType:BluetoothConnectOnTheScreenTypeisNotConnect];
            }
                break;
            case BluetoothTypeDisconnect: {
                weakSelf.bluetooth.text = @"断开蓝牙";
                PATHMANAGER.isConnectedBlueTooth = NO;
//                weakSelf.drawView.isConnectBluetooth = NO;
                [weakSelf setBluetoothType:BluetoothConnectOnTheScreenTypeisNotConnect];
                [weakSelf.ipenManager reconnectToStoredDevices];
            }
                break;
                
            default:
                break;
        }
    }];
    [self.ipenManager selectDevice:self.peripheral];
    [self.ipenManager stopDeviceDiscovery];
}

- (NSString *)getBluetoothString:(int)touchState {
    NSString *string = @"离开屏幕";
    [self setBluetoothType:BluetoothConnectOnTheScreenTypeisConnectAndNotOnTheScreen];
    if (touchState == 1) {
        [self setBluetoothType:BluetoothConnectOnTheScreenTypeisConnectAndOnTheScreen];
        string = @"在屏幕上";
    }
    return [NSString stringWithFormat:@"电量:%d%%, 笔触状态:%@",[self.ipenManager getBatteryState],string];
}

- (void)setBluetoothType:(BluetoothConnectOnTheScreenType)type {
    self.bluetoothConnectOnTheScreenType = type;
//    if (type == BluetoothConnectOnTheScreenTypeisConnectAndNotOnTheScreen) {
//        self.drawView.userInteractionEnabled = NO;
//    }else {
//        self.drawView.userInteractionEnabled = YES;
//    }
}

#pragma mark    - click
- (IBAction)deleteLine:(id)sender {
    [self.drawView deleteLast];
    [self changeDeleteBtnTpye];
}

- (void)btnLong:(id)sender {
    [self.drawView clear];
    [self changeDeleteBtnTpye];
}

- (IBAction)lineWidth:(id)sender {
    if (self.isShowColorView) {
        self.isShowColorView = NO;
        [self changeColorViewAniment:self.isShowColorView];
    }
    self.lineWidthSlider.alpha = self.lineWidthSlider.alpha==1?0:1;
}

- (IBAction)setLinesWidth:(UISlider *)sender {

    CGFloat lineW = sender.value;
    
    [self.drawView lineWidthWithFloat:lineW];
}

- (IBAction)photo:(id)sender {
    [self reduction];
    
    self.topToolView.userInteractionEnabled = NO;
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)color:(id)sender {
    self.lineWidthSlider.alpha = 0;

    self.isShowColorView = !self.isShowColorView;
    [self changeColorViewAniment:self.isShowColorView];
}

- (IBAction)determinePhoto:(id)sender {
    [self.photoView drawImage];
    self.bottomImageToolView.hidden = YES;
    self.topToolView.userInteractionEnabled = YES;
}

- (IBAction)cancelPhoto:(id)sender {
    [self.photoView removeFromSuperview];
    self.bottomImageToolView.hidden = YES;
    self.topToolView.userInteractionEnabled = YES;
}

- (void)gotoCoreBluetoothVC {
    CoreBluetoothViewController *vc = [CoreBluetoothViewController new];
    if (self.peripheral != nil) {
        vc.peripheral = self.peripheral;
    }
    WS(weakSelf)
    vc.linkBlock = ^(CBPeripheral *peripheral, IpenManager *ipenManager) {
        weakSelf.peripheral = peripheral;
        [weakSelf initIpenManager:ipenManager];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)blueToothClick:(id)sender {
    [self gotoCoreBluetoothVC];
}

- (IBAction)gotoSetting:(id)sender {
    self.settingVC = [SettingViewController new];
    
    [self.navigationController pushViewController:self.settingVC animated:YES];
}

#pragma mark    - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //获得图片
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    self.photoView = nil;
    
    self.photoView = [[ZJWPhotoImg alloc]initWithFrame:self.drawView.frame];
    
    //这里把photoView放到drawView上，拖拽图片时，drawView也能响应pan手势
    [self.view addSubview:self.photoView];
    
    [self.view bringSubviewToFront:self.topToolView];
    [self.view bringSubviewToFront:self.bottomImageToolView];
    
    self.photoView.image = img;
    self.photoView.delegte = self;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    self.bottomImageToolView.hidden = NO;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    self.topToolView.userInteractionEnabled = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark    - ZJWPhotoImgDelegate
- (void)photoImg:(ZJWPhotoImg *)phohoImg withImage:(UIImage *)image
{
    self.drawView.image = image;
}

#pragma mark    - ZJWDrawViewDelegate
- (void)drawBegan {
    [self reduction];
}

- (void)drawBeganAnimate {
    self.lineWidthSlider.alpha = 0;
    if (self.topToolView.alpha == 1) {
        [UIView animateWithDuration:0.5 animations:^{
            self.topToolView.alpha = 0;
        }];
    }
}

- (void)drawEnd {
    [self reduction];

    [self changeDeleteBtnTpye];
    self.lineWidthSlider.alpha = 0;

    if (self.topToolView.alpha == 0) {
        [UIView animateWithDuration:1 animations:^{
            self.topToolView.alpha = 1;
        }];
    }
}

@end
