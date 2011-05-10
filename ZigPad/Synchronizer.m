//
//  SynchTestViewController.m
//  SynchTest
//
//  Created by ceesar on 22/03/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import "Synchronizer.h"
#import "SyncEvent.h"

// The Bonjour application protocol, which must:
// 1) be no longer than 14 characters
// 2) contain only lower-case letters, digits, and hyphens
// 3) begin and end with lower-case letter or digit
// It should also be descriptive and human-readable
// See the following for more information:
// http://developer.apple.com/networking/bonjour/faq.html
#define kGameIdentifier		@"zigpad"

#define ZIGPAD_SYNC_DOMAIN @"local"

@implementation Synchronizer

@synthesize ownEntry = _ownEntry;
@synthesize showDisclosureIndicators = _showDisclosureIndicators;
@synthesize currentResolve = _currentResolve;
@synthesize netServiceBrowser = _netServiceBrowser;
@synthesize services = _services;
@synthesize needsActivityIndicator = _needsActivityIndicator;
@dynamic timer;
@synthesize initialWaitOver = _initialWaitOver;
@synthesize ownName = _ownName;

- (void) registerNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fireSyncEvent:) 
                                                 name:@"ZigPadSyncFire"
                                               object:nil];
}

- (void) unregisterNotificationCenter {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void) fireSyncEventTimed: (NSTimer*) theTimer {
    [self fireSyncEvent: [theTimer userInfo]];
}

- (void) fireSyncEvent: (NSNotification *) notification {
    if (_outReady) {
        
        SyncEvent *event = (SyncEvent *) [notification object];
        NSLog(@"Sending SyncEvent %i : %d", event.command, event.argument);

        // Send three bytes, first the command, then the first byte of the argument
        // finally then the second.
        [_outStream write:[event bytes] maxLength:4];
    }
    else if (_outStream) {
        // Outstream is not yet ready but we have an outstream, wait a second and try again.
        NSLog(@"Trying to send sync event but stream is not yet ready, wait 1s before retrying");
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(fireSyncEventTimed:) userInfo:notification repeats:NO];
    }
}

- (id)init {
    
    id i = [super init];
    NSLog(@"Setup...");
    [_server release];
	_server = nil;
	
	[_inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_inStream release];
	_inStream = nil;
	_inReady = NO;
    
	[_outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outStream release];
	_outStream = nil;
	_outReady = NO;
	
	_server = [TCPServer new];
	[_server setDelegate:self];
	NSError *error = nil;
	if(_server == nil || ![_server start:&error]) {
		if (error == nil) {
			NSLog(@"Failed creating server: Server instance is nil");
		} else {
            NSLog(@"Failed creating server: %@", error);
		}
		//[self _showAlert:@"Failed creating server"];
		return i;
	}
	
	//Start advertising to clients, passing nil for the name to tell Bonjour to pick use default name
	if(![_server enableBonjourWithDomain:@"local" applicationProtocol:[TCPServer bonjourTypeFromIdentifier:kGameIdentifier] name:nil]) {
		//[self _showAlert:@"Failed advertising server"];
        NSLog(@"Failed advertising server");
		return i;
	}	
    NSLog(@"Finished setup");
    
    
    [self registerNotificationCenter];
    
    return i;
}

// Creates an NSNetServiceBrowser that searches for services of a particular type in a particular domain.
// If a service is currently being resolved, stop resolving it and stop the service browser from
// discovering other services.
- (void)lookForDevice {
    
    NSString *type = [TCPServer bonjourTypeFromIdentifier:kGameIdentifier];
    
	[self stopCurrentResolve];
	[self.netServiceBrowser stop];
	[self.services removeAllObjects];
    
	NSNetServiceBrowser *aNetServiceBrowser = [[NSNetServiceBrowser alloc] init];
	if(!aNetServiceBrowser) {
        // The NSNetServiceBrowser couldn't be allocated and initialized.
		return;
	}
    
	aNetServiceBrowser.delegate = self;
	self.netServiceBrowser = aNetServiceBrowser;
	[aNetServiceBrowser release];
	[self.netServiceBrowser searchForServicesOfType:type inDomain:ZIGPAD_SYNC_DOMAIN];
}

- (void)stopCurrentResolve {
    
	[self.currentResolve stop];
	self.currentResolve = nil;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
	// If a service went away, stop resolving it if it's currently being resolved,
	// remove it from the list and update the table view if no more events are queued.
    
	if (self.currentResolve && [service isEqual:self.currentResolve]) {
		[self stopCurrentResolve];
	}
	[self.services removeObject:service];
	if (self.ownEntry == service)
		self.ownEntry = nil;
	
	// If moreComing is NO, it means that there are no more messages in the queue from the Bonjour daemon, so we should update the UI.
	// When moreComing is set, we don't update the UI so that it doesn't 'flash'.
	if (!moreComing) {
		//[self sortAndUpdateUI];
	}
}	

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
	// If a service came online, add it to the list and update the table view if no more events are queued.
	if ([service.name isEqual:self.ownName]) {
        NSLog(@"Found own Service.");
		self.ownEntry = service;
    } else {
        
        // If another resolve was running, stop it & remove the activity indicator from that cell
        if (self.currentResolve) {
            // Stop the current resolve, which will also set self.needsActivityIndicator
            [self stopCurrentResolve];
        }
        
        // Then set the current resolve to the service corresponding to the tapped cell
        self.currentResolve = service;
        [self.currentResolve setDelegate:self];
        
        // Attempt to resolve the service. A value of 0.0 sets an unlimited time to resolve it. The user can
        // choose to cancel the resolve by selecting another service in the table view.
        [self.currentResolve resolveWithTimeout:0.0];
        
        NSLog(@"Connecting to %@", service.name);
    }
}	

// This should never be called, since we resolve with a timeout of 0.0, which means indefinite
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
	[self stopCurrentResolve];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
	assert(service == self.currentResolve);
	
	[service retain];
	[self stopCurrentResolve];
    
    
	// note the following method returns _inStream and _outStream with a retain count that the caller must eventually release
	if (![service getInputStream:&_inStream outputStream:&_outStream]) {
        NSLog(@"Failed to connect to server.");
		return;
	}
    
    
    NSLog(@"Connected with %@!", service.name);
    
	[self openStreams];
    
    SyncEvent *event = [[SyncEvent alloc] init];
    event.command = CONNECTED;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZigPadSyncReceive" object:event];
    
    [event release];
    
	
	[service release];
}

- (void) send:(const uint8_t)message
{
	if (_outStream && [_outStream hasSpaceAvailable]) {
		if([_outStream write:(const uint8_t *)&message maxLength:sizeof(const uint8_t)] == -1) {
			NSLog(@"Failed sending data %d to peer", message);
        }
    }
}

- (void) openStreams
{
	_inStream.delegate = self;
	[_inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_inStream open];
	_outStream.delegate = self;
	[_outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outStream open];
    
    if (_outStream) {
        NSLog(@"Outstream is open.");
    }
    
    if (_inStream) {
        NSLog(@"Instream is open.");
    }
}

- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
	switch(eventCode) {
		case NSStreamEventOpenCompleted:
		{
			
			[_server release];
			_server = nil;
            
			if (stream == _inStream)
				_inReady = YES;
			else
				_outReady = YES;
			
			if (_inReady && _outReady) {
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

- (void) serverDidEnableBonjour:(TCPServer *)server withName:(NSString *)string
{
	NSLog(@"Enabled (%@)", string);
    self.ownName = string;
}

- (void)didAcceptConnectionForServer:(TCPServer *)server inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr
{
	if (_inStream || _outStream || server != _server)
		return;
	
	[_server release];
	_server = nil;
	
	_inStream = istr;
	[_inStream retain];
	_outStream = ostr;
	[_outStream retain];
    
    SyncEvent *event = [[SyncEvent alloc] init];
    event.command = CONNECTED;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZigPadSyncReceive" object:event];
    
    [event release];
    
    
    NSLog(@"Accepted connection from remote device");
	
	[self openStreams];
}


- (void)dealloc
{
    [self unregisterNotificationCenter];
    
    [_inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[_inStream release];
    
	[_outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[_outStream release];
    
	[_server release];
    [super dealloc];
}

@end


