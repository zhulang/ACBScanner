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
- (void)peripheralDidSendData:(NSDictionary *)dataDic status:(BOOL)status;
{
    NSLog(@"peripheralDidSendData - %@",dataDic);
}

- (void)peripheralRecogniseDidFail:(NSString *)errorDescription
{
    NSLog(@"%@",errorDescription);
}

- (void)peripheralDidStopScanning
{
    NSLog(@"已停止扫描");
}

- (void)peripheralDidStartScanning
{
    NSLog(@"已开始扫描");
}

- (void)peripheralDidSendJsonString:(nonnull NSString *)jsonString status:(BOOL)status {
    if (status == NO) {
        NSLog(@"数据已发出，中心设备没有接收成功");
    }else{
        NSLog(@"中心设备已成功接收成功");
    }
}

@end
