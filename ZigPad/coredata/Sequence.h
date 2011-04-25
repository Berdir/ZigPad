//
//  Sequence.h
//  ZigPad
//
//  Created by ceesar on 25/04/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BWOrderedManagedObject.h"
#import "LocalPicture.h"

@class Action, Presentation;

@interface Sequence : BWOrderedManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * command;
@property (nonatomic, retain) id actionsOrdering;
@property (nonatomic, retain) NSNumber * refId;

@property (nonatomic, retain) NSSet* presentations;
@property (nonatomic, retain) LocalPicture * icon;
@property (nonatomic, retain) NSSet* actions;

- (void)addActionsObject:(Action *)value;

@end
