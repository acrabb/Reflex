//
//  LQRModel.m
//  Reflex
//
//  Created by André Crabb on 11/30/13.
//  Copyright (c) 2013 Andre Crabb. All rights reserved.
//

#import "LQRModel.h"

@implementation LQRModel

@synthesize uuidDevice          = _uuidDevice;
@synthesize uuidService         = _uuidService;
@synthesize uuidCharacteristic  = _uuidCharacteristic;
@synthesize history = _history;


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
        self.uuidDevice = [[NSUUID alloc] initWithUUIDString:@"7C42A62A-92E8-EB1C-34F6-408A12BCD60F"];
        
        self.uuidService = [CBUUID UUIDWithString:@"e14235c0-5d26-11e3-949a-0800200c9a66"];
        self.uuidCharacteristic = [CBUUID UUIDWithString:@"e14235c1-5d26-11e3-949a-0800200c9a66"];
        
        
    }
    return self;
}


- (void)addValueToHistory: (DataModel *)value
{
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    [self.history setObject:value forKey:now];
}

-(NSArray *)getHistoryKeysSorted;
{
    NSArray *keys = self.history.allKeys;
    return [keys sortedArrayUsingSelector:@selector(compare:)];
}
- (NSArray *)getHistoryValues
{
    return self.history.allValues;
}





@end
