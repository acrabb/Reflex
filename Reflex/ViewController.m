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
NSString *END_TEST_LABEL    = @"End Test";
NSString *READING_DATA      = @"Reading data...";
NSString *SEARCHING_LABEL   = @"Searching...";


const NSInteger OFF_TAG         = 0;
const NSInteger START_TEST_TAG  = 1;
const NSInteger END_TEST_TAG    = 4;
const NSInteger READING_TAG     = 2;
const NSInteger SEARCHING_TAG   = 3;


NSString *const DeviceName = @"Reflex X1";

@synthesize myModel     = _myModel;
@synthesize myManager   = _myManager;
@synthesize statusLabel = _statusLabel;
@synthesize multiButton = _multiButton;
@synthesize historyButton = _historyButton;
@synthesize periph      = _periph;

@synthesize hammerStrengthLabel = _hammerStrengthLabel;
@synthesize reflexLatLabel  = _reflexLatLabel;
@synthesize reflexStrLabel  = _reflexStrLabel;

bool onlyOurDevice = false;


//-----------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.myModel = [LQRModel sharedInstance];
    self.myManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pretty.jpg"]];
    [self.multiButton.layer setCornerRadius:5.0];
    [self.historyButton.layer setCornerRadius:5.0];
    [self.hammerStrengthLabel.layer setCornerRadius:5.0];
    [self.reflexLatLabel.layer setCornerRadius:5.0];
    [self.reflexStrLabel.layer setCornerRadius:5.0];
}

//-----------------------------------------------------------------------
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

//-----------------------------------------------------------------------
- (IBAction)multiButtonTapped:(UIButton*)sender {
    NSLog(@">> Multi button tapped: %@", sender.titleLabel.text);
    switch (sender.tag) {
        case OFF_TAG:
            [self alert];
            break;
        case START_TEST_TAG:
            [self startTest];
            break;
        default:
            break;
    }
}


//-------------------------------------------------------------------------
- (void) alert
{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Bluetooth"
                message:@"Please enable bluetooth to continue."
                delegate:nil
                cancelButtonTitle:@"Ok"
                otherButtonTitles: nil];
    [alert show];
    
}
//-------------------------------------------------------------------------

- (void)blueToothOff
{
    self.statusLabel.text = @"BT is off";
    [self.multiButton setTitle:OFF_LABEL forState:UIControlStateNormal];
    self.multiButton.tag = OFF_TAG;
    [self.multiButton setNeedsDisplay];
}

//-------------------------------------------------------------------------
- (void)blueToothOn
{
    self.statusLabel.text = @"BT is on!";
    [self disconnected];
}

//-------------------------------------------------------------------------
- (void)connect
{
    NSDictionary *scanOptions;
    if (onlyOurDevice) {
        scanOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                  forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
        [self.myManager scanForPeripheralsWithServices:[NSArray arrayWithObject:self.myModel.uuidService] options:scanOptions];
    } else {
        scanOptions = nil;
        [self.myManager scanForPeripheralsWithServices:nil options:scanOptions];
    }
    NSLog(@">> Scanning for peripherals...");
    self.statusLabel.text = SEARCHING_LABEL;
}

//-------------------------------------------------------------------------
- (void)connected
{
       // TODO CHANGE ME TO SPECIFIC SERVICE
//    [self.periph discoverServices:[NSArray arrayWithObject:self.myModel.uuidService]];
    
    //    [self.periph readValueForCharacteristic:[]];
    self.periph.delegate = self;
    [self.periph discoverServices:nil];
    [self.statusLabel setText:@"Connected!"];
    [self.multiButton setTag:END_TEST_TAG];
    [self.multiButton setTitle:END_TEST_LABEL forState:UIControlStateNormal];
}

//-------------------------------------------------------------------------
-(void)startTest {
    [self connect];
}
//-------------------------------------------------------------------------
- (void)disconnected {
    [self.multiButton setTag:START_TEST_TAG];
    [self.multiButton setTitle:START_TEST_LABEL forState:UIControlStateNormal];
    [self.statusLabel setText:@"Disconnected"];
    self.periph = nil;
}




#pragma mark Central Manager Delegate
//-------------------------------------------------------------------------
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    NSLog(@"LQR> Looking for UUID: %@", self.myModel.uuidDevice);
    NSLog(@"LQR> Advertisement...:%@",[advertisementData description]);
    NSLog(@">>> >> ...for peripheral:%@\n", peripheral);
    if ([self.myModel.uuidDevice isEqual:peripheral.identifier]
                || !onlyOurDevice) {
        NSLog(@"LQR> FOUND IT!");
        self.periph = peripheral;
        [self.myManager connectPeripheral:self.periph options:nil];
        [self.myManager stopScan];
    }
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
    [self connected];
}
//-------------------------------------------------------------------------
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"LQR> Did DISconnect peripheral: %@", [peripheral description]);
    [self disconnected];
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
            [self blueToothOff];
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
            [self blueToothOn];
            break;
    }
    NSLog(@"%@", logMessage);
}


#pragma mark Peripheral Delegate
//-----------------------------------------------------------------------
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"PER> Discovered services...");
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:self.myModel.uuidService] || !onlyOurDevice) {
            NSLog(@"PER>> Discovered service: %@, with uuid: %@", service, service.UUID);
            // TODO: CHANGE TO OUR CHARACTERISTIC
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}
//-----------------------------------------------------------------------
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
    
}
//-----------------------------------------------------------------------
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics) {
        // ONLY FOR SPECIFIC CHAR
        if ([self.myModel.uuidCharacteristic isEqual:characteristic.UUID] || !onlyOurDevice) {
            // Subscribe to the value!!
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
    
    NSRange range = NSMakeRange (0, 6);
    unsigned char aBuffer[6];
    [data getBytes:aBuffer range:range];
    int ham1 = aBuffer[0];
    int ham2 = aBuffer[1];
    int ham3 = aBuffer[2];
    
    self.hammerStrengthLabel.text = [NSString stringWithFormat:@"%d", ham1];
    self.reflexLatLabel.text = [NSString stringWithFormat:@"%d", ham2];
    self.reflexStrLabel.text = [NSString stringWithFormat:@"%d", ham3];

    
    DataModel *dm = [[DataModel alloc] init];
    dm.hamStrength  = [NSNumber numberWithInt:ham1];
    dm.refLatency   = [NSNumber numberWithInt:ham2];
    dm.refStrength  = [NSNumber numberWithInt:ham3];
    
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
