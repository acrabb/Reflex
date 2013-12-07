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

NSString *OFF_LABEL         = @"Turn BT On";
NSString *ON_LABEL          = @"Connect";
NSString *CONNECTED_LABEL   = @"Start Test";
NSString *CONNECTING_LABEL  = @"Connecting...";

const NSInteger OFF_TAG         = 0;
const NSInteger ON_TAG          = 1;
const NSInteger CONNECTED_TAG   = 2;



@synthesize myModel     = _myModel;
@synthesize myManager   = _myManager;
@synthesize statusLabel = _statusLabel;
@synthesize multiButton = _multiButton;
@synthesize periph      = _periph;

@synthesize hammerStrengthLabel = _hammerStrengthLabel;
@synthesize reflexLatLabel  = _reflexLatLabel;
@synthesize reflexStrLabel  = _reflexStrLabel;




- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.myModel = [LQRModel sharedInstance];
    self.myManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
}

//-----------------------------------------------------------------------
- (IBAction)multiButtonTapped:(UIButton*)sender {
    NSLog(@">> Multi button tapped: %@", sender.titleLabel.text);
    switch (sender.tag) {
        case OFF_TAG:
            // Turn on bluetooth or notify;
            break;
        case ON_TAG:
            [self connect];
            break;
        case CONNECTED_TAG:
            // Start test!
            break;
        default:
            break;
    }
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
    [self.multiButton setTitle:ON_LABEL forState:UIControlStateNormal];
    self.multiButton.tag = ON_TAG;
    [self.multiButton setNeedsDisplay];
}

//-------------------------------------------------------------------------
- (void)connect
{
    NSDictionary *scanOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                            forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    NSLog(@">> Scanning for peripherals...");
    //TODO CHANGE ME TO SPECIFIC SERVICE
//    [self.myManager scanForPeripheralsWithServices:[NSArray arrayWithObject:self.myModel.uuidService] options:scanOptions];
    [self.myManager scanForPeripheralsWithServices:nil options:scanOptions];
}



#pragma mark Peripheral Delegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"PER> Discovered services...");
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:self.myModel.uuidService]) {
            NSLog(@"PER>> Discovered service: %@, with uuid: %@", service, service.UUID);
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics) {
       [self.periph setNotifyValue:YES forCharacteristic:characteristic];
        NSLog(@"PER>>>> Read char value: %s", characteristic.value.bytes);
        // ONLY FOR SPECIFIC CHAR
        if ([self.myModel.uuidCharacteristic isEqual:characteristic.UUID]) {
            // Read the value!!
            [self.periph setNotifyValue:YES forCharacteristic:characteristic];
            NSLog(@"PER>>>> Read char value: %s", characteristic.value.bytes);
        }

    }
}

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
    NSLog(@"PER>>>> Updated char value: %@", [characteristic.value description]);
    
    NSRange range = NSMakeRange (0, 6);
    unsigned char aBuffer[6];
    [data getBytes:aBuffer range:range];
    int ham1 = aBuffer[0];
    int ham2 = aBuffer[1];
    int ham3 = aBuffer[2];
    
    self.hammerStrengthLabel.text = [NSString stringWithFormat:@"%d", ham1];
    self.reflexLatLabel.text = [NSString stringWithFormat:@"%d", ham2];
    self.reflexStrLabel.text = [NSString stringWithFormat:@"%d", ham3];
    
//    NSString *s = [[NSString alloc] initWithBytes:aBuffer length:6 encoding:NSUTF8StringEncoding];
//    NSLog(@"PER>>>> Updated char value: %@", s);
}


#pragma mark Central Manager Delegate
//-------------------------------------------------------------------------
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    NSLog(@"LQR> Advertisement...:%@",[advertisementData description]);
    NSLog(@">>> >> ...for peripheral:%@\n", peripheral);
    if ([@"Reflex X1" isEqualToString:peripheral.name]) {
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
    self.periph.delegate = self;
    [self.periph discoverServices:nil];
    // TODO CHANGE ME TO SPECIFIC SERVICE
//    [self.periph discoverServices:[NSArray arrayWithObject:self.myModel.uuidService]];
    
//    [self.periph readValueForCharacteristic:[]];
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


//-----------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
