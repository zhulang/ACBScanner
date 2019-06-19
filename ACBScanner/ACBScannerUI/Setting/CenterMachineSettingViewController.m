//
//  CenterMachineSettingViewController.m
//  ACBScanner
//
//  Created by Achilles on 2019/5/24.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "CenterMachineSettingViewController.h"
#import <WatchDogSDK/ACBScannerManager.h>

@interface CenterMachineSettingViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *maxConnectLabel;
@property (weak, nonatomic) IBOutlet UISlider *maxConnectSlider;
@property (weak, nonatomic) IBOutlet UILabel *maxCacheLabel;
@property (weak, nonatomic) IBOutlet UISlider *maxCacheSlider;
@property (weak, nonatomic) IBOutlet UILabel *autoUploadLabel;
@property (weak, nonatomic) IBOutlet UISwitch *autoUploadSwitch;
@end

@implementation CenterMachineSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"中心设备参数设置";
    
    self.maxConnectSlider.value = [ACBScannerManager manager].maxInterfaceNumber;
    self.maxConnectLabel.text = [NSString stringWithFormat:@"最大连接扫描仪个数：%.0f",self.maxConnectSlider.value];
    
    self.maxCacheSlider.value = [ACBScannerManager manager].maxCacheNumber;
    self.maxCacheLabel.text = [NSString stringWithFormat:@"最大缓存记录条数：%.0f",self.maxCacheSlider.value];
    
    self.autoUploadSwitch.on = [ACBScannerManager manager].autoUpload;
    self.autoUploadLabel.text = [NSString stringWithFormat:@"自动上传：%@",self.autoUploadSwitch.on ? @"开" : @"关"];
}

- (IBAction)maxConnectDidChange:(UISlider *)sender {
    self.maxConnectLabel.text = [NSString stringWithFormat:@"最大连接扫描仪个数：%.0f",self.maxConnectSlider.value];
    [ACBScannerManager manager].maxInterfaceNumber = sender.value;
}

- (IBAction)maxCacheDidChange:(UISlider *)sender {
    self.maxCacheLabel.text = [NSString stringWithFormat:@"最大缓存记录条数：%.0f",sender.value];
    [ACBScannerManager manager].maxCacheNumber = sender.value;
}

- (IBAction)clearCacheData:(UIButton *)sender {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"谨慎操作提示" message:@"点击清除将清除所有缓存条码记录" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * act = [UIAlertAction actionWithTitle:@"清除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"clear.cache.data" object:@(YES)];
    }];
    UIAlertAction * act2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:act];
    [alert addAction:act2];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}
- (IBAction)autoUploadValueDidChange:(UISwitch *)sender {
    [ACBScannerManager setCenterAutoUpload:sender.on];
    self.autoUploadLabel.text = [NSString stringWithFormat:@"自动上传：%@",sender.on ? @"开" : @"关"];
}

@end
