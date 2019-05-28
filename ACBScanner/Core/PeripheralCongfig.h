//
//  PeripheralCongfig.h
//  ACBScanner
//
//  Created by 朱浪 on 2019/5/28.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ACBFocusMode) {
    ACBFocusModeLocked         = 0,
    ACBFocusModeAutoFocus      = 1,
    ACBFocusModeContinuousAutoFocus = 2,
} API_AVAILABLE(macos(10.7), ios(4.0));

NS_ASSUME_NONNULL_BEGIN

@interface PeripheralCongfig : NSObject

/**
 @ brightness ,the value between 0 to 1 ,default is 0.8
 */
@property (nonatomic, assign) float brightness;

/**
 @ torchOn ,if set the value NO,the light will close,default is YES
 */
@property (nonatomic, assign) BOOL torchOn;

/**
 @ fps ,torchAuto is enable when set torchOn is YES,default is NO
 */
@property (nonatomic, assign) BOOL torchAuto;

/**
 @ fps ,MAX value scanning times in 1 min. the value between 1 to 50 ,default is 30
 */
@property (nonatomic, assign) float fps;

/**
 @ focusMode ,ACCaptureFocusMode ,default is ACCaptureFocusModeLocked
 */
@property (nonatomic, assign) ACBFocusMode focusMode;

@end

NS_ASSUME_NONNULL_END

