//
//  DataModel.h
//  Reflex
//
//  Created by André Crabb on 12/9/13.
//  Copyright (c) 2013 Andre Crabb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject

@property (nonatomic) NSNumber *hamStrength;
@property (nonatomic) NSNumber *refLatency;
@property (nonatomic) NSNumber *refStrength;

- (id)initWithHammerStrength:(int)hs reflexLatency:(int)rl reflexStrength:(int)rs;
@end
