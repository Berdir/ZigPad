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

/**
 * The Bonjour application protocol, which must:
 * 1) be no longer than 14 characters
 * 2) contain only lower-case letters, digits, and hyphens
 * 3) begin and end with lower-case letter or digit
 * It should also be descriptive and human-readable
 * See the following for more information:
 * http://developer.apple.com/networking/bonjour/faq.html
 */
NSString * const SERVICE_IDENTIFIER = @"zigpad";

/**
 * Domain for which the service should be propagated and searched.
 */
NSString * const SERVICE_DOMAIN = @"local";

@implementation Synchronizer

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
    for (SynchronizerConnection *connection in outConnections) {
        [connection send:notification.object];
    }
}

- (id)init {
    
    id i = [super init];
    
    if (i) {

        [self registerNotificationCenter];
        
        // Initialization of the server.
        _server = [TCPServer new];
        [_server setDelegate:self];
        NSError *error = nil;
        if(_server == nil || ![_server start:&error]) {
            if (error == nil) {
                NSLog(@"Failed creating server: Server instance is nil");
            } else {
                NSLog(@"Failed creating server: %@", error);
            }
            return i;
        }
        
        // Allocate the arrays used to store services and connections.
        inConnections = [[NSMutableArray alloc] initWithCapacity:10];
        outConnections = [[NSMutableArray alloc] initWithCapacity:10]; 
        currentResolve = [[NSMutableArray alloc] initWithCapacity:10];
        
        // Start advertising to clients, passing nil for the name to tell Bonjour
        // to pick use default name.
        if(![_server enableBonjourWithDomain:SERVICE_DOMAIN applicationProtocol:[TCPServer bonjourTypeFromIdentifier: SERVICE_IDENTIFIER] name:nil]) {
            NSLog(@"Failed advertising server");
            return i;
        }

        NSLog(@"Synchronizer successfully started");
    }
    
    return i;
}

- (void)lookForDevice {
    
    // Get service name.
    NSString *type = [TCPServer bonjourTypeFromIdentifier: SERVICE_IDENTIFIER];
    
    // Create a net service browser and start search for devices.
	netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    if (!netServiceBrowser) {
        return;
    }
	netServiceBrowser.delegate = self;
	[netServiceBrowser searchForServicesOfType:type inDomain: SERVICE_DOMAIN];
}

- (void)stopCurrentResolve: (NSNetService *) service {
    
    for (NSNetService *s in currentResolve) {
        // Loop over devices. If either the service is nil or equals to the
        // requested service, stop and remove it from the array.
        if (service == nil || [s isEqual: service]) {
            [service stop];
            [currentResolve removeObject:service];
        }
    }
}

#pragma mark -
#pragma mark NSNetService delegate methods

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
	
    // If a service went a way, remove the connection to it.
    SynchronizerConnection *toRemove = nil;
    for (SynchronizerConnection *conn in outConnections) {
        if ([conn.name isEqualToString: [service name]]) {
            toRemove = conn;
        }
    }
    if (toRemove) {
        [outConnections removeObject:toRemove];
    }
    
    
    // Also try removing it from the current resolve list.
    [self stopCurrentResolve: service];
}	

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
	// Ignore the own service.
	if ([service.name isEqual:self.ownName]) {
        NSLog(@"Found own Service.");
    } else {
        // Attempt to resolve the service. A value of 0.0 sets an unlimited time to resolve it. The user can
        // choose to cancel the resolve by selecting another service in the table view.
        [service setDelegate:self];
        [service resolveWithTimeout:0.0];
        [currentResolve addObject:service];
        
        NSLog(@"Connecting to %@", service.name);
    }
}	

/**
 * This should never be called, since we resolve with a timeout of 0.0, which means indefinite
 */
- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
	[self stopCurrentResolve:service];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    // Verify that we are currently resolving this service.
	assert([currentResolve containsObject:service]);
	
    // Stop resolving.
	[service retain];
    [self stopCurrentResolve:service];
    
    // Create a connection to this device.
    SynchronizerConnection *conn = [[SynchronizerConnection alloc] initWithService:service];
    [outConnections addObject:conn];
    NSLog(@"Created outbound connection to %@!", service.name);

    // Send a CONNECTED sync event.
    SyncEvent *event = [[SyncEvent alloc] init];
    event.command = CONNECTED;
    event.connection = conn;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZigPadSyncReceive" object:event];
    
    [conn release];
    [event release];
	[service release];
}

#pragma mark -
#pragma mark TCPServer delegate methods.

- (void) serverDidEnableBonjour:(TCPServer *)server withName:(NSString *)string
{
	NSLog(@"Enabled (%@)", string);
    self.ownName = string;
}

- (void)didAcceptConnectionForServer:(TCPServer *)server inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr
{
    
    SynchronizerConnection *conn = [[SynchronizerConnection alloc] initWithStreams: istr: ostr];
    [inConnections addObject:conn];
    [conn release];
    
    NSLog(@"Accepted inbound connection.");
}

#pragma mark -

- (void)dealloc
{
    [self unregisterNotificationCenter];

    [inConnections release];
    [outConnections release];
    [currentResolve release];
    
    [netServiceBrowser release];
    
	[_server release];
    [super dealloc];
}

@end


