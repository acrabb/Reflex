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
    CBUUID *hr = [CBUUID UUIDWithString:@"180D"];
    NSDictionary *scanOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                            forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    NSLog(@">> Scanning for peripherals...");
//    [self.myManager scanForPeripheralsWithServices:[NSArray arrayWithObject:hr]
     [self.myManager scanForPeripheralsWithServices:nil
                                           options:scanOptions];
    
}


#pragma mark Central Manager
//-------------------------------------------------------------------------
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    NSLog(@"LQR> Advertisement...:%@",[advertisementData description]);
    NSLog(@">>> >> ...for peripheral:%@\n", peripheral);
    //[self.myManager retrievePeripheralsWithIdentifiers:(id)peripheral.identifier];
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
