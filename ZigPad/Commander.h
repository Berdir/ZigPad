//
//  Commander.h
//  ZigPad
//
//  Created by ceesar on 07/04/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "AsyncUdpSocket.h"
#import "AsyncTCPSocket.h"
#import "Action.h"
#import "Param.h"


@interface Commander : NSObject{
//@interface Commander : NSObject <AsyncUdpSocketDelegate> {
   @private
     //AsyncUdpSocket *udpSocket;
    AsyncTCPSocket *tcpSocket;
}

+(Commander*) defaultCommander;
+(void) close;

-(void) sendString: (NSString* )message;
-(void) sendAction: (Action* )message;


@end
