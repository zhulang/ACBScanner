//
//  ViceMachineTableViewController.m
//  BScanner
//
//  Created by 朱浪 on 2019/5/23.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "PeripheralMachineTableViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "PeripheralSettingViewController.h"
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
    [ACBScannerManager manager].peripheralDelegate = self;
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    [ACBScannerManager manager].previewLayerFrame = CGRectMake(0, 0, w, h);
    self.navigationItem.title = @"扫描仪";
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(setting)]];
}

- (void)setting
{
    PeripheralSettingViewController * vc = [[PeripheralSettingViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - ACBScannerPeripheralDelegate methods
- (void)peripheralDidSendData:(NSDictionary *)dataDic status:(BOOL)status;
{
    
}

- (void)peripheralRecogniseDidFail:(NSString *)errorDescription
{
    
}

- (void)peripheralDidStopScanning
{
    
}

- (void)peripheralDidStartScanning
{
    
}

@end
