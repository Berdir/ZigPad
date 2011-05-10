//
//  SynchTestViewController.m
//  SynchTest
//
//  Created by ceesar on 22/03/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import "Synchronizer.h"
#import "SyncEvent.h"
#import "SynchronizerConnection.h"

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


- (void) fireSyncEvent: (NSNotification *) notification {
    for (SynchronizerConnection *connection in connections) {
        [connection send:notification.object];
    }
}

- (id)init {
    
    id i = [super init];
    NSLog(@"Setup...");
    [_server release];
	_server = nil;
	
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
    
    connections = [[NSMutableArray alloc] initWithCapacity:10];
    self.currentResolve = [[NSMutableArray alloc] initWithCapacity:10];
	
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
    
    for (NSNetService *service in _currentResolve) {
        [service stop];
    }
    [self.currentResolve release];
    self.currentResolve = [[NSMutableArray alloc] initWithCapacity:10];

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
        [service setDelegate:self];
        
        // Attempt to resolve the service. A value of 0.0 sets an unlimited time to resolve it. The user can
        // choose to cancel the resolve by selecting another service in the table view.
        [service resolveWithTimeout:0.0];
        
        [self.currentResolve addObject:service];
        
        NSLog(@"Connecting to %@", service.name);
    }
}	

// This should never be called, since we resolve with a timeout of 0.0, which means indefinite
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
	[self stopCurrentResolve];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
	assert([_currentResolve containsObject:service]);
	
	[service retain];
    [service stop];
    [_currentResolve removeObject:service];
    
    SynchronizerConnection *conn = [[SynchronizerConnection alloc] initWithService:service];
    [connections addObject:conn];
    NSLog(@"Connected with %@!", service.name);
    
    SyncEvent *event = [[SyncEvent alloc] init];
    event.command = CONNECTED;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZigPadSyncReceive" object:event];
    
    [event release];
    
	
	[service release];
}

- (void) serverDidEnableBonjour:(TCPServer *)server withName:(NSString *)string
{
	NSLog(@"Enabled (%@)", string);
    self.ownName = string;
}

- (void)didAcceptConnectionForServer:(TCPServer *)server inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr
{
	//[_server release];
	//_server = nil;
    
    SynchronizerConnection *conn = [[SynchronizerConnection alloc] initWithStreams: istr: ostr];
    [connections addObject:conn];
    
    SyncEvent *event = [[SyncEvent alloc] init];
    event.command = CONNECTED;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZigPadSyncReceive" object:event];
    
    [event release];
    
    NSLog(@"Accepted connection from remote device");

}

- (void)dealloc
{
    [self unregisterNotificationCenter];

    [connections release];
    [_currentResolve release];
    
	[_server release];
    [super dealloc];
}

@end


