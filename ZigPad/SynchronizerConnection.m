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


- (void) openStreams
{
	_inStream.delegate = self;
	[_inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_inStream open];
	_outStream.delegate = self;
	[_outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outStream open];
}

- (id) initWithService: (NSNetService *) service {
    
    id i = [super init];
    
    [self.inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.inStream release];
	self.inStream = nil;
	self.inReady = NO;
    
	[self.outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.outStream release];
	self.outStream = nil;
	self.outReady = NO;
    
    self.name = service.name;
    
    
	// note the following method returns _inStream and _outStream with a retain count that the caller must eventually release
	if (![service getInputStream:&_inStream outputStream:&_outStream]) {
        NSLog(@"Failed to connect to server.");
	}
    
    [self openStreams];
    
    return i;
}

- (id) initWithStreams:(NSInputStream *)istr :(NSOutputStream *)ostr {
    
    
    
    id i = [super init];
    
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
    
    return i;
}

- (void) send:(SyncEvent *) event
{
    // Only send something if the service name is set. This means that this
    // connection was initialized through a NSNetService. This is to avoid
    // sending the event twice (as there are two connections between each device)
    if (self.name == nil) {
        return;
    }
    
    if (self.outReady) {
        NSLog(@"Sending SyncEvent %i : %d", event.command, event.argument);
        
        // Send three bytes, first the command, then the first byte of the argument
        // finally then the second.
        [self.outStream write:[event bytes] maxLength:event.bytesLength];
    }
    else if (self.outStream) {
        // Outstream is not yet ready but we have an outstream, wait a second and try again.
        NSLog(@"Trying to send sync event but stream is not yet ready, wait 1s before retrying");
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendTimed:) userInfo:event repeats:NO];
    }
}

- (void) sendTimed:(NSTimer *)timer {
    [self send:[timer userInfo]];
}


- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
	switch(eventCode) {
		case NSStreamEventOpenCompleted:
		{
			if (stream == _inStream)
				self.inReady = YES;
			else
				self.outReady = YES;
			
			if (self.inReady && self.outReady) {
                NSLog(@"Connected");
			}
			break;
		}
		case NSStreamEventHasBytesAvailable:
		{
			if (stream == _inStream) {
				uint8_t b[3];
				int len = 0;
				len = [_inStream read:b maxLength:4];
				if(len < 3) {
					if ([stream streamStatus] != NSStreamStatusAtEnd)
						NSLog(@"Failed reading data from peer");
				} else {                    
                    SyncEvent *event = [[SyncEvent alloc] initWithBytes:b];
                    
                    NSLog(@"Got SyncEvent %d with argument %d", event.command, event.argument);
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZigPadSyncReceive" object:event];
                    
                    [event release];
				}
			}
			break;
		}
		case NSStreamEventErrorOccurred:
		{
            NSError *theError = [stream streamError];
            NSLog(@"Error %i: %@", [theError code], [theError localizedDescription]);
            
            [stream close];
            [stream release];
			break;
		}
			
		case NSStreamEventEndEncountered:
		{
            SyncEvent *event = [[SyncEvent alloc] init];
            event.command = LOST_CONNECTION;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ZigPadSyncReceive" object:event];
            
            [event release];
            
			NSLog(@"Device Disconnected!");
			break;
		}
	}
}

- (void) dealloc {
    [_inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[_inStream release];
    
	[_outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[_outStream release];
    [super dealloc];
}


@end
