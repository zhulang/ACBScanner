//
//  CenterMachineTableViewController.m
//  BScanner
//
//  Created by 朱浪 on 2019/5/23.
//  Copyright © 2019 朱浪. All rights reserved.
//

#import "CenterMachineTableViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "CenterMachineSettingViewController.h"
#import "CodeTableViewCell.h"
#import "ACBScannerManager.h"

static NSString * SERVICE_UUID = @"42AF46EB-296F-44FC-8C08-462FF5DE85E3";
static NSString * CHARACTERISTIC_UUID = @"42AF46EB-296F-44FC-8C08-462FF5DE85E8";

@interface CenterMachineTableViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate,ACBScannerCenterMachineDelegate>
@property (nonatomic,copy) NSString * serviceName;
@property (nonatomic,strong) CBCentralManager * manager;
@property (nonatomic,strong) NSMutableArray * peripheralArr;
@property (nonatomic,strong) NSMutableSet * peripheralUUIDSet;
@property (nonatomic,strong) NSMutableArray * resultData;
@property (nonatomic,strong) CBCharacteristic * currentCharacteristic;
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
    [ACBScannerManager manager].centerMachineDelegate = self;
    self.navigationItem.title = @"中心设备";
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(setting)],[[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(uploadData)]];
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CodeTableViewCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([CodeTableViewCell class])];
    self.peripheralArr = [NSMutableArray arrayWithCapacity:[ACBScannerManager getCenterMaxInterfaceNumber]];
    self.peripheralUUIDSet = [NSMutableSet set];
    self.resultData = [NSMutableArray array];
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCacheData:) name:@"clear.cache.data" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"clear.cache.data" object:nil];
}

- (void)clearCacheData:(NSNotification *)noti
{
    BOOL clear = [noti.object boolValue];
    if (clear) {
        @synchronized (self.resultData) {
            [self.resultData removeAllObjects];
        }
        [self.tableView reloadData];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self resetData];
}

- (void)resetData
{
    [self.peripheralArr enumerateObjectsUsingBlock:^(CBPeripheral *  _Nonnull peripheral, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.manager cancelPeripheralConnection:peripheral];
    }];
}

- (void)uploadData
{
    @synchronized (self.resultData) {
        [self.resultData removeAllObjects];
    }
    [self.tableView reloadData];
}

- (void)setting
{
    CenterMachineSettingViewController * vc = [CenterMachineSettingViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStateUnknown:
            NSLog(@">>CBManagerStateUnknown");
            break;
        case CBManagerStateResetting:
            NSLog(@">>CBManagerStateResetting");
            break;
        case CBManagerStateUnsupported:
            NSLog(@">>CBManagerStateUnsupported");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@">>CBManagerStateUnauthorized");
            break;
        case CBManagerStatePoweredOff:
            NSLog(@">>CBManagerStatePoweredOff");
            break;
        case CBManagerStatePoweredOn:
            [self.manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_UUID]] options:nil];
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString * uuid = peripheral.identifier.UUIDString;
    if (![self.peripheralUUIDSet containsObject:uuid]) {
        @synchronized (self.peripheralUUIDSet) {
            [self.peripheralUUIDSet addObject:uuid];
            if (self.peripheralArr && self.peripheralArr.count < [ACBScannerManager getCenterMaxInterfaceNumber]) {
                [self.peripheralArr addObject:peripheral];
                [self.manager connectPeripheral:peripheral options:nil];
            }
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_UUID]]];
}

#pragma mark - CBPeripheralDelegate methods
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error
{
    for (CBService * service in peripheral.services)
    {
        NSString * serviceUuid = service.UUID.UUIDString;
        if ([serviceUuid isEqualToString:SERVICE_UUID]) {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:CHARACTERISTIC_UUID]] forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error
{
    for (CBCharacteristic * characteristic in service.characteristics)
    {
        NSString * characteristicUuid = characteristic.UUID.UUIDString;
        if ([characteristicUuid isEqualToString:CHARACTERISTIC_UUID])
        {
            self.currentCharacteristic = characteristic;
            [peripheral readValueForCharacteristic:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            [peripheral discoverDescriptorsForCharacteristic:characteristic];
            [self.tableView reloadData];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}

#pragma mark - 获取值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (characteristic.value == nil || self.serviceName == nil) {
        return;
    }
    NSString * str  =[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSDictionary * dic = [str mj_JSONObject];
    if (dic == nil) {
        return;
    }
    NSDictionary * value = dic[self.serviceName];
    if (value) {
        @synchronized (self.resultData) {
            [self.resultData insertObject:value atIndex:0];
            [self.tableView reloadData];
        }
    }
}

#pragma mark - 中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (characteristic.isNotifying) {
        [peripheral readValueForCharacteristic:characteristic];
    } else {
        [self.manager cancelPeripheralConnection:peripheral];
    }
}

#pragma mark 数据写入成功回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    NSLog(@"数据写入成功！");
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
                cell.detailTextLabel.textColor = [UIColor blueColor];
                cell.detailTextLabel.text = @"连接中...";
                break;
            case CBPeripheralStateConnected:
                cell.detailTextLabel.textColor = [UIColor greenColor];
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
        NSDictionary * dic = self.resultData[indexPath.row];
        cell.info = dic;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
