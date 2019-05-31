//
//  CenterMachineManager.h
//  ACBScanner
//
//  Created by Achilles on 2019/5/25.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACBScannerCongfig.h"
#import "MJExtension.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ACBScannerPeripheralDelegate <NSObject>

/**
 @ 附设设备发送数据后的回调
 @  status, YES (send data successful)
 */
- (void)peripheralDidSendJsonString:(NSString *)jsonString status:(BOOL)status;

/**
 @ 附设设备barcode失败回调方法
 */
- (void)peripheralRecogniseDidFail:(NSString *)errorDescription;

/**
 @ 附设停止扫描后回调的回调方法
 */
- (void)peripheralDidStopScanning;

/**
 @ 调用附设启动扫描后回调此方法
 */
- (void)peripheralDidStartScanning;

@end

@protocol ACBScannerCenterMachineDelegate <NSObject>

/**
 @ 成功写入值之后中心设备回调
 */
- (void)centerPeripheralDidReadValueForCharacteristic:(NSArray *)resultData currentRecord:(NSDictionary *)value;
@end


@interface ACBScannerManager : NSObject

- (void)scanning;

- (void)stopScanning;

- (void)scanning:(NSString *)serviceName peripheralDelegate:(id<ACBScannerPeripheralDelegate>)viewController previewLayerFrame:(CGRect)previewLayerFrame;

@property (nonatomic,assign) CGRect previewLayerFrame;

@property (nonatomic,copy) NSString * serviceName;

@property (nonatomic,weak) id<ACBScannerPeripheralDelegate> peripheralDelegate;

@property (nonatomic,weak) id<ACBScannerCenterMachineDelegate> centerMachineDelegate;

+ (instancetype)manager;

/**
 @ number ,the number of center machine connects. the value between 1 to 7 ,default is 7
 @ number ,设置中心设备连接数,最小值1,最大值7,默认值7
 */
+ (void)setCenterMaxInterfaceNumber:(NSInteger)number;
+ (NSInteger)getCenterMaxInterfaceNumber;

/**
 @ number ,cache data max number. the value between 100 to 20000 ,default is 2000
 @ number,设置最大缓存条数
 */
+ (void)setCenterMaxCacheNumber:(NSInteger)number;
+ (NSInteger)getCenterMaxCacheNumber;

/**
 @ uploadUrl ,webservice url address
 @ eg. htttps://www.webservie.com
 @ 设置缓存数据传地址
 */
+ (void)setCenterUploadUrl:(NSString *)uploadUrl;
+ (NSString *)getCenterUploadUrl;

/**
 @ dataUrl ,webservice url address.
 @ open the url to show data after uploaded data
 @ eg. htttps://www.webservice.com or htttp://www.115.239.211.112.org
 @ 设置上传数据后查看地址，没有必须要可以不用设置
 */
+ (void)setCenterDataUrl:(NSString *)dataUrl;
+ (NSString *)getCenterDataUrl;

/**
 @ autoUpload ,if set the value @(NO),the data will saved to you local device
 @ 设置中心设备是否在收到数据时自动将数据上传
 */
+ (void)setCenterAutoUpload:(BOOL)autoUpload;
+ (BOOL)getCenterAutoUpload;

/**
 @ brightness ,the value between 0.01 to 1 ,default is 0.5
 @ 设置补光亮度，值在0到1之间，默认值0.5
 */
+ (void)setPeripheralBrightness:(float)brightness;
+ (float)getPeripheralBrightness;

/**
 @ torchOn ,if set the value @(NO),the light will close,default is YES
 @ 设置是否开启补光
 */
+ (void)setPeripheralTorchOn:(BOOL)isOn;
+ (BOOL)getPeripheralTorchOn;

/**
 @ fps ,torchAuto is enable when set torchOn is YES,default is NO
 @ 设置扫描仪是否自动调节补光亮度。只有在补光开启后设置才有效
 */
+ (void)setPeripheralTorchAuto:(BOOL)isOn;
+ (BOOL)getPeripheralTorchAuto;

/**
 @ fps ,MAX value scanning times in 1 min. the value between 1 to 50 ,default is 40
 @ 设置每条扫描的最大记录条数
 */
+ (void)setPeripheralFps:(float)fps;
+ (float)getPeripheralFps;

/**
 @ focusMode ,ACCaptureFocusMode ,default is ACCaptureFocusModeLocked
 @ 设置扫描仪是否需要自动对焦
 */
+ (void)setPeripheralFocusMode:(ACBFocusMode)focusMode;
+ (ACBFocusMode)getPeripheralFocusMode;

/**
 @ name ,operator's name ,recommends not to set it too long
 @ 设置操作者名称
 */
+ (void)setOperatorName:(NSString *)name;
+ (NSString *)getOperatorName;

/**
 @ number ,operator's worknumber,recommends not to set it too long
 @ 设置操作者工号
 */
+ (void)setOperatorNumber:(NSString *)numStr;
+ (NSString *)getOperatorNumber;

// 具体参数请参阅getter methods和 setter methods说明
@property (nonatomic, assign) NSInteger maxInterfaceNumber;
@property (nonatomic, assign) NSInteger maxCacheNumber;
@property (nonatomic, copy) NSString * uploadUrl;
@property (nonatomic, copy) NSString * dataUrl;
@property (nonatomic, assign) BOOL autoUpload;
@property (nonatomic, assign) float brightness;
@property (nonatomic, assign) BOOL torchOn;
@property (nonatomic, assign) BOOL torchAuto;
@property (nonatomic, assign) float fps;
@property (nonatomic, assign) ACBFocusMode focusMode;
@property (nonatomic, copy) NSString * operatorName;
@property (nonatomic, copy) NSString * operatorNumber;

// save the data of the center device
// 中心设备上的保存的数据
@property (nonatomic,strong) NSMutableArray<NSDictionary *> * centerMachineCacheData;

// save the data of the peripheral device
// 扫描仪上的保存的数据
@property (nonatomic,strong) NSMutableArray<NSDictionary *> * peripheralMachineCacheData;

@end

NS_ASSUME_NONNULL_END
