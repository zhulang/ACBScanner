//
//  CenterMachineManager.m
//  ACBScanner
//
//  Created by Achilles on 2019/5/25.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "ACBScannerManager.h"
#import "MJExtension.h"
#import "ACBScannerCongfig.h"

@implementation ACBScannerManager

static ACBScannerManager * manager = nil;
static dispatch_once_t onceToken;

+ (instancetype)manager
{
    dispatch_once(&onceToken, ^{
        manager = [[ACBScannerManager alloc] init];
        manager.scannerConfig = [ACBScannerCongfig config];
    });
    return manager;
}

+ (void)setCenterMaxInterfaceNumber:(NSInteger)number
{
    if (manager.scannerConfig.centerConfig) {
        manager.scannerConfig.centerConfig.maxInterfaceNumber = number;
    }
}

+ (void)setCenterMaxCacheNumber:(NSInteger)number
{
    if (manager.scannerConfig.centerConfig) {
        manager.scannerConfig.centerConfig.maxCacheNumber = number;
    }
}

+ (void)setCenterUploadUrl:(NSString *)uploadUrl
{
    if (uploadUrl && manager.scannerConfig.centerConfig) {
        manager.scannerConfig.centerConfig.uploadUrl = uploadUrl;
    }
}

+ (void)setCenterDataUrl:(NSString *)dataUrl
{
    if (dataUrl && manager.scannerConfig.centerConfig) {
        manager.scannerConfig.centerConfig.dataUrl = dataUrl;
    }
}

+ (void)setCenterAutoUpload:(BOOL)autoUpload
{
    if (manager.scannerConfig.centerConfig) {
        manager.scannerConfig.centerConfig.autoUpload = autoUpload;
    }
}

+ (void)setPeripheralBrightness:(float)brightness
{
    if (manager.scannerConfig.peripheralConfig) {
        manager.scannerConfig.peripheralConfig.brightness = brightness;
    }
}

+ (void)setPeripheralTorchOn:(BOOL)isOn
{
    if (manager.scannerConfig.peripheralConfig) {
        manager.scannerConfig.peripheralConfig.torchOn = isOn;
    }
}

+ (void)setPeripheralTorchAuto:(BOOL)isOn
{
    if (manager.scannerConfig.peripheralConfig) {
        manager.scannerConfig.peripheralConfig.torchAuto = isOn;
    }
}

+ (void)setPeripheralFps:(float)fps
{
    if (manager.scannerConfig.peripheralConfig) {
        manager.scannerConfig.peripheralConfig.fps = fps;
    }
}

+ (void)setPeripheralFocusMode:(ACBFocusMode)focusMode
{
    if (manager.scannerConfig.peripheralConfig) {
        manager.scannerConfig.peripheralConfig.focusMode = focusMode;
    }
}

+ (void)setOperatorName:(NSString *)name
{
    if (name && manager.scannerConfig.worker) {
        manager.scannerConfig.worker.name = name;
    }
}

+ (void)setOperatorNumber:(NSString *)numStr
{
    if (numStr && manager.scannerConfig.worker) {
        manager.scannerConfig.worker.number = numStr;
    }
}

+ (void)archiver:(ACBScannerCongfig *)config
{
    NSDictionary * dic = [config mj_keyValues];
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"config"];
}

+ (void)archiver
{
    if (manager.scannerConfig) {
        NSDictionary * dic = [manager.scannerConfig mj_keyValues];
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"config"];
    }else{
        ACBScannerCongfig * config = [ACBScannerCongfig config];
        NSDictionary * dic = [config mj_keyValues];
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"config"];
    }
}

@end
