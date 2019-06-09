//
//  ViceMachineTableViewController.m
//  BScanner
//
//  Created by 朱浪 on 2019/5/23.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "PeripheralMachineTableViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <AVFoundation/AVFoundation.h>
#import "ACBScannerManager.h"
#import "ACProgressHUD.h"

@interface PeripheralMachineTableViewController ()<ACBScannerPeripheralDelegate>
@property (nonatomic,copy) NSString * serviceName;
@end

@implementation PeripheralMachineTableViewController

- (instancetype)initWithServiceName:(NSString *)serviceName
{
    self = [super init];
    if (self) {
        self.serviceName = serviceName;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"扫描仪";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[ACBScannerManager manager] initPeripheralManager:self.serviceName delegate:self preview:self.view previewLayerFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [[ACBScannerManager manager] beginScanningBarCode:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[ACBScannerManager manager] stopScanningBarCode];
}

#pragma mark - ACBScannerPeripheralDelegate methods
//选择自上传时根据需要决定是否实现此方法
- (void)didUpload:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error
{
    NSString * str = [NSString stringWithFormat:@"statusCode: %zd",((NSHTTPURLResponse *)response).statusCode];
    [ACProgressHUD toastMessage:str withImage:nil];
}

- (void)peripheralRecogniseDidFail:(NSString *)errorDescription
{
    [ACProgressHUD toastMessage:errorDescription withImage:nil];
}

- (void)peripheralRecogniseSameTwice
{
    [ACProgressHUD toastMessage:@"和上一次扫描结果一样" withImage:nil];
}

- (void)peripheralDidStopScanning
{
    [ACProgressHUD toastMessage:@"停止扫描" withImage:nil];
}

- (void)peripheralDidStartScanning
{
    [ACProgressHUD toastMessage:@"开始扫描" withImage:nil];
}

- (void)peripheralDidSendJsonString:(nonnull NSString *)jsonString status:(BOOL)status {
    if (status == NO) {
        [ACProgressHUD toastMessage:@"中心设备没有接收成功" withImage:nil];
    }else{
        NSDictionary * dic = [jsonString mj_JSONObject];
        NSDictionary * info = dic[self.serviceName];
        NSString * code = info[@"code"];
        [ACProgressHUD toastScuess:code];
    }
}

@end
