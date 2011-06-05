//
//  SynchronizerConnection.h
//  ZigPad
//
//  Created by ceesar on 10/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncEvent.h"

/**
 * This class represents a connection to another device.
 *
 * @todo: The class is currently only used either as a outbound or a inbound
          connection, but both a input and output stream is opened for both.
          This should be improved somehow.
 */
@interface SynchronizerConnection : NSObject <NSStreamDelegate> {
    
}

/**
 * Input stream.
 */
@property (readwrite, retain) NSInputStream		*inStream;

/**
 * Output stream.
 */
@property (readwrite, retain) NSOutputStream	*outStream;

/**
 * Indicates if the input stream is ready to be used.
 */
@property (readwrite) BOOL				inReady;

/**
 * Indicates if the output stream is ready to be used
 */
@property (readwrite) BOOL				outReady;

/**
 * Name of service related to this connection.
 *
 * This is only set for outbound connections.
 */
@property (readwrite, retain) NSString *name;

/**
 * Init with a NSNetService instance for an outbound connection.
 */
- (id) initWithService: (NSNetService *) service;

/**
 * Init with an input and output stream for an inbound connection.
 */
- (id) initWithStreams: (NSInputStream *) istr : (NSOutputStream *) ostr;

/**
 * Send a sync event to the connected device.
 */
- (void) send: (SyncEvent *) event;

/**
 * NSTimer callback used for automatically re-sending data when the connection
 * is not yet ready.
 */
- (void) sendTimed: (NSTimer *) timer;

@end
