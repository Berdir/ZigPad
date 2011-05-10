//
//  SyncEvent.h
//  ZigPad
//
//  Created by ceesar on 04/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SELECT = 83,
    JUMP = 74,
    CONNECTED = 67,
    LOST_CONNECTION = 76,
    REQUEST = 82,
    ANSWER = 65,
    EXIT = 69,
    
} SyncEventCommand;

typedef enum {
    RIGHT, LEFT, RIGHT_ANIMATED, LEFT_ANIMATED, UP
} SyncEventSwipeDirection;


@interface SyncEvent : NSObject {
    
}

@property (readwrite) SyncEventCommand command;

@property (readwrite) uint8_t argument_upperByte;
@property (readwrite) uint8_t argument_lowerByte;
@property (readwrite) uint16_t argument;

@property (readwrite) SyncEventSwipeDirection direction;

@property (readonly) int bytesLength;

- (id) initWithBytes: ( const uint8_t *) bytes;
- (const uint8_t *) bytes;

@end
