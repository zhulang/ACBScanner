//
//  CodeTableViewCell.m
//  ACBScanner
//
//  Created by Achilles on 2019/5/25.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "CodeTableViewCell.h"
@interface CodeTableViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *goBtn;
@end

@implementation CodeTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.goBtn.layer.cornerRadius = 15;
    self.goBtn.clipsToBounds = YES;
    self.goBtn.layer.borderWidth = 0.5;
    self.goBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)setInfo:(NSDictionary *)info
{
    _info = info;
    NSString * code = info[@"code"];
    self.goBtn.hidden = ![code hasPrefix:@"http"];
    self.codeLabel.text = code;
    self.operatorLabel.text = [NSString stringWithFormat:@"员工：%@  工号：%@",info[@"operator"],info[@"jobNumber"]];
    self.dateLabel.text = info[@"date"];
}

- (IBAction)openUrl:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(openUrl:)]) {
        [self.delegate openUrl:_info[@"code"]];
    }
}

@end
