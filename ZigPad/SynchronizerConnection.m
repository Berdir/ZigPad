//
//  SynchronizerConnection.m
//  ZigPad
//
//  Created by ceesar on 10/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SynchronizerConnection.h"

@implementation SynchronizerConnection

@synthesize inReady;
@synthesize inStream = _inStream;
@synthesize outReady;
@synthesize outStream = _outStream;
@synthesize name = _name;


/**
 * Helper method to open the streams to the connected device.
 */
- (void) openStreams
{
    // Open input stream.
	_inStream.delegate = self;
	[_inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_inStream open];
    
    // Open outbound stream.
	_outStream.delegate = self;
	[_outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outStream open];
}

- (id) initWithService: (NSNetService *) service {
    
    id i = [super init];
    
    if (i) {
        // Make sure no connection is open yet.
        [self.inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.inStream release];
        self.inStream = nil;
        self.inReady = NO;
        
        [self.outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outStream release];
        self.outStream = nil;
        self.outReady = NO;
        
        self.name = service.name;

        // Note the following method returns _inStream and _outStream with a 
        // retain count that the caller must eventually release
        if (![service getInputStream:&_inStream outputStream:&_outStream]) {
            NSLog(@"Failed to connect to server.");
        }
        
        [_inStream retain];
        [_outStream retain];
        
        [self openStreams];
    }
    
    return i;
}

- (id) initWithStreams:(NSInputStream *)istr :(NSOutputStream *)ostr {
    id i = [super init];
    
    if (i) {
        [self.inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.inStream release];
        self.inStream = nil;
        self.inReady = NO;
        
        [self.outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outStream release];
        self.outStream = nil;
        self.outReady = NO;
        
        _inStream = istr;
        [_inStream retain];
        _outStream = ostr;
        [_outStream retain];
        
        [self openStreams];
        
        // Inbound connection only, do not send.
        self.name = nil;
    }
    return i;
}

- (void) send:(SyncEvent *) event
{
    if (self.outReady) {
        NSLog(@"Sending SyncEvent %i : %d", event.command, event.argument);
        
        // Send three bytes, first the command, then the first byte of the argument
        // finally then the second.
        [self.outStream write:[event bytes] maxLength:event.bytesLength];
    }
    else if (self.outStream) {
        // Outstream is not yet ready but we have an outstream, wait a moment and try again.
        NSLog(@"Trying to send sync event but stream is not yet ready, wait 1s before retrying");
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(sendTimed:) userInfo:event repeats:NO];
    }
}

- (void) sendTimed:(NSTimer *)timer {
    // Simply call the send method again.
    [self send:[timer userInfo]];
}

#pragma mark -
#pragma mark NSNetService delegate methods.

- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
	switch(eventCode) {
		case NSStreamEventOpenCompleted:
		{
            // Mark streams as ready.
			if (stream == _inStream) {
				self.inReady = YES;
            }
			else {
				self.outReady = YES;
            }
			break;
		}
		case NSStreamEventHasBytesAvailable:
		{
            // Only read if this is the input stream.
			if (stream == _inStream) {
                // Create a temporary bytes array to store the sent data.
				uint8_t b[3];

				int len = [_inStream read:b maxLength:4];
				if(len < 3) {
					if ([stream streamStatus] != NSStreamStatusAtEnd) {
						NSLog(@"Failed reading data from peer");
                    }
				} else {          
                    // Create a SyncEvent instance based on the sent data.
                    SyncEvent *event = [[SyncEvent alloc] initWithBytes:b];
                    event.connection = self;
                    
                    NSLog(@"Got SyncEvent %d with argument %d", event.command, event.argument);
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZigPadSyncReceive" object:event];
                    
                    [event release];
				}
			}
			break;
		}
		case NSStreamEventErrorOccurred:
		{
            // An error happened, close the connection and log an error.
            NSError *theError = [stream streamError];
            NSLog(@"Connection error %i: %@", [theError code], [theError localizedDescription]);
            
            [stream close];
            [stream release];
			break;
		}
			
		case NSStreamEventEndEncountered:
		{
            // The connection was closed, send a lost connection event.
            SyncEvent *event = [[SyncEvent alloc] init];
            event.command = LOST_CONNECTION;
            event.connection = self;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ZigPadSyncReceive" object:event];
            
            [event release];
            
            if (self.name) {
                NSLog(@"Service %@ disconnected!", self.name);
            }
			break;
		}
	}
}

#pragma mark -

- (void) dealloc {
    [_inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[_inStream release];
    
	[_outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[_outStream release];
    [super dealloc];
}


@end
