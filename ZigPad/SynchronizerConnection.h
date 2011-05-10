//
//  SynchronizerConnection.h
//  ZigPad
//
//  Created by ceesar on 10/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncEvent.h"


@interface SynchronizerConnection : NSObject <NSStreamDelegate> {
    
}

@property (readwrite, retain) NSInputStream		*inStream;
@property (readwrite, retain) NSOutputStream	*outStream;
@property (readwrite) BOOL				inReady;
@property (readwrite) BOOL				outReady;

- (id) initWithService: (NSNetService *) service;
- (id) initWithStreams: (NSInputStream *) istr : (NSOutputStream *) ostr;
- (void) send: (SyncEvent *) event;
- (void) sendTimed: (NSTimer *) timer;

- (void) openStreams;	

@end
