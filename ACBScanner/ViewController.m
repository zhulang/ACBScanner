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

@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextField *operatorNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *operatorNumberTextField;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *centerMachineButton;
@property (weak, nonatomic) IBOutlet UIButton *peripheralMachineButton;
@property (strong, nonatomic) ACBScannerCongfig *config;
@end

@implementation ViewController

- (void)viewDidLoad
{
    self.config = [ACBScannerCongfig config];
    UITapGestureRecognizer * tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fieldResignFirstResponder)];
    [self.view addGestureRecognizer:tapView];
    self.textField.text = @"999";
    self.operatorNameTextField.text = self.config.worker.name;
    self.operatorNumberTextField.text = self.config.worker.number;
    self.tipLabel.text =
     @"使用说明：\n"
     @"1.中心设备服务名称为必填项。\n"
     @"2.中心设备设置，当前页面->中心设备->设置。\n"
     @"3.扫描仪设置，当前页面->扫描仪->设置。";
    self.centerMachineButton.layer.cornerRadius = 4;
    self.centerMachineButton.clipsToBounds = YES;
    self.peripheralMachineButton.layer.cornerRadius = 4;
    self.peripheralMachineButton.clipsToBounds = YES;
    
    self.centerMachineButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.centerMachineButton.titleLabel.numberOfLines = 0;
    [self.centerMachineButton setTitle:@"中心设备\n（Center Machine）" forState:UIControlStateNormal];
    
    self.peripheralMachineButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.peripheralMachineButton.titleLabel.numberOfLines = 0;
    [self.peripheralMachineButton setTitle:@"扫描仪\n（Scanner）" forState:UIControlStateNormal];
    
    self.operatorNumberTextField.delegate = self;
    self.operatorNameTextField.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self fieldResignFirstResponder];
}

- (IBAction)asCenterMachine:(UIButton *)sender {
    if (self.textField.text) {
        NSString * cubbId = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (cubbId.length == 0) {
            UIAlertAction * act = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            UIAlertController * vc = [UIAlertController alertControllerWithTitle:@" ❗❗" message:@"请先输入中心设备服务名称" preferredStyle:UIAlertControllerStyleAlert];
            [vc addAction:act];
            [self presentViewController:vc animated:YES completion:nil];
        }else{
            CenterMachineTableViewController * vc = [[CenterMachineTableViewController alloc] initWithServiceName:cubbId];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (IBAction)asViceMachine:(UIButton *)sender {
    if (self.textField.text) {
        NSString * cubbId = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (cubbId.length == 0) {
            UIAlertAction * act = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            UIAlertController * vc = [UIAlertController alertControllerWithTitle:@" ❗❗" message:@"请先输入中心设备服务名称" preferredStyle:UIAlertControllerStyleAlert];
            [vc addAction:act];
            [self presentViewController:vc animated:YES completion:nil];
        }else{
            PeripheralMachineTableViewController * vc = [[PeripheralMachineTableViewController alloc] initWithServiceName:cubbId];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
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
        [ACBScannerCongfig config].worker.name = str;
        [ACBScannerCongfig archiver];
    }
    if ([textField isEqual:self.operatorNumberTextField]) {
        [ACBScannerCongfig config].worker.number = str;
        [ACBScannerCongfig archiver];
    }
    return YES;
}

@end
