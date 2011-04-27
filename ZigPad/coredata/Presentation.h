//
//  Presentation.h
//  ZigPad
//
//  Created by ceesar on 25/04/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BWOrderedManagedObject.h"
#import "Action.h"
#import "Sequence.h"

@interface Presentation : BWOrderedManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) id sequencesOrdering;
@property (nonatomic, retain) NSNumber * refId;

@property (nonatomic, retain) NSSet* sequences;

@property (nonatomic, retain) Sequence *activeSequence;
@property (nonatomic, retain) Action *activeAction;

- (void)addSequencesObject:(Sequence *)value;
- (Action*) getNextAction;
- (Action*) getPreviousAction;


@end
