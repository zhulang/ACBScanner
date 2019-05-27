//
//  CenterMachineSettingViewController.m
//  ACBScanner
//
//  Created by Achilles on 2019/5/24.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "CenterMachineSettingViewController.h"
#import "ACBScannerCongfig.h"

@interface CenterMachineSettingViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *maxConnectLabel;
@property (weak, nonatomic) IBOutlet UISlider *maxConnectSlider;
@property (weak, nonatomic) IBOutlet UILabel *maxCacheLabel;
@property (weak, nonatomic) IBOutlet UISlider *maxCacheSlider;
@property (weak, nonatomic) IBOutlet UITextField *uploadUrltextField;
@property (weak, nonatomic) IBOutlet UITextField *dataUrltextField;
@property (nonatomic, strong)ACBScannerCongfig * config;
@end

@implementation CenterMachineSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"中心设备参数设置";
    UITapGestureRecognizer * tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fieldResignFirstResponder)];
    [self.view addGestureRecognizer:tapView];
    self.config = [ACBScannerCongfig config];
    self.maxConnectSlider.value = [self.config.centerConfig.maxInterfaceNumber floatValue];
    self.maxConnectLabel.text = [NSString stringWithFormat:@"最大连接扫描仪个数：%.0f",self.maxConnectSlider.value];
    
    self.maxCacheSlider.value = [self.config.centerConfig.maxCacheNumber floatValue];
    self.maxCacheLabel.text = [NSString stringWithFormat:@"最大缓存记录条数：%.0f",self.maxCacheSlider.value];
    
    self.uploadUrltextField.text = self.config.centerConfig.uploadUrl;
    self.dataUrltextField.text = self.config.centerConfig.dataUrl;
    
    self.uploadUrltextField.delegate = self;
    self.dataUrltextField.delegate = self;
}

- (IBAction)maxConnectDidChange:(UISlider *)sender {
    self.maxConnectLabel.text = [NSString stringWithFormat:@"最大连接扫描仪个数：%.0f",self.maxConnectSlider.value];
    self.config.centerConfig.maxInterfaceNumber = [NSNumber numberWithFloat:sender.value];
    [ACBScannerCongfig archiver:self.config];
}

- (IBAction)maxCacheDidChange:(UISlider *)sender {
    self.maxCacheLabel.text = [NSString stringWithFormat:@"最大缓存记录条数：%.0f",sender.value];
    self.config.centerConfig.maxCacheNumber = [NSNumber numberWithFloat:sender.value];
    [ACBScannerCongfig archiver:self.config];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([textField isEqual:self.dataUrltextField]) {
        self.config.centerConfig.dataUrl = str;
        [ACBScannerCongfig archiver:self.config];
    }
    if ([textField isEqual:self.uploadUrltextField]) {
        self.config.centerConfig.uploadUrl = str;
        [ACBScannerCongfig archiver:self.config];
    }
    return YES;
}

- (void)fieldResignFirstResponder
{
    [self.uploadUrltextField resignFirstResponder];
    [self.dataUrltextField resignFirstResponder];
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


@end
