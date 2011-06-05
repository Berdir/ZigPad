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
@synthesize connection;

- (id) initWithBytes: (const uint8_t *) bytes {
    if((self = [super init])) {
        // First byte is the command.
        self.command = bytes[0];
        // Second and third byte are the arguments.
        self.argument_upperByte = bytes[1];
        self.argument_lowerByte = bytes[2];
        // And the fourth is the direction.
        self.direction = bytes[3];
    }
    return self;
}
/**
 * Getter method for the argument property.
 *
 * This is a virtual property which is created on-demand based on the upper and
 * lower bytes.
 */
- (uint16_t) argument {
    return (self.argument_upperByte << 8) + self.argument_lowerByte;
}

/**
 * Setter method for the argument property.
 *
 * The upper and lower byte is stored separately.
 */
- (void) setArgument: (uint16_t)argument {
    self.argument_lowerByte = argument;
    self.argument_upperByte = argument >> 8;
}

- (const uint8_t *) bytes {
    
    // Create the bytes array.
    uint8_t bytes[4] = {self.command, self.argument_upperByte, self.argument_lowerByte, self.direction};
    
    // Results in compiler warning.
    //return bytes;
    
    // Pass through NSData to avoid that warning. NSData must either be
    // ignoring that warning or work around it in a unkown way.
    NSData *data = [[NSData alloc] initWithBytes:bytes length:4];
    [data autorelease];
    return [data bytes];
}

- (int) bytesLength {
    // All events have a fixed bytes length of 4 bytes.
    return 4;
}

@end
