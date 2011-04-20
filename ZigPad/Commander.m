//
//  Commander.m
//  ZigPad
//
//  Created by ceesar on 07/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Commander.h"
#import "AsyncUdpSocket.h"
#import "ZigPadSettings.h"


@implementation Commander

static Commander * _defaultCommander = nil;

NSString *currentIP;
int currentPort;

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
        
        ZigPadSettings *s = [ZigPadSettings sharedInstance];
        
        currentIP = s.ip;
        currentPort = s.port;

        NSLog(@"Connecting to Host %@, port %d", s.ip, s.port);
        [udpSocket connectToHost:currentIP onPort:currentPort error:nil];
	}
    
	return self;
}

- (void) sendString: (NSString*) message {
    NSData *data = [message dataUsingEncoding: NSASCIIStringEncoding];
    
    ZigPadSettings *s = [ZigPadSettings sharedInstance];
    if (![s.ip isEqualToString:currentIP] || s.port != currentPort) {
        currentIP = s.ip;
        currentPort = s.port;
        
        NSLog(@"Detected configuration change, re-connecting to Host %@, port %d", s.ip, s.port);
        
        udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
        [udpSocket bindToPort:4321 error:nil];
        
        [udpSocket connectToHost:currentIP onPort:currentPort error:nil];
    }
    
    [udpSocket sendData:data withTimeout:-1 tag:1];
    [udpSocket receiveWithTimeout:10 tag:1];
}
-(void) sendAction:(Action *)msg
{
    for (Param* p in msg.params)
    {
        
        if ([p.key isEqualToString:@"command"] ) 
        {
            [self sendString: p.value];
            NSLog(@"Sending action command %@" ,p.value);
            break;
        }
        
    }
    
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
    NSString *response = [NSString stringWithCString:[data bytes] encoding:NSASCIIStringEncoding];
    NSLog(@"Got '%@' from %@:%i\n", response, host, port);
    
    return TRUE;
}

@end
