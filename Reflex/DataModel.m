//
//  DataModel.m
//  Reflex
//
//  Created by André Crabb on 12/9/13.
//  Copyright (c) 2013 Andre Crabb. All rights reserved.
//

#import "DataModel.h"

@implementation DataModel

@synthesize hamStrength    = _hamStrength;
@synthesize refLatency     = _refLatency;
@synthesize refStrength    = _refStrength;

- (id)initWithHammerStrength:(int)hs reflexLatency:(int)rl reflexStrength:(int)rs {
    if (self = [super init]) {
        self.hamStrength    = [NSNumber numberWithInt: hs];
        self.refLatency     = [NSNumber numberWithInt: rl];
        self.refStrength    = [NSNumber numberWithInt: rs];
    }
    return self;
}

@end
