//
//  ViceMachineTableViewController.m
//  BScanner
//
//  Created by 朱浪 on 2019/5/23.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "PeripheralMachineTableViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "PeripheralSettingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ACBScannerManager.h"

static NSString * SERVICE_UUID = @"42AF46EB-296F-44FC-8C08-462FF5DE85E3";
static NSString * CHARACTERISTIC_UUID = @"42AF46EB-296F-44FC-8C08-462FF5DE85E8";

@interface PeripheralMachineTableViewController ()<ACBScannerPeripheralDelegate>
//<CBPeripheralManagerDelegate,AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
//@property (nonatomic,strong) CBCentral * central;
//@property (nonatomic,strong) CBPeripheralManager * peripheralManager;
//@property (nonatomic,strong) CBUUID * myCubbid;
@property (nonatomic,copy) NSString * serviceName;
//@property (nonatomic,copy) NSString * code;
//@property (nonatomic,copy) NSString * operator;
//@property (nonatomic,copy) NSString * jobNumber;
//@property (nonatomic,strong) CBMutableCharacteristic * _Nonnull currentCharacteristic;
//@property (nonatomic,strong) NSMutableArray * brightnessVlaueArr;
//@property (nonatomic,strong) AVCaptureDevice * device;
//@property (nonatomic,strong) AVCaptureDeviceInput * deviceInput;
//@property (nonatomic,strong) AVCaptureMetadataOutput * metadataOutput;
//@property (nonatomic,strong) AVCaptureSession *session;
//@property (nonatomic,strong) AVCaptureVideoDataOutput *videoDataOutput;
//@property (nonatomic,strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@end

@implementation PeripheralMachineTableViewController

- (instancetype)initWithServiceName:(NSString *)serviceName
{
    self = [super init];
    if (self) {
        self.serviceName = serviceName;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [ACBScannerManager manager].peripheralDelegate = self;
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    [ACBScannerManager manager].previewLayerFrame = CGRectMake(0, 0, w, h);
    self.navigationItem.title = @"扫描仪";
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(setting)]];
}

- (void)setting
{
    PeripheralSettingViewController * vc = [[PeripheralSettingViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end

//
//- (AVCaptureSession *)session
//{
//    if (!_session) {
//        self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//
//        self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
//
//        self.session = [[AVCaptureSession alloc] init];
//        self.session.sessionPreset = AVCaptureSessionPreset1920x1080;
//
//        self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
//        [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
//        [self.session addOutput:self.metadataOutput];
//
//        self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
//        [self.videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
//        [self.session addOutput:self.videoDataOutput];
//
//        [self.session addInput:self.deviceInput];
//
//        self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
//
//        self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
//        self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//        CGFloat x = 0;
//        CGFloat y = 0;
//        CGFloat w = [UIScreen mainScreen].bounds.size.width;
//        CGFloat h = [UIScreen mainScreen].bounds.size.height;
//        self.videoPreviewLayer.frame = CGRectMake(x, y, w, h);
//        [self.view.layer insertSublayer:self.videoPreviewLayer atIndex:0];
//    }
//    return _session;
//}
//
//- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
//    NSLog(@"metadataObjects - - %@", metadataObjects);
//    if (metadataObjects != nil && metadataObjects.count > 0) {
//        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
//        self.code = [obj stringValue];
//        if (self.code) {
//            [self.session stopRunning];
//            [self sendData];
//        }
//    } else {
//        NSLog(@"暂未识别出扫描的二维码");
//    }
//}
//
//- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//    if (self.brightnessVlaueArr.count < 10) {
//        CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
//        NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
//        CFRelease(metadataDict);
//        NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
//        float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
//        NSLog(@"光源强度 %f",brightnessValue);
//        @synchronized (self.brightnessVlaueArr) {
//            [self.brightnessVlaueArr addObject:@(brightnessValue)];
//        }
//        if(self.brightnessVlaueArr.count == 10){
//            [self initTorch];
//        }
//    }
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    [self initTorch];
//}
//
//- (void)initTorch
//{
//    NSError *error = nil;
//    BOOL locked = [self.device lockForConfiguration:&error];
//    if (locked) {
//        AVCaptureFocusMode focusMode;
//        switch ([ACBScannerManager getPeripheralFocusMode]) {
//            case ACBFocusModeLocked:
//                focusMode = AVCaptureFocusModeLocked;
//                break;
//            case ACBFocusModeAutoFocus:
//                focusMode = AVCaptureFocusModeAutoFocus;
//                break;
//            case ACBFocusModeContinuousAutoFocus:
//                focusMode = AVCaptureFocusModeContinuousAutoFocus;
//                break;
//            default:
//                focusMode = AVCaptureFocusModeLocked;
//                break;
//        }
//        [self.device setFocusMode:focusMode];
//        [self.device unlockForConfiguration];
//    }
//
//    if ([ACBScannerManager getPeripheralTorchOn]) {
//        if ([ACBScannerManager getPeripheralTorchAuto]) {
//            __block CGFloat brightness = 0;
//            [self.brightnessVlaueArr enumerateObjectsUsingBlock:^(NSNumber *  _Nonnull num, NSUInteger idx, BOOL * _Nonnull stop) {
//                brightness += [num floatValue];
//            }];
//            CGFloat average = brightness * 0.1;
//
//            if (average > 5) {
//                average = 0.01;
//            }else if(average > 3){
//                average = 0.5;
//            }else{
//                average = 1;
//            }
//            NSError *error = nil;
//            if ([self.device hasTorch]) {
//                BOOL locked = [self.device lockForConfiguration:&error];
//                if (locked) {
//                    [self.device setTorchMode:AVCaptureTorchModeOn];
//                    [self.device setTorchModeOnWithLevel:average error:nil];
//                    [self.device unlockForConfiguration];
//                }
//            }
//        }else{
//            NSError *error = nil;
//            if ([self.device hasTorch]) {
//                BOOL locked = [self.device lockForConfiguration:&error];
//                if (locked) {
//                    [self.device setTorchMode:AVCaptureTorchModeOn];
//                    [self.device setTorchModeOnWithLevel:[ACBScannerManager getPeripheralBrightness] error:nil];
//                    [self.device unlockForConfiguration];
//                }
//            }
//        }
//    }else{
//        NSError *error = nil;
//        if ([self.device hasTorch]) {
//            BOOL locked = [self.device lockForConfiguration:&error];
//            if (locked) {
//                [self.device setTorchMode:AVCaptureTorchModeOff];
//                [self.device unlockForConfiguration];
//            }
//        }
//    }
//}
//
//- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
//{
//    self.myCubbid = [CBUUID UUIDWithString:[UIDevice currentDevice].identifierForVendor.UUIDString];
//    CBMutableService * service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:SERVICE_UUID] primary:YES];
//    CBMutableCharacteristic * characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
//    [service setCharacteristics:@[characteristic]];
//    [self.peripheralManager addService:service];
//}
//
//- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
//{
//    [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:SERVICE_UUID]],CBAdvertisementDataLocalNameKey : [UIDevice currentDevice].name}];
//}
//
//- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
//{
//
//}
//
//- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
//{
//    self.central = central;
//    self.currentCharacteristic = characteristic;
//}
//
//- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
//{
//
//}
//
//- (void)sendData
//{
//    if (self.serviceName == nil || self.code == nil) {
//        return;
//    }
//    NSDateFormatter * dft = [[NSDateFormatter alloc] init];
//    [dft setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDictionary * dataDic = @{self.serviceName:@{@"date":[dft stringFromDate:[NSDate date]],@"code":self.code,@"operator":self.operator ? self.operator : @"",@"jobNumber":self.jobNumber ? self.jobNumber : @""}};
//    NSString * jsonString = [dataDic mj_JSONString];
//    if (self.currentCharacteristic) {
//        if ([self.peripheralManager updateValue:[jsonString dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.currentCharacteristic onSubscribedCentrals:nil]) {
//            sleep(60.0 / [ACBScannerManager getPeripheralFps]);
//            [self.session startRunning];
//            self.code = nil;
//        }
//    }
//}
//
//- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
//{
//    NSLog(@"peripheralManagerIsReadyToUpdateSubscribers");
//}
//
//- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
//    if (request.characteristic.properties & CBCharacteristicPropertyRead) {
//        NSData * data = request.characteristic.value;
//        [request setValue:data];
//        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
//    }else{
//        [self.peripheralManager respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
//    }
//}
//
//- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
//    CBATTRequest * request = requests[0];
//    if (request.characteristic.properties & CBCharacteristicPropertyWrite) {
//        CBMutableCharacteristic * characteristic = (CBMutableCharacteristic *)request.characteristic;
//        characteristic.value = request.value;
//        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
//    }else{
//        [self.peripheralManager respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
//    }
//}
