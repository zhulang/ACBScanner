//
//  ACBScannerCongfig.m
//  ACBScanner
//
//  Created by Achilles on 2019/5/25.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "ACBScannerCongfig.h"

@implementation ACBScannerCongfig

+ (instancetype)config
{
    static ACBScannerCongfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            NSDictionary * dic = [[NSUserDefaults standardUserDefaults] valueForKey:@"config"];
            instance = [ACBScannerCongfig mj_objectWithKeyValues:dic];
            if (instance == nil) {
                instance = [[ACBScannerCongfig alloc] init];
                PeripheralCongfig * peripheralConfig = [[PeripheralCongfig alloc] init];
                peripheralConfig.torchOn = YES;
                peripheralConfig.torchAuto = NO;
                peripheralConfig.brightness = 0.8;
                peripheralConfig.fps = 30;
                peripheralConfig.focusMode = 0;
                instance.peripheralConfig = peripheralConfig;
                CenterCongfig * centerConfig = [[CenterCongfig alloc] init];
                centerConfig.maxInterfaceNumber = 7;
                centerConfig.maxCacheNumber = 2000;
                centerConfig.uploadUrl = @"";
                centerConfig.dataUrl = @"";
                centerConfig.autoUpload = YES;
                instance.centerConfig = centerConfig;
                ScannerOperator * people = [[ScannerOperator alloc] init];
                people.name = @"";
                people.number = @"";
                instance.worker = people;
                [ACBScannerCongfig archiver:instance];
            }
        }
    });
    return instance;
}

+ (void)archiver:(ACBScannerCongfig *)config
{
    NSDictionary * dic = [config mj_keyValues];
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"config"];
}

+ (void)archiver
{
    ACBScannerCongfig * config = [ACBScannerCongfig config];
    NSDictionary * dic = [config mj_keyValues];
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"config"];
}

+ (instancetype)unArchiver
{
    NSDictionary * dic = [[NSUserDefaults standardUserDefaults] valueForKey:@"config"];
    ACBScannerCongfig * config = [ACBScannerCongfig mj_objectWithKeyValues:dic];
    return config;
}

+ (void)setCenterMaxInterfaceNumber:(NSInteger)number
{
    if ([ACBScannerCongfig config].centerConfig) {
        [ACBScannerCongfig config].centerConfig.maxInterfaceNumber = number;
    }
}

+ (void)setCenterMaxCacheNumber:(NSInteger)number
{
    if ([ACBScannerCongfig config].centerConfig) {
        [ACBScannerCongfig config].centerConfig.maxCacheNumber = number;
    }
}

+ (void)setCenterUploadUrl:(NSString *)uploadUrl
{
    if (uploadUrl && [ACBScannerCongfig config].centerConfig) {
        [ACBScannerCongfig config].centerConfig.uploadUrl = uploadUrl;
    }
}

+ (void)setCenterDataUrl:(NSString *)dataUrl
{
    if (dataUrl && [ACBScannerCongfig config].centerConfig) {
        [ACBScannerCongfig config].centerConfig.dataUrl = dataUrl;
    }
}

+ (void)setCenterAutoUpload:(BOOL)autoUpload
{
    if ([ACBScannerCongfig config].centerConfig) {
        [ACBScannerCongfig config].centerConfig.autoUpload = autoUpload;
    }
}

+ (void)setPeripheralBrightness:(float)brightness
{
    if ([ACBScannerCongfig config].peripheralConfig) {
        [ACBScannerCongfig config].peripheralConfig.brightness = brightness;
    }
}

+ (void)setPeripheralTorchOn:(BOOL)isOn
{
    if ([ACBScannerCongfig config].peripheralConfig) {
        [ACBScannerCongfig config].peripheralConfig.torchOn = isOn;
    }
}

+ (void)setPeripheralTorchAuto:(BOOL)isOn
{
    if ([ACBScannerCongfig config].peripheralConfig) {
        [ACBScannerCongfig config].peripheralConfig.torchAuto = isOn;
    }
}

+ (void)setPeripheralFps:(float)fps
{
    if ([ACBScannerCongfig config].peripheralConfig) {
        [ACBScannerCongfig config].peripheralConfig.fps = fps;
    }
}

+ (void)setPeripheralFocusMode:(ACBFocusMode)focusMode
{
    if ([ACBScannerCongfig config].peripheralConfig) {
        [ACBScannerCongfig config].peripheralConfig.focusMode = focusMode;
    }
}

+ (void)setOperatorName:(NSString *)name
{
    if (name && [ACBScannerCongfig config].worker) {
        [ACBScannerCongfig config].worker.name = name;
    }
}

+ (void)setOperatorNumber:(NSString *)numStr
{
    if (numStr && [ACBScannerCongfig config].worker) {
        [ACBScannerCongfig config].worker.number = numStr;
    }
}

@end
