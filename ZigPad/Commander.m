//
//  Commander.m
//  ZigPad
//
//  Created by ceesar on 07/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Commander.h"
#import "AsyncUdpSocket.h"


@implementation Commander

static Commander * _defaultCommander = nil;

+(Commander*) defaultCommander {
    
    @synchronized([Commander class])
	{
		if (!_defaultCommander)
			[[self alloc] init];
        
		return _defaultCommander;
	}
    
	return nil;
}

+(id)alloc
{
	@synchronized([Commander class])
	{
		NSAssert(_defaultCommander == nil, @"Attempted to allocate a second instance of a singleton.");
		_defaultCommander = [super alloc];
		return _defaultCommander;
	}
    
	return nil;
}

-(id)init {
	self = [super init];
	if (self != nil) {
        udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
        [udpSocket bindToPort:4321 error:nil];
	}
    
	return self;
}

- (void) send: (NSString*) message {
    NSData *data = [message dataUsingEncoding: NSASCIIStringEncoding];
    
    //@todo Configure
    [udpSocket sendData:data toHost:@"127.0.0.12" port:1234 withTimeout:-1 tag:1];
    [udpSocket receiveWithTimeout:10 tag:1];
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
    NSString *response = [NSString stringWithCString:[data bytes] encoding:NSASCIIStringEncoding];
    NSLog(@"Got '%@' from %@:%i\n", response, host, port);
    
    return TRUE;
}

@end
