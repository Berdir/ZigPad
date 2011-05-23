//
//  TCPCommander.m
//  ZigPad
//
//  Created by ceesar on 23/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TCPCommander.h"


@implementation TCPCommander

- (void) sendString:(NSString *)message
{
    NSData *data = [message dataUsingEncoding: NSASCIIStringEncoding];
    
    ZigPadSettings *s = [ZigPadSettings sharedInstance];
    
    NSLog(@"Sending command '%@'", message);
    
    // Initialize new every times of this method call because it otherwise
    // only sends a single time for every connection.
    AsyncTCPSocket *tcpSocket = [[AsyncTCPSocket alloc] initWithDelegate:self];
    
    [tcpSocket connectToHost:s.ip onPort:s.port error:nil];
    NSLog(@"Connected to Host %@, port %d", s.ip, s.port);
    
    [tcpSocket writeData:data withTimeout:500 tag:1];
    [tcpSocket readDataWithTimeout:500 tag:1];
    
    [tcpSocket disconnectAfterReadingAndWriting];
    
    [tcpSocket release];
}

#pragma mark AsyncTCP Socket delegates

- (void)onSocket:(AsyncTCPSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *response = [NSString stringWithCString:[data bytes] encoding:NSASCIIStringEncoding];
    NSLog(@"Got Response: '%@'", response);
    
}

@end
