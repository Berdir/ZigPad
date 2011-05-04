//
//  Commander.m
//  ZigPad
//
//  Created by ceesar on 07/04/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import "Commander.h"
#import "AsyncUdpSocket.h"
#import "ZigPadSettings.h"


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

+(void) close {
    [_defaultCommander release];
    _defaultCommander = nil;
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

        NSLog(@"Connecting to Host %@, port %d", s.ip, s.port);
        [udpSocket connectToHost:s.ip onPort:s.port error:nil];
	}
    
	return self;
}

- (void) sendString: (NSString*) message {
    NSData *data = [message dataUsingEncoding: NSASCIIStringEncoding];
    
    [udpSocket sendData:data withTimeout:-1 tag:1];
    [udpSocket receiveWithTimeout:2 tag:1];
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

- (void) dealloc {
    [udpSocket close];
    [udpSocket release];
    [super dealloc];
}

@end
