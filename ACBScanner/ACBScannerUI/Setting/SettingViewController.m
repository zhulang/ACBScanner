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
    self.navigationItem.title = @"设置";
    self.tableView.tableFooterView = [[UIView alloc] init];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        UIAlertController * vc = [UIAlertController alertControllerWithTitle:nil message:@"点击还原后，APP自动退出，重新打开APP时，还原的配置才会生效" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * sure = [UIAlertAction actionWithTitle:@"还原" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self resetConfig];
        }];
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [vc addAction:cancel];
        [vc addAction:sure];
        [self presentViewController:vc animated:YES completion:nil];
        
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
    if (section == 0) {
        return 0;
    }
    return 24;
}

- (void)resetConfig
{
    [ACBScannerManager resetConfig];
    [UIView beginAnimations:@"exitAPP" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view.window cache:NO];
    self.view.window.bounds = CGRectMake(0, 0, 0, 0);
    [UIView setAnimationDidStopSelector:@selector(exitAPP)];
    [UIView commitAnimations];
}

- (void)exitAPP
{
    exit(0);
}

@end
