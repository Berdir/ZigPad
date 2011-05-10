//
//  SynchTestViewController.h
//  SynchTest
//
//  Created by ceesar on 22/03/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import "TCPServer.h"

@interface Synchronizer : NSObject <TCPServerDelegate,  NSNetServiceDelegate, NSNetServiceBrowserDelegate> {

	TCPServer			*_server;
    
    NSMutableArray * connections;
    
	NSNetService *_ownEntry;
	BOOL _showDisclosureIndicators;
	NSMutableArray *_services;
	NSNetServiceBrowser *_netServiceBrowser;
	NSMutableArray *_currentResolve;
	NSTimer *_timer;
	BOOL _needsActivityIndicator;
	BOOL _initialWaitOver;
    
    NSString *_ownName;
    
    
}

@property (nonatomic, retain, readwrite) NSNetService *ownEntry;
@property (nonatomic, assign, readwrite) BOOL showDisclosureIndicators;
@property (nonatomic, retain, readwrite) NSMutableArray *services;
@property (nonatomic, retain, readwrite) NSNetServiceBrowser *netServiceBrowser;
@property (nonatomic, retain, readwrite) NSMutableArray *currentResolve;
@property (nonatomic, retain, readwrite) NSTimer *timer;
@property (nonatomic, assign, readwrite) BOOL needsActivityIndicator;
@property (nonatomic, assign, readwrite) BOOL initialWaitOver;
@property (nonatomic, assign, readwrite) NSString *ownName;

- (void) lookForDevice;
- (void) stopCurrentResolve;

- (void) fireSyncEvent: (NSNotification*) notification;

@end
