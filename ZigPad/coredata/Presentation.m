//
//  Presentation.m
//  ZigPad
//
//  Created by ceesar on 25/04/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Presentation.h"
#import "Sequence.h"


@implementation Presentation
@dynamic name;
@dynamic comment;
@dynamic sequencesOrdering;
@dynamic refId;
@dynamic sequences;

@synthesize activeSequence;
@synthesize activeAction;

int sequencesIndex = 0;
int actionsIndex = 0;

NSEnumerator *sequenceEnumerator = nil;
NSEnumerator *actionEnumerator = nil;
Sequence *activeSequence = nil;
Action *activeAction = nil;


- (void)addSequencesObject:(Sequence *)value {    
    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"sequences" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"sequences"] addObject:value];
    [self didChangeValueForKey:@"sequences" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeSequencesObject:(Sequence *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"sequences" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"sequences"] removeObject:value];
    [self didChangeValueForKey:@"sequences" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addSequences:(NSSet *)value {
    [self willChangeValueForKey:@"sequences" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"sequences"] unionSet:value];
    [self didChangeValueForKey:@"sequences" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeSequences:(NSSet *)value {
    [self willChangeValueForKey:@"sequences" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"sequences"] minusSet:value];
    [self didChangeValueForKey:@"sequences" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

-  (Action*) getNextAction {
    // If the active sequence is nil, we're starting from the beginning,
    // and get the first sequence.
    if (!activeSequence) {
        sequencesIndex = 0;
        if ([self countOfOrderedValueForKey:@"sequences"] > sequencesIndex) {
            activeSequence = (Sequence *) [self objectInOrderedValueForKey:@"sequences" atIndex:sequencesIndex++];
        }
        else {
            return nil;
        }
    }
    
    // If the active action is nil, this is a new sequence.
    if (!activeAction) {
        actionsIndex = 0;
    }
        
    // Try to get next action. Repeat until either the next action object was found or no more
    // sequences exist.
    do {
        if ([activeSequence countOfOrderedValueForKey:@"actions"] > actionsIndex) {
            activeAction = (Action *) [activeSequence objectInOrderedValueForKey:@"actions" atIndex:actionsIndex++];
            return activeAction;
        }

        // If there are no remaining actions in the active Sequence, switch sequence and try again.
        if ([self countOfOrderedValueForKey:@"sequences"] > sequencesIndex) {
            activeSequence = (Sequence *) [self objectInOrderedValueForKey:@"sequences" atIndex:sequencesIndex++];
            actionsIndex = 0;
        }
        else {
            activeSequence = nil;
            activeAction = nil;
            return nil;
        }
    } while (true);
}

- (NSArray *) orderedSequences {
    return [self orderedValueForKey:@"sequences"];
}

- (Action*) getPreviousAction {
    do {
        if (actionsIndex > 1) {
            activeAction =  activeAction = (Action *) [activeSequence objectInOrderedValueForKey:@"actions" atIndex:(--actionsIndex) - 1];
            return activeAction;
        }
        else if (sequencesIndex > 1) {
            activeSequence = (Sequence *) [self objectInOrderedValueForKey:@"sequences" atIndex:(--sequencesIndex) - 1];
            actionsIndex = [activeSequence.actions count];
        }
        else {
            return nil;
        }
    } while (true);
    return nil;  
}

- (Action*) jumpToSequence: (int) index {
    sequencesIndex = index;
    activeSequence = (Sequence *) [self objectInOrderedValueForKey:@"sequences" atIndex:sequencesIndex++];
    
    actionsIndex = 0;
    activeAction = (Action *) [activeSequence objectInOrderedValueForKey:@"actions" atIndex:actionsIndex++];
    return activeAction;
}


- (void) dealloc {
    if (sequenceEnumerator && [sequenceEnumerator retainCount]) {
        [sequenceEnumerator release];
        sequenceEnumerator = nil;
    }
    if (actionEnumerator && [actionEnumerator retainCount]) {
        [actionEnumerator release];
        actionEnumerator = nil;
    }
    [super dealloc];
}

@end
