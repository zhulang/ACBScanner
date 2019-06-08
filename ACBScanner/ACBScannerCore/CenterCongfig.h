//
//  CenterCongfig.h
//  ACBScanner
//
//  Created by 朱浪 on 2019/5/28.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CenterCongfig : NSObject

/**
 @ maxInterfaceNumber ,the value between 1 to 7 ,default is 7
 */
@property (nonatomic, assign) NSInteger maxInterfaceNumber;

/**
 @ maxCacheNumber ,the value between 100 to 20000 ,default is 2000
 */
@property (nonatomic, assign) NSInteger maxCacheNumber;

/**
 @ uploadUrl ,webservice url address
 @ eg. htttps://www.webservie.com
 */
@property (nonatomic, copy) NSString * uploadUrl;

/**
 @ dataUrl ,webservice url address. open the url to show data after uploaded data
 @ eg. htttps://www.webservice.com or htttp://www.115.239.211.112.org
 */
@property (nonatomic, copy) NSString * dataUrl;

/**
 @ autoUpload ,if set the value NO,the data will saved to you local device,defaut is NO
 */
@property (nonatomic, assign) BOOL autoUpload;

/**
 @ sannerName , the name of the really scanner which is not a mobile phone
 */
@property (nonatomic, copy) NSString * scannerName;

@end

NS_ASSUME_NONNULL_END

