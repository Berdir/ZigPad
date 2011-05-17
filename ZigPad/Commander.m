//
//  Commander.m
//  ZigPad
//
//  Created by ceesar on 07/04/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import "Commander.h"
//#import "AsyncUdpSocket.h"
#import "AsyncTCPSocket.h"
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
        
        /*
         //variante udp       
        ZigPadSettings *s = [ZigPadSettings sharedInstance];
        NSLog(@"Connecting to Host %@, port %d", s.ip, s.port);
        udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
        [udpSocket bindToPort:4321 error:nil];
        [udpSocket connectToHost:s.ip onPort:s.port error:nil];
         */
        
        //variante tcp
        tcpSocket = [[AsyncTCPSocket alloc] initWithDelegate:self];
        
        
        }
    
	return self;
}

- (void) sendString: (NSString*) message {
    NSData *data = [message dataUsingEncoding: NSASCIIStringEncoding];
    
    /*
     //variante udp
    [udpSocket sendData:data withTimeout:-1 tag:1];
    [udpSocket receiveWithTimeout:2 tag:1];
     */
    
    //variante tcp
    ZigPadSettings *s = [ZigPadSettings sharedInstance];
    NSLog(@"Connecting to Host %@, port %d", s.ip, s.port);
    [tcpSocket disconnect]; //do it, if not already done
    
    bool success = [tcpSocket connectToHost:s.ip onPort:s.port error:nil];
    if (success) 
        NSLog(@"gira connected");
    
    [tcpSocket writeData:data withTimeout:500 tag:1];
    [tcpSocket readDataWithTimeout:500 tag:1];
    
    [tcpSocket disconnectAfterReadingAndWriting];
    
    
}
-(void) sendAction:(Action *)msg
{
    Param *p = [msg getParamForKey:@"command"];
    if (p != nil) {
       [self sendString: p.value];
        NSLog(@"Sending action command %@" ,p.value);
    }
}

/*
 //if we want udp
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
    NSString *response = [NSString stringWithCString:[data bytes] encoding:NSASCIIStringEncoding];
    NSLog(@"Got '%@' from %@:%i\n", response, host, port);
    
    return TRUE;
}
 */
// if we want TCP
- (void)onSocket:(AsyncTCPSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    NSString *response = [NSString stringWithCString:[data bytes] encoding:NSASCIIStringEncoding];
    NSLog(@"Got '%@' from Simulator\n", response);

}


- (void) dealloc {
    /*
    [udpSocket close];
    [udpSocket release];
     */
    [tcpSocket disconnect];
    [tcpSocket release];
    
    [super dealloc];
}

@end
