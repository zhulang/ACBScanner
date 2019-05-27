//
//  ACBScannerCongfig.h
//  ACBScanner
//
//  Created by Achilles on 2019/5/25.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CenterCongfig : NSObject
@property (nonatomic, strong) NSNumber * maxInterfaceNumber;
@property (nonatomic, strong) NSNumber * maxCacheNumber;
@property (nonatomic, copy) NSString * uploadUrl;
@property (nonatomic, copy) NSString * dataUrl;
@end

@interface PeripheralCongfig : NSObject
@property (nonatomic, strong) NSNumber * brightness;
@property (nonatomic, strong) NSNumber * torchOn;
@property (nonatomic, strong) NSNumber * torchAuto;
@property (nonatomic, strong) NSNumber * fps;
@property (nonatomic, strong) NSNumber * focusMode;
@end

@interface ScannerOperator : NSObject
@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * number;
@end

@interface ACBScannerCongfig : NSObject

+ (void)setCenterMaxInterfaceNumber:(NSInteger)number;
+ (void)setCenterMaxCacheNumber:(NSInteger)number;
+ (void)setCenterUploadUrl:(NSString *)uploadUrl;
+ (void)setCenterDataUrl:(NSString *)dataUrl;;

+ (void)setPeripheralBrightness:(float)brightness;
+ (void)setPeripheralTorchOn:(BOOL)isOn;
+ (void)setPeripheralTorchAuto:(BOOL)isOn;
+ (void)setPeripheralFps:(float)fps;
+ (void)setPeripheralFocusMode:(NSInteger)focusMode;

+ (void)setOperatorName:(NSString *)name;
+ (void)setOperatorNumber:(NSString *)numStr;

+ (instancetype)config;
+ (instancetype)unArchiver;
+ (void)archiver;
+ (void)archiver:(ACBScannerCongfig *)config;

@property (nonatomic, strong) PeripheralCongfig * peripheralConfig;
@property (nonatomic, strong) CenterCongfig * centerConfig;
@property (nonatomic, strong) ScannerOperator * worker;
@end

NS_ASSUME_NONNULL_END
