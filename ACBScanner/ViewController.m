//
//  ViewController.m
//  BScanner
//
//  Created by 朱浪 on 2019/5/23.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "ViewController.h"
#import "CenterMachineTableViewController.h"
#import "PeripheralMachineTableViewController.h"
#import "ACBScannerManager.h"
#import <AVFoundation/AVFoundation.h>
#import "ACProgressHUD.h"

@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextField *operatorNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *operatorNumberTextField;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *centerMachineButton;
@property (weak, nonatomic) IBOutlet UIButton *peripheralMachineButton;
@property (weak, nonatomic) IBOutlet UIButton *center2scanButton;
@property (weak, nonatomic) IBOutlet UIButton *peripheralSelfUploadButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    UITapGestureRecognizer * tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fieldResignFirstResponder)];
    [self.view addGestureRecognizer:tapView];
    self.textField.text = @"999";
    self.operatorNameTextField.text = [ACBScannerManager getOperatorName];
    self.operatorNumberTextField.text = [ACBScannerManager getOperatorNumber];
    self.tipLabel.text =
     @"使用说明：\n"
     @"1.开启蓝牙后使用。\n"
     @"2.外设离中心设备距离不要超过100米。\n"
     @"3.建议不要关闭连续对焦功能（默认开启）。";
    self.centerMachineButton.layer.cornerRadius = 4;
    self.centerMachineButton.clipsToBounds = YES;
    self.peripheralMachineButton.layer.cornerRadius = 4;
    self.peripheralMachineButton.clipsToBounds = YES;
    self.center2scanButton.layer.cornerRadius = 4;
    self.center2scanButton.clipsToBounds = YES;
    self.peripheralSelfUploadButton.layer.cornerRadius = 4;
    self.peripheralSelfUploadButton.clipsToBounds = YES;
    
    self.centerMachineButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.peripheralMachineButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.operatorNumberTextField.delegate = self;
    self.operatorNameTextField.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self fieldResignFirstResponder];
}

- (IBAction)asCenterMachine:(UIButton *)sender {
    if ( [ACBScannerManager manager].autoUpload && ([ACBScannerManager manager].uploadUrl == nil || ![[ACBScannerManager manager].uploadUrl hasPrefix:@"http"])) {
        [ACProgressHUD toastMessage:@"请在设置里正确填写好服务器地址" withImage:nil];
        return;
    }
    
    if (self.textField.text) {
        NSString * cubbId = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (cubbId.length == 0) {
            UIAlertAction * act = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            UIAlertController * vc = [UIAlertController alertControllerWithTitle:@" ❗❗" message:@"请先输入中心设备服务名称" preferredStyle:UIAlertControllerStyleAlert];
            [vc addAction:act];
            [self presentViewController:vc animated:YES completion:nil];
        }else{
            [ACBScannerManager manager].isLinkScanGun = NO;
            CenterMachineTableViewController * vc = [[CenterMachineTableViewController alloc] initWithServiceName:cubbId];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (IBAction)asViceMachine:(UIButton *)sender {
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusAuthorized) {
        [ACProgressHUD toastMessage:@"请打开设想机权限" withImage:nil];
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self open:NO];
                });
            }
        }];
        return;
    }
    [self open:NO];
}

- (void)open:(BOOL)uploadSelf
{
    if (self.textField.text) {
        NSString * cubbId = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (cubbId.length == 0) {
            UIAlertAction * act = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            UIAlertController * vc = [UIAlertController alertControllerWithTitle:@" ❗❗" message:@"请先输入中心设备服务名称" preferredStyle:UIAlertControllerStyleAlert];
            [vc addAction:act];
            [self presentViewController:vc animated:YES completion:nil];
        }else{
            [ACBScannerManager manager].uploadSelf = uploadSelf;
            PeripheralMachineTableViewController * vc = [[PeripheralMachineTableViewController alloc] initWithServiceName:cubbId];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (IBAction)uploadPeripheralSelf:(UIButton *)sender
{
    if ([ACBScannerManager manager].uploadUrl == nil || ![[ACBScannerManager manager].uploadUrl hasPrefix:@"http"]) {
        [ACProgressHUD toastMessage:@"请在设置里正确填写好服务器地址" withImage:nil];
        return;
    }
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusAuthorized) {
        [ACProgressHUD toastMessage:@"请打开设想机权限" withImage:nil];
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self open:YES];
                });
            }
        }];
        return;
    }
    [self open:YES];
}

- (IBAction)connectScan:(UIButton *)sender
{
    if ([ACBScannerManager manager].autoUpload && ([ACBScannerManager manager].uploadUrl == nil || ![[ACBScannerManager manager].uploadUrl hasPrefix:@"http"])) {
        UIAlertController * alt = [UIAlertController alertControllerWithTitle:nil message:@"当前处于自动上传数据模式，请先正确填写好上传地址" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * act = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {}];
        [alt addAction:act];
        [self presentViewController:alt animated:YES completion:nil];
        return;
    }
    UIAlertController * alt = [UIAlertController alertControllerWithTitle:@"扫描枪名称" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alt addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入扫描枪名称";
        if ([ACBScannerManager getScannerName].length) {
            textField.text = [ACBScannerManager getScannerName];
        }
    }];
    UIAlertAction * act1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {}];
    UIAlertAction * act2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField * textField = alt.textFields[0];
        NSString * scannerName = textField.text;
        if (scannerName.length) {
            [ACBScannerManager setScannerName:scannerName];
            if (self.textField.text) {
                NSString * cubbId = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
                if (cubbId.length == 0) {
                    UIAlertAction * act = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                    UIAlertController * vc = [UIAlertController alertControllerWithTitle:@" ❗❗" message:@"请先输入中心设备服务名称" preferredStyle:UIAlertControllerStyleAlert];
                    [vc addAction:act];
                    [self presentViewController:vc animated:YES completion:nil];
                }else{
                    [ACBScannerManager manager].isLinkScanGun = YES;
                    CenterMachineTableViewController * vc = [[CenterMachineTableViewController alloc] initWithServiceName:cubbId];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
        }
    }];
    [alt addAction:act1];
    [alt addAction:act2];
    
    [self presentViewController:alt animated:YES completion:^{}];
}

- (void)fieldResignFirstResponder
{
    [self.textField resignFirstResponder];
    [self.operatorNameTextField resignFirstResponder];
    [self.operatorNumberTextField resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([textField isEqual:self.operatorNameTextField]) {
        [ACBScannerManager setOperatorName:str];
    }
    if ([textField isEqual:self.operatorNumberTextField]) {
        [ACBScannerManager setOperatorNumber:str];
    }
    return YES;
}

@end
