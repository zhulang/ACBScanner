//
//  PeripheralSettingViewController.m
//  ACBScanner
//
//  Created by Achilles on 2019/5/26.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "PeripheralSettingViewController.h"
#import "ACBScannerManager.h"

@interface PeripheralSettingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *torchLabel;
@property (weak, nonatomic) IBOutlet UISwitch *torchSwitch;
@property (weak, nonatomic) IBOutlet UILabel *torchAutoLabel;
@property (weak, nonatomic) IBOutlet UISwitch *torchAutoSwitch;
@property (weak, nonatomic) IBOutlet UILabel *lightBrightnessLabel;
@property (weak, nonatomic) IBOutlet UISlider *lightBrightnessSlider;
@property (weak, nonatomic) IBOutlet UILabel *fpsLabel;
@property (weak, nonatomic) IBOutlet UISlider *fpsSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *focusModeSegmentedControl;
@end

@implementation PeripheralSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"扫描仪参数设置";
    self.lightBrightnessSlider.value = [ACBScannerManager getPeripheralBrightness];
    self.lightBrightnessLabel.text = [NSString stringWithFormat:@"手动调节补光亮度：%.2f",self.lightBrightnessSlider.value];
    self.torchSwitch.on = [ACBScannerManager getPeripheralTorchOn];
    self.torchLabel.text = [NSString stringWithFormat:@"补光：%@",self.torchSwitch.on ? @"开" : @"关"];
    self.torchAutoSwitch.on = [ACBScannerManager getPeripheralTorchAuto] && self.torchSwitch.on;
    self.torchAutoSwitch.enabled = self.torchSwitch.on;
    self.torchAutoLabel.text = [NSString stringWithFormat:@"自动调节补光亮度：%@",self.torchAutoSwitch.on ? @"开" : @"关"];
    self.fpsSlider.value = [ACBScannerManager getPeripheralFps];
    self.fpsLabel.text = [NSString stringWithFormat:@"每分钟扫描次数：%.0f",self.fpsSlider.value];
    self.focusModeSegmentedControl.selectedSegmentIndex = [ACBScannerManager getPeripheralFocusMode];
}

- (IBAction)torchSwitchValueDidChange:(UISwitch *)sender
{
    if (sender.on) {
        self.torchAutoSwitch.enabled = YES;
        self.torchAutoSwitch.on = [ACBScannerManager getPeripheralTorchAuto];
    }else{
        self.torchAutoSwitch.on = NO;
        self.torchAutoSwitch.enabled = NO;
    }
    [ACBScannerManager setPeripheralTorchOn:sender.on];
    self.torchLabel.text = [NSString stringWithFormat:@"补光：%@",self.torchSwitch.on ? @"开" : @"关"];
}

- (IBAction)autoTorchDidChange:(UISwitch *)sender
{
    [ACBScannerManager setPeripheralTorchAuto:sender.on];
    self.torchAutoLabel.text = [NSString stringWithFormat:@"自动调节补光亮度：%@",self.torchAutoSwitch.on ? @"开" : @"关"];
}

- (IBAction)lightBrightnessDidChange:(UISlider *)sender
{
    [ACBScannerManager setPeripheralBrightness:sender.value];
    self.lightBrightnessLabel.text = [NSString stringWithFormat:@"手动调节补光亮度：%.2f",self.lightBrightnessSlider.value];
}

- (IBAction)fpsSliderValueDidChange:(UISlider *)sender
{
    [ACBScannerManager setPeripheralFps:sender.value];
    self.fpsLabel.text = [NSString stringWithFormat:@"手动调节补光亮度：%.2f",self.fpsSlider.value];
}

- (IBAction)focusValueDidChange:(UISegmentedControl *)sender
{
    [ACBScannerManager setPeripheralFocusMode:sender.selectedSegmentIndex];
}

@end
