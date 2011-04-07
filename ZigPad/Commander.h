//
//  Commander.h
//  ZigPad
//
//  Created by ceesar on 07/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncUdpSocket.h"



@interface Commander : NSObject <AsyncUdpSocketDelegate> {
   @private
     AsyncUdpSocket *udpSocket;
}

+(Commander*) defaultCommander;

-(void) send: (NSString* )message;

@end
