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

@end
