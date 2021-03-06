//
//  Presentation.h
//  ZigPad
//
//  Created by ceesar on 25/04/11.
//  Copyright (c) 2011 CEESAR. All rights reserved.
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
@property (nonatomic, readonly) NSArray* orderedSequences;

@property (nonatomic, retain) Sequence *activeSequence;
@property (nonatomic, retain) Action *activeAction;

@property (nonatomic, retain) NSMutableArray* indexMapping;

@property (nonatomic, readonly) int currentSequenceIndex;
@property (nonatomic, readonly) int currentActionIndex;

- (void)addSequencesObject:(Sequence *)value;
- (Action*) getNextAction;
- (Action*) getPreviousAction;
- (Action*) jumpToSequence: (int) index;
- (Action*) jumpToAction: (int) actionIndex sequenceIndex: (int) sequenceIndex;
- (void) resetPresentation;

@end
