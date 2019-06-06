//
//  CodeTableViewCell.h
//  ACBScanner
//
//  Created by Achilles on 2019/5/25.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CodeTableViewCellDelegate <NSObject>

- (void)openUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_BEGIN

@interface CodeTableViewCell : UITableViewCell
@property (nonatomic,strong) NSDictionary * info;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UILabel *operatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) id<CodeTableViewCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
