//
//  Commander.h
//  ZigPad
//
//  Created by ceesar on 07/04/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZigPadSettings.h"
#import "Action.h"
#import "Param.h"

/**
 * Defines which commander implementation is used.
 */
extern NSString * const COMMANDER_IMPL;

/**
 * Allows to send strings over TCP or UDP.
 */
@interface Commander : NSObject {
}

/**
 * Get the default commander instance.
 */
+(Commander*) defaultCommander;
/**
 * Close the default commander, e.g. if settings have changed.
 */
+(void) close;

/**
 * Send a string.
 *
 * This is an abstract method and must be overriden by the actual
 * implementation.
 *
 * @param message The string that should be sent.
 */
-(void) sendString: (NSString* )message;

/**
 * Send a command parameter of an action.
 *
 * This is a helper method, which will look for an Param with key "command"
 * and send that as a string.
 *
 * @param action The action object of which the command Param should be sent.
 */
-(void) sendAction: (Action* )action;


@end
