//
//  UDPCommander.h
//  ZigPad
//
//  Created by ceesar on 23/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Commander.h"
#import "AsyncUdpSocket.h"

/**
 * UDP implementation of the abstract Commander class.
 */ 
@interface UDPCommander : Commander <AsyncUdpSocketDelegate>
{
    @private
        /**
         * Instance of the AsyncUdpSocket.
         */
        AsyncUdpSocket *udpSocket;
}

@end
