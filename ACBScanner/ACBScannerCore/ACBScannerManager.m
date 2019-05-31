//
//  CenterMachineManager.m
//  ACBScanner
//
//  Created by Achilles on 2019/5/25.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "ACBScannerManager.h"
#import "MJExtension.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

static NSString * SERVICE_UUID = @"42AF46EB-296F-44FC-8C08-462FF5DE85E3";
static NSString * CHARACTERISTIC_UUID = @"42AF46EB-296F-44FC-8C08-462FF5DE85E8";

@interface ACBScannerManager () <CBPeripheralManagerDelegate,AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate,CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic,strong) ACBScannerCongfig * scannerConfig;
@property (nonatomic,strong) CBCharacteristic * _Nonnull currentCharacteristic;
//附设属性
@property (nonatomic,strong) CBCentral * central;
@property (nonatomic,strong) CBPeripheralManager * peripheralManager;
@property (nonatomic,strong) CBUUID * myCubbid;
@property (nonatomic,copy) NSString * code;
@property (nonatomic,strong) NSMutableArray * brightnessVlaueArr;
@property (nonatomic,strong) AVCaptureDevice * device;
@property (nonatomic,strong) AVCaptureDeviceInput * deviceInput;
@property (nonatomic,strong) AVCaptureMetadataOutput * metadataOutput;
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
//主设属性
@property (nonatomic,strong) CBCentralManager * manager;
@property (nonatomic,strong) NSMutableArray * peripheralArr;
@property (nonatomic,strong) NSMutableSet * peripheralUUIDSet;
@property (nonatomic,strong) NSMutableArray * resultData;

@end

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

#pragma mark - peripheral device methods
- (void)scanning
{
    if (self.serviceName == nil || self.peripheralDelegate == nil) {
        return;
    }
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    [self.session startRunning];
    if (self.peripheralDelegate && [self.peripheralDelegate respondsToSelector:@selector(peripheralDidStartScanning)]) {
        [self.peripheralDelegate peripheralDidStartScanning];
    }
}

- (void)stopScanning
{
    [self.session stopRunning];
    if (self.peripheralDelegate && [self.peripheralDelegate respondsToSelector:@selector(peripheralDidStopScanning)]) {
        [self.peripheralDelegate peripheralDidStopScanning];
    }
}

- (void)scanning:(NSString *)serviceName peripheralDelegate:(id<ACBScannerPeripheralDelegate>)viewController previewLayerFrame:(CGRect)previewLayerFrame
{
    self.serviceName = serviceName;
    self.peripheralDelegate = viewController;
    self.previewLayerFrame = previewLayerFrame;
    [self scanning];
}

- (AVCaptureSession *)session
{
    if (!_session) {
        self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
        
        self.session = [[AVCaptureSession alloc] init];
        self.session.sessionPreset = AVCaptureSessionPreset1920x1080;
        
        self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [self.session addOutput:self.metadataOutput];
        
        self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [self.videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        [self.session addOutput:self.videoDataOutput];
        
        [self.session addInput:self.deviceInput];
        
        self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
        
        self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.videoPreviewLayer.frame = self.previewLayerFrame;
        UIView * view = ((UIViewController *)self.peripheralDelegate).view;
        [view.layer insertSublayer:self.videoPreviewLayer atIndex:0];
    }
    return _session;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"metadataObjects - - %@", metadataObjects);
    if (metadataObjects != nil && metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        self.code = [obj stringValue];
        if (self.code) {
            [self.session stopRunning];
            [self sendData];
        }
    } else {
        if (self.peripheralDelegate && [self.peripheralDelegate respondsToSelector:@selector(peripheralRecogniseDidFail:)]) {
            [self.peripheralDelegate peripheralRecogniseDidFail:@"暂未识别出扫描的二维码"];
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (self.brightnessVlaueArr.count < 10) {
        CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
        NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
        CFRelease(metadataDict);
        NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
        float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
        NSLog(@"光源强度 %f",brightnessValue);
        @synchronized (self.brightnessVlaueArr) {
            [self.brightnessVlaueArr addObject:@(brightnessValue)];
        }
        if(self.brightnessVlaueArr.count == 10){
            [self initTorch];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self initTorch];
}

- (void)initTorch
{
    NSError *error = nil;
    BOOL locked = [self.device lockForConfiguration:&error];
    if (locked) {
        AVCaptureFocusMode focusMode;
        switch ([ACBScannerManager getPeripheralFocusMode]) {
            case ACBFocusModeLocked:
                focusMode = AVCaptureFocusModeLocked;
                break;
            case ACBFocusModeAutoFocus:
                focusMode = AVCaptureFocusModeAutoFocus;
                break;
            case ACBFocusModeContinuousAutoFocus:
                focusMode = AVCaptureFocusModeContinuousAutoFocus;
                break;
            default:
                focusMode = AVCaptureFocusModeLocked;
                break;
        }
        [self.device setFocusMode:focusMode];
        [self.device unlockForConfiguration];
    }
    
    if ([ACBScannerManager getPeripheralTorchOn]) {
        if ([ACBScannerManager getPeripheralTorchAuto]) {
            __block CGFloat brightness = 0;
            [self.brightnessVlaueArr enumerateObjectsUsingBlock:^(NSNumber *  _Nonnull num, NSUInteger idx, BOOL * _Nonnull stop) {
                brightness += [num floatValue];
            }];
            CGFloat average = brightness * 0.1;
            
            if (average > 5) {
                average = 0.01;
            }else if(average > 3){
                average = 0.5;
            }else{
                average = 1;
            }
            NSError *error = nil;
            if ([self.device hasTorch]) {
                BOOL locked = [self.device lockForConfiguration:&error];
                if (locked) {
                    [self.device setTorchMode:AVCaptureTorchModeOn];
                    [self.device setTorchModeOnWithLevel:average error:nil];
                    [self.device unlockForConfiguration];
                }
            }
        }else{
            NSError *error = nil;
            if ([self.device hasTorch]) {
                BOOL locked = [self.device lockForConfiguration:&error];
                if (locked) {
                    [self.device setTorchMode:AVCaptureTorchModeOn];
                    [self.device setTorchModeOnWithLevel:[ACBScannerManager getPeripheralBrightness] error:nil];
                    [self.device unlockForConfiguration];
                }
            }
        }
    }else{
        NSError *error = nil;
        if ([self.device hasTorch]) {
            BOOL locked = [self.device lockForConfiguration:&error];
            if (locked) {
                [self.device setTorchMode:AVCaptureTorchModeOff];
                [self.device unlockForConfiguration];
            }
        }
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    self.myCubbid = [CBUUID UUIDWithString:[UIDevice currentDevice].identifierForVendor.UUIDString];
    CBMutableService * service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:SERVICE_UUID] primary:YES];
    CBMutableCharacteristic * characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
    [service setCharacteristics:@[characteristic]];
    [self.peripheralManager addService:service];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:SERVICE_UUID]],CBAdvertisementDataLocalNameKey : [UIDevice currentDevice].name}];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    self.central = central;
    self.currentCharacteristic = characteristic;
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    
}

- (void)sendData
{
    if (self.serviceName == nil || self.code == nil) {
        return;
    }
    NSDateFormatter * dft = [[NSDateFormatter alloc] init];
    [dft setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDictionary * dataDic = @{self.serviceName:@{@"date":[dft stringFromDate:[NSDate date]],@"code":self.code,@"operator":self.scannerConfig.worker.name ? self.scannerConfig.worker.name : @"",@"jobNumber":self.scannerConfig.worker.number ? self.scannerConfig.worker.number : @""}};
    NSString * jsonString = [dataDic mj_JSONString];
    if (self.currentCharacteristic) {
        if ([self.peripheralManager updateValue:[jsonString dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.currentCharacteristic onSubscribedCentrals:nil]) {
            sleep(60.0 / [ACBScannerManager getPeripheralFps]);
            [self.session startRunning];
            self.code = nil;
            if (self.peripheralDelegate && [self.peripheralDelegate respondsToSelector:@selector(peripheralDidSendJsonString:status:)]) {
                [self.peripheralDelegate peripheralDidSendJsonString:jsonString status:YES];
            }
        }else{
            if (self.peripheralDelegate && [self.peripheralDelegate respondsToSelector:@selector(peripheralDidSendJsonString:status:)]) {
                [self.peripheralDelegate peripheralDidSendJsonString:jsonString status:NO];
            }
        }
    }
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    NSLog(@"peripheralManagerIsReadyToUpdateSubscribers");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    if (request.characteristic.properties & CBCharacteristicPropertyRead) {
        NSData * data = request.characteristic.value;
        [request setValue:data];
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }else{
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
    CBATTRequest * request = requests[0];
    if (request.characteristic.properties & CBCharacteristicPropertyWrite) {
        CBMutableCharacteristic * characteristic = (CBMutableCharacteristic *)request.characteristic;
        characteristic.value = request.value;
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }else{
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
    }
}

#pragma mark - center peripheral device methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStateUnknown:
            NSLog(@">>CBManagerStateUnknown");
            break;
        case CBManagerStateResetting:
            NSLog(@">>CBManagerStateResetting");
            break;
        case CBManagerStateUnsupported:
            NSLog(@">>CBManagerStateUnsupported");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@">>CBManagerStateUnauthorized");
            break;
        case CBManagerStatePoweredOff:
            NSLog(@">>CBManagerStatePoweredOff");
            break;
        case CBManagerStatePoweredOn:
            [self.manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_UUID]] options:nil];
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString * uuid = peripheral.identifier.UUIDString;
    if (![self.peripheralUUIDSet containsObject:uuid]) {
        @synchronized (self.peripheralUUIDSet) {
            [self.peripheralUUIDSet addObject:uuid];
            if (self.peripheralArr && self.peripheralArr.count < [ACBScannerManager getCenterMaxInterfaceNumber]) {
                [self.peripheralArr addObject:peripheral];
                [self.manager connectPeripheral:peripheral options:nil];
            }
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_UUID]]];
}

#pragma mark - CBPeripheralDelegate methods
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error
{
    for (CBService * service in peripheral.services)
    {
        NSString * serviceUuid = service.UUID.UUIDString;
        if ([serviceUuid isEqualToString:SERVICE_UUID]) {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:CHARACTERISTIC_UUID]] forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error
{
    for (CBCharacteristic * characteristic in service.characteristics)
    {
        NSString * characteristicUuid = characteristic.UUID.UUIDString;
        if ([characteristicUuid isEqualToString:CHARACTERISTIC_UUID])
        {
            self.currentCharacteristic = characteristic;
            [peripheral readValueForCharacteristic:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            [peripheral discoverDescriptorsForCharacteristic:characteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}

//获取值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (characteristic.value == nil || self.serviceName == nil) {
        return;
    }
    NSString * str  =[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSDictionary * dic = [str mj_JSONObject];
    if (dic == nil) {
        return;
    }
    NSDictionary * value = dic[self.serviceName];
    if (value) {
        @synchronized (self.resultData) {
            [self.resultData insertObject:value atIndex:0];
            if (self.centerMachineDelegate && [self.centerMachineDelegate respondsToSelector:@selector(centerPeripheralDidReadValueForCharacteristic:currentRecord:)]) {
                [self.centerMachineDelegate centerPeripheralDidReadValueForCharacteristic:self.resultData currentRecord:value];
            }
        }
    }
}

//中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (characteristic.isNotifying) {
        [peripheral readValueForCharacteristic:characteristic];
    } else {
        [self.manager cancelPeripheralConnection:peripheral];
    }
}

//数据写入成功回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    NSLog(@"数据写入成功！");
}

#pragma mark - setter methods
+ (void)setCenterMaxInterfaceNumber:(NSInteger)number
{
    if (manager.scannerConfig.centerConfig) {
        if (number < 1) {
            number = 1;
        }else if (number > 7){
            number = 7;
        }
        manager.scannerConfig.centerConfig.maxInterfaceNumber = number;
        [ACBScannerCongfig archiver];
    }
}

+ (void)setCenterMaxCacheNumber:(NSInteger)number
{
    if (manager.scannerConfig.centerConfig) {
        if (number < 100) {
            number = 100;
        }else if (number > 20000){
            number = 20000;
        }
        manager.scannerConfig.centerConfig.maxCacheNumber = number;
        [ACBScannerCongfig archiver];
    }
}

+ (void)setCenterUploadUrl:(NSString *)uploadUrl
{
    if (uploadUrl && manager.scannerConfig.centerConfig) {
        manager.scannerConfig.centerConfig.uploadUrl = uploadUrl;
        [ACBScannerCongfig archiver];
    }
}

+ (void)setCenterDataUrl:(NSString *)dataUrl
{
    if (dataUrl && manager.scannerConfig.centerConfig) {
        manager.scannerConfig.centerConfig.dataUrl = dataUrl;
        [ACBScannerCongfig archiver];
    }
}

+ (void)setCenterAutoUpload:(BOOL)autoUpload
{
    if (manager.scannerConfig.centerConfig) {
        manager.scannerConfig.centerConfig.autoUpload = autoUpload;
        [ACBScannerCongfig archiver];
    }
}

+ (void)setPeripheralBrightness:(float)brightness
{
    if (manager.scannerConfig.peripheralConfig) {
        if (brightness <= 0.01) {
            brightness = 0.01;
        }else if (brightness > 1){
            brightness = 1;
        }
        manager.scannerConfig.peripheralConfig.brightness = brightness;
        [ACBScannerCongfig archiver];
    }
}

+ (void)setPeripheralTorchOn:(BOOL)isOn
{
    if (manager.scannerConfig.peripheralConfig) {
        manager.scannerConfig.peripheralConfig.torchOn = isOn;
        [ACBScannerCongfig archiver];
    }
}

+ (void)setPeripheralTorchAuto:(BOOL)isOn
{
    if (manager.scannerConfig.peripheralConfig) {
        manager.scannerConfig.peripheralConfig.torchAuto = isOn;
        [ACBScannerCongfig archiver];
    }
}

+ (void)setPeripheralFps:(float)fps
{
    if (manager.scannerConfig.peripheralConfig) {
        if (fps < 1) {
            fps = 1;
        }else if (fps > 50){
            fps = 50;
        }
        manager.scannerConfig.peripheralConfig.fps = fps;
        [ACBScannerCongfig archiver];
    }
}

+ (void)setPeripheralFocusMode:(ACBFocusMode)focusMode
{
    if (manager.scannerConfig.peripheralConfig) {
        if (focusMode < ACBFocusModeLocked || focusMode > ACBFocusModeContinuousAutoFocus ) {
            return;
        }
        manager.scannerConfig.peripheralConfig.focusMode = focusMode;
        [ACBScannerCongfig archiver];
    }
}

+ (void)setOperatorName:(NSString *)name
{
    if (name && manager.scannerConfig.worker) {
        manager.scannerConfig.worker.name = name;
        [ACBScannerCongfig archiver];
    }
}

+ (void)setOperatorNumber:(NSString *)numStr
{
    if (numStr && manager.scannerConfig.worker) {
        manager.scannerConfig.worker.number = numStr;
        [ACBScannerCongfig archiver];
    }
}

#pragma mark - getter methods
+ (NSInteger)getCenterMaxCacheNumber
{
    if (manager.scannerConfig.centerConfig) {
        return manager.scannerConfig.centerConfig.maxCacheNumber;
    }
    return 2000;
}

+ (NSInteger)getCenterMaxInterfaceNumber
{
    if (manager.scannerConfig.centerConfig) {
        return manager.scannerConfig.centerConfig.maxInterfaceNumber;
    }
    return 7;
}

+ (NSString *)getCenterUploadUrl
{
    if (manager.scannerConfig.centerConfig) {
        return manager.scannerConfig.centerConfig.uploadUrl;
    }
    return @"";
}

+ (NSString *)getCenterDataUrl
{
    if (manager.scannerConfig.centerConfig) {
        return manager.scannerConfig.centerConfig.dataUrl;
    }
    return @"";
}

+ (BOOL)getCenterAutoUpload
{
    if (manager.scannerConfig.centerConfig) {
        return manager.scannerConfig.centerConfig.autoUpload;
    }
    return NO;
}

+ (float)getPeripheralBrightness
{
    if (manager.scannerConfig.peripheralConfig) {
        return manager.scannerConfig.peripheralConfig.brightness;
    }
    return 0.8;
}

+ (BOOL)getPeripheralTorchOn
{
    if (manager.scannerConfig.peripheralConfig) {
        return manager.scannerConfig.peripheralConfig.torchOn;
    }
    return NO;
}

+ (BOOL)getPeripheralTorchAuto
{
    if (manager.scannerConfig.peripheralConfig) {
        return manager.scannerConfig.peripheralConfig.torchAuto;
    }
    return NO;
}

+ (float)getPeripheralFps
{
    if (manager.scannerConfig.peripheralConfig) {
        return manager.scannerConfig.peripheralConfig.fps;
    }
    return 30;
}

+ (ACBFocusMode)getPeripheralFocusMode
{
    if (manager.scannerConfig.peripheralConfig) {
        return manager.scannerConfig.peripheralConfig.focusMode;
    }
    return ACBFocusModeLocked;
}

+ (NSString *)getOperatorName
{
    if (manager.scannerConfig.worker) {
        return manager.scannerConfig.worker.name;
    }
    return @"";
}

+ (NSString *)getOperatorNumber
{
    if (manager.scannerConfig.worker) {
        return manager.scannerConfig.worker.number;
    }
    return @"";
}

- (NSInteger)maxInterfaceNumber
{
    if (manager.scannerConfig.centerConfig)
        return manager.scannerConfig.centerConfig.maxInterfaceNumber;
    else
        return 7;
}

- (NSInteger)maxCacheNumber
{
    if (manager.scannerConfig.centerConfig)
        return manager.scannerConfig.centerConfig.maxCacheNumber;
    else
        return 2000;
}

- (NSString *)uploadUrl
{
    if (manager.scannerConfig.centerConfig)
        return manager.scannerConfig.centerConfig.uploadUrl;
    else
        return @"";
}

- (NSString *)dataUrl
{
    if (manager.scannerConfig.centerConfig)
        return manager.scannerConfig.centerConfig.dataUrl;
    else
        return @"";
}

- (BOOL)autoUpload
{
    if (manager.scannerConfig.centerConfig)
        return manager.scannerConfig.centerConfig.autoUpload;
    else
        return YES;
}

- (BOOL)torchOn
{
    if (manager.scannerConfig.peripheralConfig)
        return manager.scannerConfig.peripheralConfig.torchOn;
    else
        return YES;
}

- (BOOL)torchAuto
{
    if (manager.scannerConfig.peripheralConfig)
        return manager.scannerConfig.peripheralConfig.torchAuto;
    else
        return NO;
}

- (float)brightness
{
    if (manager.scannerConfig.peripheralConfig)
        return manager.scannerConfig.peripheralConfig.brightness;
    else
        return 0.8;
}

- (float)fps
{
    if (manager.scannerConfig.peripheralConfig)
        return manager.scannerConfig.peripheralConfig.fps;
    else
        return 30;
}

- (ACBFocusMode)focusMode
{
    return [ACBScannerManager getPeripheralFocusMode];
}

- (NSString *)operatorName
{
    if (manager.scannerConfig.worker)
        return manager.scannerConfig.worker.name;
    else
        return @"";
}

- (NSString *)operatorNumber
{
    if (manager.scannerConfig.worker)
        return manager.scannerConfig.worker.number;
    else
        return @"";
}

#pragma mark - archiver methods
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
