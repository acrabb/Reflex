//
//  ViewController.h
//  Reflex
//
//  Created by André Crabb on 11/30/13.
//  Copyright (c) 2013 Andre Crabb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LQRModel.h"

@interface ViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager  *myManager;

@property (strong, nonatomic) LQRModel          *myModel;
@property (weak, nonatomic) IBOutlet UIButton   *multiButton;
@property (weak, nonatomic) IBOutlet UILabel    *statusLabel;
@property (strong, nonatomic) CBPeripheral      *periph;



@end
