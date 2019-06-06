//
//  CenterMachineSettingViewController.m
//  ACBScanner
//
//  Created by Achilles on 2019/5/24.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "CenterMachineSettingViewController.h"
#import "ACBScannerManager.h"

@interface CenterMachineSettingViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *maxConnectLabel;
@property (weak, nonatomic) IBOutlet UISlider *maxConnectSlider;
@property (weak, nonatomic) IBOutlet UILabel *maxCacheLabel;
@property (weak, nonatomic) IBOutlet UISlider *maxCacheSlider;
@property (weak, nonatomic) IBOutlet UITextField *uploadUrltextField;
@property (weak, nonatomic) IBOutlet UITextField *dataUrltextField;
@end

@implementation CenterMachineSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"中心设备参数设置";
    UITapGestureRecognizer * tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fieldResignFirstResponder)];
    [self.view addGestureRecognizer:tapView];
    self.maxConnectSlider.value = [ACBScannerManager manager].maxInterfaceNumber;
    self.maxConnectLabel.text = [NSString stringWithFormat:@"最大连接扫描仪个数：%.0f",self.maxConnectSlider.value];
    
    self.maxCacheSlider.value = [ACBScannerManager manager].maxCacheNumber;
    self.maxCacheLabel.text = [NSString stringWithFormat:@"最大缓存记录条数：%.0f",self.maxCacheSlider.value];
    
    self.uploadUrltextField.text = [ACBScannerManager manager].uploadUrl;
    self.dataUrltextField.text = [ACBScannerManager manager].dataUrl;
    
    self.uploadUrltextField.delegate = self;
    self.dataUrltextField.delegate = self;
}

- (IBAction)maxConnectDidChange:(UISlider *)sender {
    self.maxConnectLabel.text = [NSString stringWithFormat:@"最大连接扫描仪个数：%.0f",self.maxConnectSlider.value];
    [ACBScannerManager manager].maxInterfaceNumber = sender.value;
}

- (IBAction)maxCacheDidChange:(UISlider *)sender {
    self.maxCacheLabel.text = [NSString stringWithFormat:@"最大缓存记录条数：%.0f",sender.value];
    [ACBScannerManager manager].maxCacheNumber = sender.value;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([textField isEqual:self.dataUrltextField]) {
        [ACBScannerManager manager].dataUrl = str;
    }
    if ([textField isEqual:self.uploadUrltextField]) {
        [ACBScannerManager manager].uploadUrl = str;
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
