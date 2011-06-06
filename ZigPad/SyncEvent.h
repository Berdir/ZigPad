//
//  SyncEvent.h
//  ZigPad
//
//  Created by ceesar on 04/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynchronizerConnection.h"

/**
 * SyncEventCommand enumeration, list of the existing commands including the
 * corresponding value as ASCI.
 */
typedef enum {
    /* Select a presentation */
    SELECT = 83,
    /* Jump to an sequence/action */
    JUMP = 74,
    /* Connected to a device, not sent to any external device */
    CONNECTED = 67,
    /* Lost connection to a device, not sent to any external device */
    LOST_CONNECTION = 76,
    /* Request the current state (running presentation) */
    REQUEST = 82,
    /* The currently running presentation, in response to a REQUEST */
    ANSWER = 65,
    /* Sent when closing a presention */
    EXIT = 69,
    
} SyncEventCommand;

/**
 * Enumeration used to indicate the direction of the view.
 */
typedef enum {
    RIGHT, LEFT, RIGHT_ANIMATED, LEFT_ANIMATED, UP
} SyncEventSwipeDirection;

/**
 * A class that contaions information about a synchronization notification event.
 */
@interface SyncEvent : NSObject {
    
}

/**
 * The command of this sync event.
 */
@property (readwrite) SyncEventCommand command;

/**
 * The upper byte of the 16bit argument.
 */
@property (readwrite) uint8_t argument_upperByte;

/**
 * The lower byte of the 16bit argument.
 */
@property (readwrite) uint8_t argument_lowerByte;

/**
 * The 16bit unsigned int argument.
 *
 * The meaning depends on the used command. Some command also use each byte
 * seperately, in that case, those bytes can be accessed directly through the
 * argument_lowerByte/upperByte properties.
 */
@property (readwrite) uint16_t argument;

/**
 * The swipe direction of the command, only relevant for JUMP commands.
 */
@property (readwrite) SyncEventSwipeDirection direction;

/**
 * Length of the bytes array returned by bytes().
 */
@property (readonly) int bytesLength;

@property (nonatomic, retain) SynchronizerConnection* connection;


/**
 * Create an instance based on a received bytes array.
 */
- (id) initWithBytes: ( const uint8_t *) bytes;

/**
 * Returns a byte array that can be sent to another device.
 */
- (const uint8_t *) bytes;

@end
