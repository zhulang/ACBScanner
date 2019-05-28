//
//  ACBScannerCongfig.h
//  ACBScanner
//
//  Created by Achilles on 2019/5/25.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PeripheralCongfig.h"
#import "CenterCongfig.h"
#import "ScannerOperator.h"
#import "MJExtension.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACBScannerCongfig : NSObject

/**
 @ number ,the value between 1 to 7 ,default is 7
 */
+ (void)setCenterMaxInterfaceNumber:(NSInteger)number;

/**
 @ number ,,the value between 100 to 20000 ,default is 2000
 */
+ (void)setCenterMaxCacheNumber:(NSInteger)number;

/**
 @ uploadUrl ,webservice url address
 @ eg. htttps://www.webservie.com
 */
+ (void)setCenterUploadUrl:(NSString *)uploadUrl;

/**
 @ dataUrl ,webservice url address.
 @ open the url to show data after uploaded data
 @ eg. htttps://www.webservice.com or htttp://www.115.239.211.112.org
 */
+ (void)setCenterDataUrl:(NSString *)dataUrl;

/**
 @ autoUpload ,if set the value @(NO),the data will saved to you local device
 */
+ (void)setCenterAutoUpload:(BOOL)autoUpload;

/**
 @ brightness ,the value between 0 to 1 ,default is 0.5
 */
+ (void)setPeripheralBrightness:(float)brightness;

/**
 @ torchOn ,if set the value @(NO),the light will close,default is YES
 */
+ (void)setPeripheralTorchOn:(BOOL)isOn;

/**
 @ fps ,torchAuto is enable when set torchOn is YES,default is NO
 */
+ (void)setPeripheralTorchAuto:(BOOL)isOn;

/**
 @ fps ,MAX value scanning times in 1 min. the value between 1 to 50 ,default is 40
 */
+ (void)setPeripheralFps:(float)fps;

/**
 @ focusMode ,ACCaptureFocusMode ,default is ACCaptureFocusModeLocked
 */
+ (void)setPeripheralFocusMode:(ACBFocusMode)focusMode;

/**
 @ name ,operator's name ,recommends not to set it too long
 */
+ (void)setOperatorName:(NSString *)name;

/**
 @ number ,operator's worknumber,recommends not to set it too long
 */
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
