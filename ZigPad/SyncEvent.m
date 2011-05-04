//
//  SyncEvent.m
//  ZigPad
//
//  Created by ceesar on 04/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SyncEvent.h"


@implementation SyncEvent

@synthesize command;
@synthesize argument_upperByte;
@synthesize argument_lowerByte;
@synthesize direction;

- (id) initWithBytes: (const uint8_t *) bytes {
    if((self = [super init])) {
        self.command = bytes[0];
        self.argument_upperByte = bytes[1];
        self.argument_lowerByte = bytes[2];
        self.direction = bytes[3];
    }
    return self;
}

- (uint16_t) argument {
    return (self.argument_upperByte << 8) + self.argument_lowerByte;
}

- (void) setArgument:(uint16_t)argument {
    self.argument_lowerByte = argument;
    self.argument_upperByte = argument >> 8;
}

- (const uint8_t *) bytes {
    uint8_t bytes[4] = {self.command, self.argument_upperByte, self.argument_lowerByte, self.direction};
    
    // Results in compiler warning.
    //return bytes;
    
    // Pass through NSData to avoid that warning.
    NSData *data = [[NSData alloc] initWithBytes:bytes length:4];
    [data autorelease];
    return [data bytes];
}

@end
