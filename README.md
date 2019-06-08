
WatchDog
===
----
## 项目介绍
* WatchDog可以用来做什么?

	1.WatchDog可以用来扫描所看到的二维码或条形码，将二维码或条形码以明文形式展示于手机中，也可以将二维码或条形码以明文形式上传到服务器
		
	2.当身边没有没有扫描枪时，可以用打开WatchDog扫描，并且如果不需要中心设备可以在直接上传到服务器
		
	3.打开WatchDog，将WatchDog APP作为中心设备，可以接收外部设备扫描到的数据
	
	4.在没有网络情况下，打开WatchDog APP作为中心设备，也可以接收外部设备传来的数据
	
	5.WatchDog可以存储扫描到的数据
	
	6.WatchDog可以连接部分蓝牙扫描枪(不是手机)，并接收扫描枪传递的数据
	

## 使用说明
* 什么样场景需要使用WatchDog？
   
   可以在以下几种情形下使用WatchDog

   1.没有网络时，但想传递扫描到的二维码或条形码数据
		
	2.当二维码或条形码所处环境光线很暗时，普通手机APP扫描无法识别
	
	3.需要几个外部扫描设备，同时向中心设备传输数据
	
	4.传统扫描枪使用距离受限制时
	
	5.二维码或条形码打印质量不好，可以被识别但不易被识别的时候
		
	6.想使用手机扫码，或想用手机收集其他扫描设备扫描到的数据
	
* WatchDog有什么注意事项

	1.使用时必须打开蓝牙
	
	2.当使用WatchDog作为中心设备临时存储数据时，最好不要距离外设太远
	
	3.WatchDog提供了补光的功能，如果光线强的情况下，建议关闭补光，以节省手机用电，只有在光线很暗时建议才开启。
	
	4.当手机不使用WatchDog时，建议关闭蓝牙，省电
	
	5.WatchDog只会对相邻两次扫描结果排重。如果间隔很久再次扫描同一个二维码或条形码，数据同样会被收集或传输
	
	6.WatchDog只支持部分蓝牙扫描枪相连接，目前已知的品牌有科密。
	
## 链接
APP链接：[APP链接][1]

SDK链接：[SDK链接][2]
	
## 开发者文档

* WatchDog 的基本原理

	WatchDog 是基于蓝牙开发的。外设必须支持蓝牙4.0才能与之相连接。当选择自上传模式时，扫描到二维码直接将扫描的结果，传输到服务器，不需要和其他设备交互。
		
* 模式介绍

	中心设备 - 模式：将手机作为中心设备，手机其他手机扫描到的结果。
	
	扫描仪 - 模式：将手机作为扫描仪，将扫描结果传输到中心设备。
	
	自上传 - 模式：将手机作为扫描仪，将扫描结果直接传输到服务器。

	连接扫描枪 - 模式：将手机作为中心设备，收集扫描枪传来的数据。
	
		注意事项：中心设备 和 扫描仪 模式 配对使用，一对多模式。

* 快速集成

	以 自上传 模式 为例
	
	1.在AppDelegate.m中 导入ACBScannerManager.h文件，在方法：- (BOOL)application:(UIApplication *)application里实现以下代码
	
		[ACBScannerManager manager];
	2.在跳转入口处添加以下代码，PeripheralMachineTableViewController 是扫描窗口页面
	
		[ACBScannerManager manager].uploadSelf = uploadSelf;
            PeripheralMachineTableViewController * vc = [[PeripheralMachineTableViewController alloc] initWithServiceName:cubbId];
            [self.navigationController pushViewController:vc animated:YES];
    
    3.实现扫描窗口页面 PeripheralMachineTableViewController

		- (void)viewDidAppear:(BOOL)animated
		{
		    [super viewDidAppear:animated];
		    [[ACBScannerManager manager] initPeripheralManager:self.serviceName delegate:self preview:self.view previewLayerFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
		    [[ACBScannerManager manager] beginScanningBarCode:YES];
		}
		
		- (void)viewDidDisappear:(BOOL)animated
		{
		    [super viewDidDisappear:animated];
		    [[ACBScannerManager manager] stopScanningBarCode];
		}

	4.扫描窗口页面 PeripheralMachineTableViewController 实现 ACBScannerPeripheralDelegate 代理方法
	
		#pragma mark - ACBScannerPeripheralDelegate methods
		//选择自上传时根据需要决定是否实现此方法
		- (void)didUpload:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error
		{
		    NSString * str = [NSString stringWithFormat:@"statusCode: %zd",((NSHTTPURLResponse *)response).statusCode];
		 
		}
		
		//自上传 模式，此方法可以不用实现
		- (void)peripheralDidSendJsonString:(nonnull NSString *)jsonString status:(BOOL)status {
		    if (status == YES) {
		        NSDictionary * dic = [jsonString mj_JSONObject];
		        NSDictionary * info = dic[self.serviceName];
		        NSString * code = info[@"code"];
		    }
		}
		
		
* API

	isLinkScanGun
	
	是否连接外部真实版扫描枪，用于连接扫描枪模式
	
	uploadSelf 
	
	如果设置为YES,由当前设备将扫描到数据上传 ，用于自上传模式
	
	serviceName 
	
	中心设备服务名称，除真实扫描枪以外，其他配置或模式下的设备都需要填写服务名称
	
	ACBScannerPeripheralDelegate 
	
	外设代理方法，当选取 扫描仪 或 自上传 模式时，需要实现这个代理方法集

	ACBScannerCenterMachineDelegate 
	
	中心代理方法，当选取 中心设备 或 连接扫描枪 模式时，需要实现这个代理方法集
	
	连接指定的外部设备
	
		-(void)connectPeripheral:(CBPeripheral *)peripheral;

	获取中心设备的所有保存的扫描结果
			
		- (NSMutableArray *)getResultData;

	移除所有服务
	
		- (void)removeAllServices;

	初始化中心设备
	
		- (void)initCenterMachineManager:(NSString *)serviceName delegate:(id<ACBScannerCenterMachineDelegate>)viewController;
		
	初始化外设
	
		- (void)initPeripheralManager:(NSString *)serviceName delegate:(id<ACBScannerPeripheralDelegate>)viewController preview:(UIView *)preview previewLayerFrame:(CGRect)previewLayerFrame;
		
	具体属性、代理方法、类方法和实例方法的详细介绍，请参考下方代码
	
		- (void)connectPeripheral:(CBPeripheral *)peripheral;

		- (NSMutableArray *)getResultData;
		
		- (void)removeAllServices;
		
		//开始扫描条码或二维码
		- (void)beginScanningBarCode:(BOOL)resetTorch;
		
		//停止扫描条码或二维码
		- (void)stopScanningBarCode;
		
		/**
		 @ serviceName，服务名称
		 @ viewController，附设代理
		 @ preview，扫描区域载体
		 @ previewLayerFrame，扫描区域位置
		 */
		- (void)initPeripheralManager:(NSString *)serviceName delegate:(id<ACBScannerPeripheralDelegate>)viewController preview:(UIView *)preview previewLayerFrame:(CGRect)previewLayerFrame;
		
		
		//开始扫描附设
		- (void)beginScanningPeripheral;
		
		//停止扫描外设
		- (void)stopScanningPeripheral;
		
		/**
		 @ serviceName，服务名称
		 @ viewController，中心设备代理
		 */
		- (void)initCenterMachineManager:(NSString *)serviceName delegate:(id<ACBScannerCenterMachineDelegate>)viewController;
		
		@property (nonatomic,assign) CGRect previewLayerFrame;
		
		//服务名称
		@property (nonatomic,copy) NSString * serviceName;
		
		//附设代理
		@property (nonatomic,weak) id<ACBScannerPeripheralDelegate> peripheralDelegate;
		
		//中设代理
		@property (nonatomic,weak) id<ACBScannerCenterMachineDelegate> centerMachineDelegate;
		
		+ (void)uploadData:(void (^)(BOOL success,NSString * description))handler;
		
		+ (instancetype)manager;
		
		//还原配置，还原配置后需要退出APP，重新打开生效
		+ (void)resetConfig;
		
		/**
		 @ number ,the number of center machine connects. the value between 1 to 7 ,default is 7
		 @ number ,设置中心设备连接数,最小值1,最大值7,默认值7
		 */
		+ (void)setCenterMaxInterfaceNumber:(NSInteger)number;
		+ (NSInteger)getCenterMaxInterfaceNumber;
		
		/**
		 @ number ,cache data max number. the value between 100 to 20000 ,default is 2000
		 @ number,设置最大缓存条数
		 */
		+ (void)setCenterMaxCacheNumber:(NSInteger)number;
		+ (NSInteger)getCenterMaxCacheNumber;
		
		/**
		 @ uploadUrl ,webservice url address
		 @ eg. htttps://www.webservie.com
		 @ 设置缓存数据传地址
		 */
		+ (void)setCenterUploadUrl:(NSString *)uploadUrl;
		+ (NSString *)getCenterUploadUrl;
		
		/**
		 @ dataUrl ,webservice url address.
		 @ open the url to show data after uploaded data
		 @ eg. htttps://www.webservice.com or htttp://www.115.239.211.112.org
		 @ 设置上传数据后查看地址，没有必须要可以不用设置
		 */
		+ (void)setCenterDataUrl:(NSString *)dataUrl;
		+ (NSString *)getCenterDataUrl;
		
		/**
		 @ autoUpload ,if set the value @(NO),the data will saved to you local device
		 @ 设置中心设备是否在收到数据时自动将数据上传
		 */
		+ (void)setCenterAutoUpload:(BOOL)autoUpload;
		+ (BOOL)getCenterAutoUpload;
		
		/**
		 @ sannerName , the name of the really scanner which is not a mobile phone
		 @ 设置扫描枪名称
		 */
		+ (void)setScannerName:(NSString *)scannerName;
		+ (NSString *)getScannerName;
		
		/**
		 @ brightness ,the value between 0.01 to 1 ,default is 0.5
		 @ 设置补光亮度，值在0到1之间，默认值0.5
		 */
		+ (void)setPeripheralBrightness:(float)brightness;
		+ (float)getPeripheralBrightness;
		
		/**
		 @ torchOn ,if set the value @(NO),the light will close,default is YES
		 @ 设置是否开启补光
		 */
		+ (void)setPeripheralTorchOn:(BOOL)isOn;
		+ (BOOL)getPeripheralTorchOn;
		
		/**
		 @ fps ,torchAuto is enable when set torchOn is YES,default is NO
		 @ 设置扫描仪是否自动调节补光亮度。只有在补光开启后设置才有效
		 */
		+ (void)setPeripheralTorchAuto:(BOOL)isOn;
		+ (BOOL)getPeripheralTorchAuto;
		
		/**
		 @ fps ,MAX value scanning times in 1 min. the value between 1 to 50 ,default is 40
		 @ 设置每条扫描的最大记录条数
		 */
		+ (void)setPeripheralFps:(float)fps;
		+ (float)getPeripheralFps;
		
		/**
		 @ focusMode ,ACCaptureFocusMode ,default is ACCaptureFocusModeLocked
		 @ 设置扫描仪是否需要自动对焦
		 */
		+ (void)setPeripheralFocusMode:(ACBFocusMode)focusMode;
		+ (ACBFocusMode)getPeripheralFocusMode;
		
		/**
		 @ name ,operator's name ,recommends not to set it too long
		 @ 设置操作者名称
		 */
		+ (void)setOperatorName:(NSString *)name;
		+ (NSString *)getOperatorName;
		
		/**
		 @ number ,operator's worknumber,recommends not to set it too long
		 @ 设置操作者工号
		 */
		+ (void)setOperatorNumber:(NSString *)numStr;
		+ (NSString *)getOperatorNumber;
		
		/**
		 @ isLinkScanGun,link the real scanner gun which is not a mobile phone
		 @ 是否连接外部真实版扫描枪
		 */
		@property (nonatomic, assign) BOOL isLinkScanGun;
		
		/**
		 @ if uploadSelf == YES,upload data to service by the current device
		 @ 如果设置为YES,由当前设备将扫描到数据上传
		 */
		@property (nonatomic, assign) BOOL uploadSelf;
		
		/**
		 @ the max value of center machine connects
		 @ 中心设备连接数
		 */
		@property (nonatomic, assign) NSInteger maxInterfaceNumber;
		
		/**
		 @ cache data max number
		 @ 最大缓存条数
		 */
		@property (nonatomic, assign) NSInteger maxCacheNumber;
		
		/**
		 @ webservice url address
		 @ 缓存数据传地址
		 */
		@property (nonatomic, copy) NSString * uploadUrl;
		
		/**
		 @ webservice url address.
		 @ 上传数据后查看地址
		 */
		@property (nonatomic, copy) NSString * dataUrl;
		
		/**
		 @ if set the value NO,the data will saved to you local device
		 @ 中心设备是否在收到数据时自动将数据上传
		 */
		@property (nonatomic, assign) BOOL autoUpload;
		
		/**
		 @ sannerName , the name of the really scanner which is not a mobile phone
		 @ 扫描枪名称
		 */
		@property (nonatomic, copy) NSString * sannerName;
		
		/**
		 @ brightness
		 @ 设置补光亮度
		 */
		@property (nonatomic, assign) float brightness;
		
		/**
		 @ if set the value NO,the light will close,default is YES
		 @ 是否开启补光
		 */
		@property (nonatomic, assign) BOOL torchOn;
		
		/**
		 @ torchAuto is enable when set torchOn is YES,default is NO
		 @ 扫描仪是否自动调节补光亮度。只有在补光开启后设置才有效
		 */
		@property (nonatomic, assign) BOOL torchAuto;
		
		/**
		 @ MAX value scanning times in 1 min. the value between 1 to 50 ,default is 40
		 @ 每条扫描的最大记录条数
		 */
		@property (nonatomic, assign) float fps;
		
		/**
		  @ ACCaptureFocusMode ,default is ACCaptureFocusModeLocked
		  @ 扫描仪是否需要自动对焦
		  */
		@property (nonatomic, assign) ACBFocusMode focusMode;
		
		// operator's name ,recommends not to set it too long
		// 操作者名称
		@property (nonatomic, copy) NSString * operatorName;
		
		// operator's worknumber,recommends not to set it too long
		// 设置操作者工号
		@property (nonatomic, copy) NSString * operatorNumber;
		
		// save the data of the center device
		// 中心设备上的保存的数据
		@property (nonatomic,strong) NSMutableArray<NSDictionary *> * centerMachineCacheData;
		
		// save the data of the peripheral device
		// 扫描仪上的保存的数据
		@property (nonatomic,strong) NSMutableArray<NSDictionary *> * peripheralMachineCacheData;
 

<!-- 文件 -->
[1]: https://www.baidu.com/
[2]: /Users/Achilles/Desktop/JOYN资源/ios.txt 
<!-- 指令 -->
