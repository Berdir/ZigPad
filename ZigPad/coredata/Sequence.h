//
//  Sequence.h
//  ZigPad
//
//  Created by ceesar on 25/04/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "LocalPicture.h"
#import "OrderingPlugin.h"

@class Action, Presentation;

@interface Sequence : OrderingPlugin {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * command;
@property (nonatomic, retain) NSNumber * refId;

@property (nonatomic, retain) NSSet* presentations;
@property (nonatomic, retain) LocalPicture * icon;
@property (nonatomic, retain) NSSet* actions;


- (void)addActionsObject:(Action *)value;

@end
