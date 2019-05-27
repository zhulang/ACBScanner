//
//  CenterMachineManager.m
//  ACBScanner
//
//  Created by Achilles on 2019/5/25.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "CenterMachineManager.h"

@implementation CenterMachineManager

+ (instancetype)shareCenterMachineManager
{
    static CenterMachineManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CenterMachineManager alloc] init];
    });
    return manager;
}

@end
