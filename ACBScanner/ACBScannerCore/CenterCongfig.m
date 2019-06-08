//
//  CenterCongfig.m
//  ACBScanner
//
//  Created by 朱浪 on 2019/5/28.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "CenterCongfig.h"
#import "ACBScannerCongfig.h"

@implementation CenterCongfig

- (void)setMaxInterfaceNumber:(NSInteger)maxInterfaceNumber
{
    _maxInterfaceNumber = maxInterfaceNumber;
}

- (void)setMaxCacheNumber:(NSInteger)maxCacheNumber
{
    _maxCacheNumber = maxCacheNumber;
}

- (void)setUploadUrl:(NSString *)uploadUrl
{
    _uploadUrl = uploadUrl;
}

- (void)setDataUrl:(NSString *)dataUrl
{
    _dataUrl = dataUrl;
}

- (void)setAutoUpload:(BOOL)autoUpload
{
    _autoUpload = autoUpload;
}

- (void)setScannerName:(NSString *)scannerName
{
    _scannerName = scannerName;
}

@end
