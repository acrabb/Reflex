//
//  LQRModel.h
//  Reflex
//
//  Created by André Crabb on 11/30/13.
//  Copyright (c) 2013 Andre Crabb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface LQRModel : NSObject

+ (id)sharedInstance;

@property (strong, nonatomic) CBUUID *uuidDevice;
@property (strong, nonatomic) CBUUID *uuidService;
@property (strong, nonatomic) CBUUID *uuidCharacteristic;

@end
