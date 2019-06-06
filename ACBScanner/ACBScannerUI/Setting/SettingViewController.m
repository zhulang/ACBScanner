//
//  SettingViewController.m
//  ACBScanner
//
//  Created by 朱浪 on 2019/6/6.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "SettingViewController.h"
#import "PeripheralSettingViewController.h"
#import "CenterMachineSettingViewController.h"
#import "ACBScannerManager.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设置中心";
    self.tableView.tableFooterView = [[UIView alloc] init];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        [ACBScannerManager resetConfig];
    }else{
        if (indexPath.row == 0) {
            CenterMachineSettingViewController * vc = [[CenterMachineSettingViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }else if(indexPath.row == 1){
            PeripheralSettingViewController * vc = [[PeripheralSettingViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24;
}

@end
