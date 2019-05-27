//
//  PeripheralSettingViewController.m
//  ACBScanner
//
//  Created by Achilles on 2019/5/26.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "PeripheralSettingViewController.h"
#import "ACBScannerCongfig.h"
@interface PeripheralSettingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *torchLabel;
@property (weak, nonatomic) IBOutlet UISwitch *torchSwitch;
@property (weak, nonatomic) IBOutlet UILabel *torchAutoLabel;
@property (weak, nonatomic) IBOutlet UISwitch *torchAutoSwitch;
@property (weak, nonatomic) IBOutlet UILabel *lightBrightnessLabel;
@property (weak, nonatomic) IBOutlet UISlider *lightBrightnessSlider;
@property (strong, nonatomic) ACBScannerCongfig * config;
@property (weak, nonatomic) IBOutlet UILabel *fpsLabel;
@property (weak, nonatomic) IBOutlet UISlider *fpsSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *focusModeSegmentedControl;
@end

@implementation PeripheralSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"扫描仪参数设置";
    self.config = [ACBScannerCongfig config];
    self.lightBrightnessSlider.value = [self.config.peripheralConfig.brightness floatValue];
    self.lightBrightnessLabel.text = [NSString stringWithFormat:@"手动调节补光亮度：%.2f",self.lightBrightnessSlider.value];
    self.torchSwitch.on = [self.config.peripheralConfig.torchOn boolValue];
    self.torchLabel.text = [NSString stringWithFormat:@"补光：%@",self.torchSwitch.on ? @"开" : @"关"];
    self.torchAutoSwitch.on = [self.config.peripheralConfig.torchAuto boolValue] && self.torchSwitch.on;
    self.torchAutoSwitch.enabled = self.torchSwitch.on;
    self.torchAutoLabel.text = [NSString stringWithFormat:@"自动调节补光亮度：%@",self.torchAutoSwitch.on ? @"开" : @"关"];
    self.fpsSlider.value = [self.config.peripheralConfig.fps floatValue];
    self.fpsLabel.text = [NSString stringWithFormat:@"每分钟扫描次数：%.0f",self.fpsSlider.value];
    self.focusModeSegmentedControl.selectedSegmentIndex = [self.config.peripheralConfig.focusMode integerValue];
}

- (IBAction)torchSwitchValueDidChange:(UISwitch *)sender {
    if (sender.on) {
        self.torchAutoSwitch.enabled = YES;
    }else{
        self.torchAutoSwitch.on = NO;
        self.torchAutoSwitch.enabled = NO;
    }
    self.config.peripheralConfig.torchAuto = @(self.torchAutoSwitch.on);
    self.config.peripheralConfig.torchOn = @(sender.on);
    self.torchLabel.text = [NSString stringWithFormat:@"补光：%@",self.torchSwitch.on ? @"开" : @"关"];
    [ACBScannerCongfig archiver:self.config];
}

- (IBAction)autoTorchDidChange:(UISwitch *)sender {
    self.config.peripheralConfig.torchAuto = @(sender.on);
    self.torchAutoLabel.text = [NSString stringWithFormat:@"自动调节补光亮度：%@",self.torchAutoSwitch.on ? @"开" : @"关"];
    [ACBScannerCongfig archiver:self.config];
}

- (IBAction)lightBrightnessDidChange:(UISlider *)sender {
    
    self.config.peripheralConfig.brightness = @(sender.value);
    self.lightBrightnessLabel.text = [NSString stringWithFormat:@"手动调节补光亮度：%.2f",self.lightBrightnessSlider.value];
    [ACBScannerCongfig archiver:self.config];
}

- (IBAction)fpsSliderValueDidChange:(UISlider *)sender {
    self.config.peripheralConfig.fps = @(sender.value);
    self.fpsLabel.text = [NSString stringWithFormat:@"手动调节补光亮度：%.2f",self.fpsSlider.value];
    [ACBScannerCongfig archiver:self.config];
}

- (IBAction)focusValueDidChange:(UISegmentedControl *)sender {
    self.config.peripheralConfig.focusMode = @(sender.selectedSegmentIndex);
    [ACBScannerCongfig archiver:self.config];
}

@end
