//
//  SynchTestViewController.h
//  SynchTest
//
//  Created by ceesar on 22/03/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import "TCPServer.h"

@interface Synchronizer : NSObject <TCPServerDelegate, NSStreamDelegate,  NSNetServiceDelegate, NSNetServiceBrowserDelegate> {

	TCPServer			*_server;
	NSInputStream		*_inStream;
	NSOutputStream		*_outStream;
	BOOL				_inReady;
	BOOL				_outReady;
    
	NSNetService *_ownEntry;
	BOOL _showDisclosureIndicators;
	NSMutableArray *_services;
	NSNetServiceBrowser *_netServiceBrowser;
	NSNetService *_currentResolve;
	NSTimer *_timer;
	BOOL _needsActivityIndicator;
	BOOL _initialWaitOver;
    
    NSString *_ownName;
    
    
}

@property (nonatomic, retain, readwrite) NSNetService *ownEntry;
@property (nonatomic, assign, readwrite) BOOL showDisclosureIndicators;
@property (nonatomic, retain, readwrite) NSMutableArray *services;
@property (nonatomic, retain, readwrite) NSNetServiceBrowser *netServiceBrowser;
@property (nonatomic, retain, readwrite) NSNetService *currentResolve;
@property (nonatomic, retain, readwrite) NSTimer *timer;
@property (nonatomic, assign, readwrite) BOOL needsActivityIndicator;
@property (nonatomic, assign, readwrite) BOOL initialWaitOver;
@property (nonatomic, assign, readwrite) NSString *ownName;

- (void) lookForDevice;
- (void) stopCurrentResolve;
- (void) openStreams;	

- (void) fireSyncEvent: (NSNotification*) notification;
- (void) fireSyncEventTimed: (NSTimer*) theTimer;

@end
