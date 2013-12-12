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


const int kLQROptionAll             = 0;
const int kLQROptionHammerStrength  = 1;
const int kLQROptionReflexLatency   = 2;
const int kLQROptionReflexStrength  = 3;

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
        
        self.history = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (void)addValueToHistory: (DataModel *)value
{
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    [self.history setObject:value forKey:now];
}


+(NSDate *)refDate
{
    NSDate *weekAgo = [NSDate dateWithTimeIntervalSinceNow:-60*60*24*5];
    return weekAgo;
//   	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
//    
//	[dateComponents setMonth:date mo];
//	[dateComponents setDay:10];
//	[dateComponents setYear:2013];
//	[dateComponents setHour:12];
//	[dateComponents setMinute:0];
//	[dateComponents setSecond:0];
//	NSCalendar *gregorian = [[NSCalendar alloc]
//							 initWithCalendarIdentifier:NSGregorianCalendar];
//    return [gregorian dateFromComponents:dateComponents];
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
