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
} SyncEventCommand;

typedef enum {
    RIGHT, LEFT, RIGHT_ANIMATED, LEFT_ANIMATED,
} SyncEventSwipeDirection;


@interface SyncEvent : NSObject {
    
}

@property (readwrite) SyncEventCommand command;

@property (readwrite) uint8_t argument_upperByte;
@property (readwrite) uint8_t argument_lowerByte;
@property (readwrite) uint16_t argument;

@property (readwrite) SyncEventSwipeDirection direction;

- (id) initWithBytes: ( const uint8_t *) bytes;
- (const uint8_t *) bytes;

@end
