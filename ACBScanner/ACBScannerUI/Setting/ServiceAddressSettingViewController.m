//
//  ServiceAddressSettingViewController.m
//  ACBScanner
//
//  Created by Achilles on 2019/6/8.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "ServiceAddressSettingViewController.h"
#import "ACBScannerManager.h"

@interface ServiceAddressSettingViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *uploadUrltextField;
@property (weak, nonatomic) IBOutlet UITextField *dataUrltextField;
@end

@implementation ServiceAddressSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设置服务器地址";
    UITapGestureRecognizer * tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fieldResignFirstResponder)];
    [self.view addGestureRecognizer:tapView];
    self.uploadUrltextField.text = [ACBScannerManager manager].uploadUrl;
    self.dataUrltextField.text = [ACBScannerManager manager].dataUrl;
    self.uploadUrltextField.delegate = self;
    self.dataUrltextField.delegate = self;
    self.uploadUrltextField.keyboardType = UIKeyboardTypeURL;
    self.dataUrltextField.keyboardType = UIKeyboardTypeURL;
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

@end
