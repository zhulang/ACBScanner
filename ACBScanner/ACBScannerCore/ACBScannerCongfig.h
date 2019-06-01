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

+ (instancetype)config;
+ (void)archiver;
+ (void)archiver:(ACBScannerCongfig *)config;
@property (nonatomic, strong) PeripheralCongfig * peripheralConfig;
@property (nonatomic, strong) CenterCongfig * centerConfig;
@property (nonatomic, strong) ScannerOperator * worker;
@end

NS_ASSUME_NONNULL_END
