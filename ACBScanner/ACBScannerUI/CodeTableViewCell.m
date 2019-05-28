//
//  CodeTableViewCell.m
//  ACBScanner
//
//  Created by Achilles on 2019/5/25.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "CodeTableViewCell.h"
@interface CodeTableViewCell ()

@end

@implementation CodeTableViewCell

- (void)setInfo:(NSDictionary *)info
{
    self.codeLabel.text = info[@"code"];
    self.operatorLabel.text = [NSString stringWithFormat:@"员工：%@  工号：%@",info[@"operator"],info[@"jobNumber"]];
    self.dateLabel.text = info[@"date"];
}

@end
