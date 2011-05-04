//
//  SyncEvent.h
//  ZigPad
//
//  Created by ceesar on 04/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SELECT = 83,
    JUMP = 74,
} SyncEventCommand;


@interface SyncEvent : NSObject {
    
}

@property (readwrite) SyncEventCommand command;
@property (readwrite) uint16_t argument;

@end
