//
//  SynchTestViewController.h
//  ZigPad
//
//  Created by ceesar on 22/03/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import "TCPServer.h"

/**
 * This class manages connections to synchronized devices.
 * 
 * Each device is represented by a SynchronizerConnection instance, which can
 * either be an inbound or an outbound connection.
 * 
 */
@interface Synchronizer : NSObject <TCPServerDelegate,  NSNetServiceDelegate, NSNetServiceBrowserDelegate> {
    
    /**
     * Instance of the TCP server that allows others to connect to this device.
     */
	@private TCPServer			*_server;
    
    /**
     * Array of inbound connections. They are created in the TCPServer
     * delege methods.
     */
    @private NSMutableArray * inConnections;
    
    /**
     * Array of outbound connections. They are created in NSNetService delegate
     * methods.
     */
    @private NSMutableArray * outConnections;
    
    /**
     * Reference to the service browser.
     */
	@private NSNetServiceBrowser *netServiceBrowser;
    
    /**
     * Array containing the services that are currently being resolved.
     */
    @private NSMutableArray *currentResolve;
}

/**
 * Name of the service propagated by this device.
 */
@property (nonatomic, assign, readwrite) NSString *ownName;

/**
 * Start looking for devices for synchronization.
 */
- (void) lookForDevice;

/**
 * Stop resolving a service.
 *
 * @param service The service for which resolving should be stopped. If nil,
                  resolving is stopped for services
 */
- (void) stopCurrentResolve: (NSNetService *) service;

/**
 * Callback when recieving a sync event notification.
 */
- (void) fireSyncEvent: (NSNotification*) notification;

/**
 * Register for sync event notifications to be sent.
 */
- (void) registerNotificationCenter;

/**
 * Unregister from the notification center.
 */
- (void) unregisterNotificationCenter;

@end
