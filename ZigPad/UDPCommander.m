//
//  UDPCommander.m
//  ZigPad
//
//  Created by ceesar on 23/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UDPCommander.h"


@implementation UDPCommander

-(id)init
{
	self = [super init];
	if (self != nil) {
        // Get the settings instance.
        ZigPadSettings *s = [ZigPadSettings sharedInstance];
        NSLog(@"Connecting to Host %@, port %d", s.ip, s.port);

        // Create an AsyncUdpSocket instance, bind to a local port
        // and connect to the configured host. This just means that the class
        // will only accept responses from that IP, no communication happens.
        udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
        [udpSocket bindToPort:4321 error:nil];
        [udpSocket connectToHost:s.ip onPort:s.port error:nil];
    }
    
	return self;
}

- (void) sendString:(NSString *)message
{
    // Get the string as ASCI encoded data.
    NSData *data = [message dataUsingEncoding: NSASCIIStringEncoding];
    
    // Send the data and start receiving with a timeout of 2s.
    [udpSocket sendData:data withTimeout:-1 tag:1];
    [udpSocket receiveWithTimeout:2 tag:1];
}

- (void) dealloc {
    [udpSocket close];
    [udpSocket release];
    
    [super dealloc];
}

#pragma mark AsyncUdpSocketDelegate

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
    NSString *response = [NSString stringWithCString:[data bytes] encoding:NSASCIIStringEncoding];
    NSLog(@"Got '%@' from %@:%i\n", response, host, port);
    
    return TRUE;
}

@end
