//
//  CenterMachineTableViewController.m
//  BScanner
//
//  Created by 朱浪 on 2019/5/23.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "CenterMachineTableViewController.h"
#import "CenterMachineSettingViewController.h"
#import "CodeTableViewCell.h"
#import <WatchDogSDK/ACBScannerManager.h>
#import "WKWebViewController.h"
#import "ACProgressHUD.h"

@interface CenterMachineTableViewController ()<ACBScannerCenterMachineDelegate,CodeTableViewCellDelegate>
@property (nonatomic,copy) NSString * serviceName;
@property (nonatomic,strong) NSMutableArray * peripheralArr;
@property (nonatomic,strong) NSMutableArray * resultData;
@end

@implementation CenterMachineTableViewController

- (instancetype)initWithServiceName:(NSString *)serviceName
{
    self = [super init];
    if (self) {
        self.serviceName = serviceName;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"中心设备";
    
    if([ACBScannerManager manager].autoUpload == NO)
    {
        self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(uploadData)]];
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CodeTableViewCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([CodeTableViewCell class])];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 300;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[ACBScannerManager manager] initCenterMachineManager:self.serviceName delegate:self];
    self.resultData = [NSMutableArray array];
    [self.resultData addObjectsFromArray:[[ACBScannerManager manager] getResultData]];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[ACBScannerManager manager] stopScanningPeripheral];
}

- (void)uploadData
{
    [ACBScannerManager uploadData:^(BOOL success, NSString * _Nonnull description) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.resultData = [NSMutableArray arrayWithCapacity:0];
                [self.tableView reloadData];
                [ACProgressHUD toastScuess:description];
            }else{
                [ACProgressHUD toastMessage:description withImage:nil];
            }
        });
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.peripheralArr.count;
    }
    if (section == 1) {
        return self.resultData.count;
    }
    return 0;
}

static  NSString * peripheralCell = @"CenterMachineTableViewController";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:peripheralCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:peripheralCell];
        }
        CBPeripheral * peripheral = self.peripheralArr[indexPath.row];
        cell.textLabel.text = peripheral.name ? peripheral.name : peripheral.identifier.UUIDString;
        switch (peripheral.state) {
            case CBPeripheralStateDisconnected:
                cell.detailTextLabel.textColor = [UIColor redColor];
                cell.detailTextLabel.text = @"点击重新连接";
                break;
            case CBPeripheralStateConnecting:
                cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                cell.detailTextLabel.text = @"连接中...";
                break;
            case CBPeripheralStateConnected:
                cell.detailTextLabel.textColor = [UIColor blueColor];
                cell.detailTextLabel.text = @"已连接";
                break;
            case CBPeripheralStateDisconnecting:
                cell.detailTextLabel.textColor = [UIColor yellowColor];
                cell.detailTextLabel.text = @"正在取消连接";
                break;
            default:
                break;
        }
        return cell;
    }else if (indexPath.section == 1) {
        CodeTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CodeTableViewCell class]) forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([CodeTableViewCell class]) owner:self options:nil] lastObject];
        }
        cell.delegate = self;
        NSDictionary * dic = self.resultData[indexPath.row];
        cell.info = dic[self.serviceName];
        return cell;
    }else{
        return [UITableViewCell new];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView * view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"view"];
    if (view == nil) {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"view"];
    }
    view.textLabel.text = section == 0 ? [NSString stringWithFormat:@"扫描到 %zd 个设备",self.peripheralArr.count] : @"接收到的数据";
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        UITableViewHeaderFooterView * view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"viewForFooter"];
        if (view == nil) {
            view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"viewForFooter"];
            view.contentView.backgroundColor = [UIColor whiteColor];
        }
        return view;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return section == 0 ? 8 : 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral * peripheral = self.peripheralArr[indexPath.row];
    if (peripheral.state == CBPeripheralStateDisconnected) {
        [[ACBScannerManager manager] connectPeripheral:peripheral];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - ACBScannerCenterMachineDelegate methods
//自动上传模式，数据上传后的回调
- (void)didUpload:(NSData *)data response:(NSURLResponse * _Nullable)response error:(NSError * _Nullable)error
{
    NSString * str = [NSString stringWithFormat:@"statusCode: %zd",((NSHTTPURLResponse *)response).statusCode];
    [ACProgressHUD toastMessage:str withImage:nil];
}

- (void)centralDidUpdateStatePoweredOn
{
    [[ACBScannerManager manager] beginScanningPeripheral];
}

- (void)centralForPeripheralsUpdate:(NSMutableArray<CBPeripheral *> *)peripheralArr
{
    [ACProgressHUD toastScuess:@"发现了新设备"];
    self.peripheralArr = peripheralArr;
    [self.tableView reloadData];
}

- (void)centralDidConnectPeripheral:(CBPeripheral *)peripheral
{
    [self.tableView reloadData];
}

- (void)centralForPeripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error
{
    
}

- (void)centralDidReadValueForCharacteristic:(NSDictionary *)currentRecord
{
    [ACProgressHUD toastScuess:@"有了新数据"];
    [self.resultData insertObject:currentRecord atIndex:0];
    [self.tableView reloadData];
}

- (void)centralForPeripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
   [ACProgressHUD toastScuess:@"写入数据成功"];
}

- (void)centralDidFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%@",@"centralDidFailToConnectPeripheral");
    [self removePeripheral:peripheral];
    [self.tableView reloadData];
}

- (void)centralDidDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error complete:(nonnull void (^)(NSMutableArray * _Nonnull))handler
{
//    [self removePeripheral:peripheral];
//    handler(self.peripheralArr);
    [self.tableView reloadData];
}

- (void)removePeripheral:(CBPeripheral *)peripheral
{
    if ([self.peripheralArr containsObject:peripheral]) {
        NSMutableArray * arr = [NSMutableArray arrayWithArray:self.peripheralArr];
        [arr removeObject:peripheral];
        self.peripheralArr = arr;
    }
}

#pragma mark - Codecelldelegate methods
- (void)openUrl:(NSString *)url
{
    WKWebViewController * vc = [[WKWebViewController alloc] init];
    vc.url = url;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
