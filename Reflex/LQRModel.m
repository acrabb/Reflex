
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
@synthesize uuidDeviceService   = _uuidDeviceService;
@synthesize uuidCharacteristic  = _uuidCharacteristic;
@synthesize history = _history;


const int kLQROptionAll             = 0;
const int kLQROptionHammerStrength  = 1;
const int kLQROptionReflexLatency   = 2;
const int kLQROptionReflexStrength  = 3;

bool debug = true;
int secondsInDay = 1 * 60 * 60 * 24;
int offset = 0;

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
//        self.uuidDevice = [[NSUUID alloc] initWithUUIDString:@"7C42A62A-92E8-EB1C-34F6-408A12BCD60F"];
        self.uuidDevice = [[NSUUID alloc] initWithUUIDString:@"A0FBB8C4-F62D-1010-AB42-5B9BF3E8A499"];
        
        self.uuidService = [CBUUID UUIDWithString:@"e14235c0-5d26-11e3-949a-0800200c9a66"];
        self.uuidDeviceService = [CBUUID UUIDWithString:@"195ae58a-437a-489b-b0cd-b7c9c394bae4"];
        self.uuidCharacteristic = [CBUUID UUIDWithString:@"e14235c1-5d26-11e3-949a-0800200c9a66"];
        
        self.history = [[NSMutableDictionary alloc] init];
        
        // MOCK DATA
        if (debug) {
            int hs;
            int rl;
            int rs;
            for (int i = 0; i < 10; i++) {
                hs = (arc4random() % 10) + 1;
                rl = 40 + (arc4random() % 50) - i;
                rs = 2 + (arc4random() % 5) + i/2;
                if (i == 9) {
                    hs = 7;
                    rl = 32;
                    rs = 7;
                }
                NSLog(@">>> hs: %d,,, rl: %d,,, rs: %d",hs, rl, rs);
                NSDate* week = [NSDate dateWithTimeIntervalSinceNow: -1 * secondsInDay * (10-i)];
                [self.history setObject:[[DataModel alloc] initWithHammerStrength:hs
                                                                            reflexLatency:rl
                                                                           reflexStrength:rs]
                                         forKey: week];
            }
        }
        
    }
    return self;
}


- (void)addValueToHistory: (DataModel *)value
{
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:offset];
    [self.history setObject:value forKey:now];
    offset += secondsInDay;
}


+(NSDate *)refDate
{
    NSDate *weekAgo = [NSDate dateWithTimeIntervalSinceNow:-60*60*24*5];
    return weekAgo;
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
-(NSMutableArray *)getHistoryAsArrayFor:(int)option
{
    //TODO change the NSDate object to seconds from refDate
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSDictionary *dict;
    NSNumber *dateInSecondsSinceRef, *yValue;
    
    for (NSDate *d in [self.history.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        dateInSecondsSinceRef = [NSNumber numberWithDouble:[d timeIntervalSinceDate:[LQRModel refDate]]];
        switch (option) {
            case kLQROptionHammerStrength:
                yValue = [[self.history objectForKey:d] hamStrength];
                break;
            case kLQROptionReflexLatency:
                yValue = [[self.history objectForKey:d] refLatency];
                break;
            case kLQROptionReflexStrength:
                yValue = [[self.history objectForKey:d] refStrength];
                break;
        }
        dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:dateInSecondsSinceRef, @"x", yValue, @"y", nil];
        [arr addObject:dict];
    }
    return arr;
}


@end
