//
//  LQRModel.m
//  Reflex
//
//  Created by André Crabb on 11/30/13.
//  Copyright (c) 2013 Andre Crabb. All rights reserved.
//

#import "LQRModel.h"

@implementation LQRModel

@synthesize myManager = _myManager;

+ (id)sharedInstance {
    static LQRModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        self.myManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    }
    return self;
}


//--------------------------------------------------------------------------------------------
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
                                                       advertisementData:(NSDictionary *)advertisementData
                                                                    RSSI:(NSNumber *)RSSI {
    NSLog([NSString stringWithFormat:@"%@",[advertisementData description]]);
    [self.myManager retrievePeripheralsWithIdentifiers:(id)peripheral.identifier];
}
//--------------------------------------------------------------------------------------------
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
}
//--------------------------------------------------------------------------------------------
-(void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals{
    NSLog(@"LQR> Did retrieve peripherals.");
}

//--------------------------------------------------------------------------------------------
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSString *logMessage = @"";
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            logMessage = @"!> Bluetooth is currently powered off.";
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
            CBUUID *hr = [CBUUID UUIDWithString:@"180D"];
            NSDictionary *scanOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                                    forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
            [self.myManager scanForPeripheralsWithServices:[NSArray arrayWithObject:hr]
                                                   options:scanOptions];
            //[mgr retrieveConnectedPeripherals];
            
            //--- it works, I Do get in this area!
            
            break;
            
    }
    NSLog(logMessage); 
} 




@end
