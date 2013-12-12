//
//  LQRModel.h
//  Reflex
//
//  Created by André Crabb on 11/30/13.
//  Copyright (c) 2013 Andre Crabb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DataModel.h"
#import "LQRModel.h"

@interface LQRModel : NSObject

extern const int kLQROptionAll;
extern const int kLQROptionHammerStrength;
extern const int kLQROptionReflexLatency;
extern const int kLQROptionReflexStrength;

+ (id)sharedInstance;

@property (strong, nonatomic) NSUUID *uuidDevice;
@property (strong, nonatomic) CBUUID *uuidService;
@property (strong, nonatomic) CBUUID *uuidDeviceService;
@property (strong, nonatomic) CBUUID *uuidCharacteristic;

@property (strong, nonatomic) NSMutableDictionary *history;


+(NSDate *)refDate;

- (void) addValueToHistory: (DataModel *)value;
-(NSArray *)getHistoryValues;
-(NSArray *)getHistoryKeysSorted;
-(NSMutableArray *)getHistoryAsArrayFor:(int)option;

@end
