//
//  PeripheralCongfig.m
//  ACBScanner
//
//  Created by 朱浪 on 2019/5/28.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "PeripheralCongfig.h"
#import "ACBScannerCongfig.h"

@implementation PeripheralCongfig

- (void)setBrightness:(float)brightness
{
    _brightness = brightness;
}

- (void)setTorchOn:(BOOL)torchOn
{
    _torchOn = torchOn;
}

- (void)setTorchAuto:(BOOL)torchAuto
{
    _torchOn = torchAuto;
}

- (void)setFps:(float)fps
{
    _fps = fps;
}

- (void)setFocusMode:(ACBFocusMode)focusMode
{
    _focusMode = focusMode;
}

@end
