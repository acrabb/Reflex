//
//  ViewController.m
//  Reflex
//
//  Created by André Crabb on 11/30/13.
//  Copyright (c) 2013 Andre Crabb. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


/* TODO
 Add searching view and timeout.
 Add data received to model storage.
 View model data in history view.
 Add graph to history view.
 */



NSString *OFF_LABEL         = @"Enable Bluetooth";
NSString *START_TEST_LABEL  = @"Start Test";
NSString *END_TEST_LABEL    = @"Cancel Test";
NSString *READING_DATA      = @"Reading data...";
NSString *SEARCHING_LABEL   = @"Searching...";
NSString *CLEARED_LABEL     = @"--";


const NSInteger STATUS_BT_OFF       = 0;
const NSInteger STATUS_DISCONNECTED = 1;
const NSInteger STATUS_SEARCHING    = 2;
const NSInteger STATUS_CONNECTED    = 3;
const NSInteger STATUS_TESTING      = 4;
const NSInteger STATUS_READING      = 5;
int status = -1;

NSString *const DeviceName = @"Reflex X1";

@synthesize myModel         = _myModel;
@synthesize myManager       = _myManager;
//@synthesize statusLabel     = _statusLabel;
@synthesize multiButton     = _multiButton;
@synthesize historyButton   = _historyButton;
@synthesize resetButton     = _resetButton;
@synthesize periph          = _periph;

@synthesize hammerStrengthLabel = _hammerStrengthLabel;
@synthesize reflexLatLabel      = _reflexLatLabel;
@synthesize reflexStrLabel      = _reflexStrLabel;

bool onlyOurDevice = true;
NSTimer *connectTimer;


//-----------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.myModel = [LQRModel sharedInstance];
    self.myManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pretty.jpg"]];
    [self.multiButton.layer setCornerRadius:5.0];
    [self.resetButton.layer setCornerRadius:5.0];
    [self.historyButton.layer setCornerRadius:5.0];
    [self.reflexLatLabel.layer setCornerRadius:5.0];
    [self.reflexStrLabel.layer setCornerRadius:5.0];
    [self.hammerStrengthLabel.layer setCornerRadius:5.0];
    status = -1;
}

//-----------------------------------------------------------------------
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


//-------------------------------------------------------------------------
- (void) alertWithTitle:(NSString*)title andMessage:(NSString*)message
{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                message:message
                delegate:nil
                cancelButtonTitle:@"Ok"
                otherButtonTitles: nil];
    [alert show];
    
}


//-------------------------------------------------------------------------
- (void)connect
{
    NSDictionary *scanOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                 forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    NSArray *services;
    if (onlyOurDevice) {
        services = [NSArray arrayWithObject:self.myModel.uuidDeviceService];
    } else {
        services = nil;
    }
    NSLog(@">> Scanning for peripherals...");
    [self startConnectTimer];
    [self.myManager scanForPeripheralsWithServices:services options:scanOptions];
    
    status = STATUS_SEARCHING;
    [self updateStatus];
}

//-------------------------------------------------------------------------
- (void)startConnectTimer;
{
    if (connectTimer == nil) {
        connectTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self
                                                      selector:@selector(timerCompletion) userInfo:nil
                                                       repeats:false];
        NSLog(@"Timer> Starting timer.");
    }
}
//-------------------------------------------------------------------------
- (void)timerCompletion;
{
    NSLog(@"Timer> Timer completed");
    if (connectTimer != nil && status==STATUS_SEARCHING) {
        [connectTimer invalidate];
        connectTimer = nil;
        status = STATUS_DISCONNECTED;
        [self updateStatus];
        [self alertWithTitle:@"Connection Timeout" andMessage:@"We couldn't find the reflex device."];
    }
}
//-------------------------------------------------------------------------
- (void)endTest;
{
    if (self.periph != nil) {
        [self.myManager cancelPeripheralConnection:self.periph];
    }
}


- (IBAction)resetTapped:(UIButton *)sender {
    [self.hammerStrengthLabel setText:CLEARED_LABEL];
    [self.reflexStrLabel setText:CLEARED_LABEL];
    [self.reflexLatLabel setText:CLEARED_LABEL];
}
//-----------------------------------------------------------------------
- (IBAction)multiButtonTapped:(UIButton*)sender {
    NSLog(@">> Multi button tapped: %@", sender.titleLabel.text);
       switch (status) {
        case STATUS_BT_OFF:
            [self alertWithTitle:@"Enable Bluetooth" andMessage:@"Please enable bluetooth in settings to continue."];
            break;
        case STATUS_DISCONNECTED:
              [self connect];
            break;
        case STATUS_SEARCHING:
            break;
        case STATUS_CONNECTED:
               [self endTest];
            break;
//        case STATUS_TESTING:
//            break;
        case STATUS_READING:
            break;
       }
}
//-----------------------------------------------------------------------
- (void)updateStatus;
{
    NSString *statusText;
    NSString *buttonTitle;
    switch (status) {
        case STATUS_BT_OFF:
            statusText = @"BT is off";
            buttonTitle = OFF_LABEL;
            self.multiButton.userInteractionEnabled = true;
            break;
        case STATUS_DISCONNECTED:
            statusText = @"Disconnected";
            buttonTitle = START_TEST_LABEL;
            self.multiButton.userInteractionEnabled = true;
            break;
        case STATUS_SEARCHING:
            statusText = @"Searching...";
            buttonTitle = SEARCHING_LABEL;
            self.multiButton.userInteractionEnabled = false;
            break;
        case STATUS_CONNECTED:
            statusText = [NSString stringWithFormat: @"Connected to %@", self.periph.name];
            buttonTitle = END_TEST_LABEL;
            self.multiButton.userInteractionEnabled = true;
            break;
//        case STATUS_TESTING:
//            statusText = @"Testing";
//            buttonTitle = testing;
//            break;
        case STATUS_READING:
            statusText = @"BT is off";
            buttonTitle = OFF_LABEL;
            self.multiButton.userInteractionEnabled = true;
            break;
    }
//    self.statusLabel.text = statusText;
    [self.multiButton setTitle:buttonTitle forState:UIControlStateNormal];
//    [self.multiButton setNeedsDisplay];
}


#pragma mark Central Manager Delegate
//-------------------------------------------------------------------------
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    NSLog(@"LQR> Looking for UUID: %@", self.myModel.uuidDevice);
    NSLog(@"LQR> Advertisement...:%@",[advertisementData description]);
    NSLog(@">>> >> ...for peripheral:%@\n", peripheral);
    NSLog(@"LQR> FOUND ONE!");
    self.periph = peripheral;
    [self.myManager connectPeripheral:self.periph options:nil];
    [self.myManager stopScan];
}
//-------------------------------------------------------------------------
- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"!LQR> Did connect peripheral: %@", [peripheral description]);
}
//-------------------------------------------------------------------------
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"LQR> Did connect peripheral: %@", [peripheral description]);
    self.periph = peripheral;
    self.periph.delegate = self;
//    if (onlyOurDevice) {
//        [self.periph discoverServices:[NSArray arrayWithObject:self.myModel.uuidService]];
//    } else {
//        [self.periph discoverServices:nil];
//    }
    [self.periph discoverServices:nil];
    
    status = STATUS_CONNECTED;
    [self updateStatus];
}
//-------------------------------------------------------------------------
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"LQR> Did DISconnect peripheral: %@", [peripheral description]);
    self.periph = nil;
    status = STATUS_DISCONNECTED;
    [self updateStatus];
}
//-------------------------------------------------------------------------
-(void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals{
    NSLog(@"LQR> Did retrieve peripherals: %@", peripherals);
}
//-----------------------------------------------------------------------
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSString *logMessage = @"";
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            logMessage = @"!> Bluetooth is currently powered off.";
            status = STATUS_BT_OFF;
            [self updateStatus];
            break;
        case CBCentralManagerStateResetting:
            logMessage = @"!> Bluetooth is resetting.";
            break;
        case CBCentralManagerStateUnauthorized:
            logMessage = @"!> Bluetooth LE is not authorized for this device.";
            break;
        case CBCentralManagerStateUnknown:
            logMessage = @"!> Bluetooth state unknown.";
            break;
        case CBCentralManagerStateUnsupported:
            logMessage = @"!> Bluetooth LE is not supported for this device.";
            break;
        case CBCentralManagerStatePoweredOn:
            logMessage = @"Bluetooth is currently powered on!";
            status = STATUS_DISCONNECTED;
            [self updateStatus];
            break;
    }
    NSLog(@"%@", logMessage);
}


#pragma mark Peripheral Delegate
//-----------------------------------------------------------------------
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"PER> Discovered services...");
    NSLog(@"%@", peripheral.services);
    for (CBService *service in peripheral.services) {
        NSLog(@"PER>> Discovered service: %@, with uuid: %@", service, service.UUID);
        if ([service.UUID isEqual:self.myModel.uuidService] || !onlyOurDevice) {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}
//-----------------------------------------------------------------------
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
    NSLog(@"PER> Did modify services.");
}
//-----------------------------------------------------------------------
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([self.myModel.uuidCharacteristic isEqual:characteristic.UUID] || !onlyOurDevice) {
            [self.periph setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

//-----------------------------------------------------------------------
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@",
              [error localizedDescription]);
    }
}
//-------------------------------------------------------------------------
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSData * data = characteristic.value;
    NSLog(@"PER> > Updated char value: %@", [characteristic.value description]);
    
    NSRange range = NSMakeRange (0, 3);
    unsigned char aBuffer[3];
    [data getBytes:aBuffer range:range];
    int ham1 = aBuffer[0];  //hammer peak
    int ham2 = aBuffer[1];  // reflex peak
    int ham3 = aBuffer[2];  // reflex latency
    
    if (ham3 < 20) {
        [self alertWithTitle:@"Please Retry" andMessage:@"Invalid reading. Please re-hammer."];
        return;
    }
    
    self.hammerStrengthLabel.text = [NSString stringWithFormat:@"%d", ham1];
    self.reflexStrLabel.text = [NSString stringWithFormat:@"%d", ham2];
    self.reflexLatLabel.text = [NSString stringWithFormat:@"%d ms", ham3];

    
    DataModel *dm = [[DataModel alloc] init];
    dm.hamStrength  = [NSNumber numberWithInt:ham1];
    dm.refStrength  = [NSNumber numberWithInt:ham2];
    dm.refLatency   = [NSNumber numberWithInt:ham3];
    
    [self.myModel addValueToHistory:dm];
    
    [self.myManager cancelPeripheralConnection:self.periph];
}



//-----------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
