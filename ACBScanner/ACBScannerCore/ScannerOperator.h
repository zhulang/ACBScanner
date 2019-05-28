//
//  ScannerOperator.h
//  ACBScanner
//
//  Created by 朱浪 on 2019/5/28.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScannerOperator : NSObject

/**
 @ name ,operator's name ,recommends not to set it too long
 */
@property (nonatomic, copy) NSString * name;

/**
 @ number ,operator's worknumber,recommends not to set it too long
 */
@property (nonatomic, copy) NSString * number;

@end

NS_ASSUME_NONNULL_END
