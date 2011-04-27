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
    // If the Sequence Enumerater is nil, we're starting from the beginning,
    // and get the first Sequence.
    if (sequenceEnumerator == nil) {
        sequenceEnumerator = [self.sequences objectEnumerator];
        [sequenceEnumerator retain];
        activeSequence = [sequenceEnumerator nextObject];
    }
    
    // If the Action enumerator is nil, this is a new sequence.
    if (actionEnumerator == nil) {
        actionEnumerator = [activeSequence.actions objectEnumerator];
        [actionEnumerator retain];
    }
        
    // Try to get next action. Repeat until either the next action object was found or no more
    // sequences exist.
    do {
        activeAction = [actionEnumerator nextObject];
    
        if (activeAction) {
            return activeAction;
        }

        // If there are no remaining actions in the active Sequence, switch sequence and try again.
        activeSequence = [sequenceEnumerator nextObject];
        if (!activeSequence) {
            [sequenceEnumerator release];
            sequenceEnumerator = nil;
            [actionEnumerator release];
            actionEnumerator = nil;
            return nil;
        }
        [actionEnumerator release];
        actionEnumerator = [activeSequence.actions objectEnumerator];
        [actionEnumerator retain];

    } while (true);
}

- (NSArray *) orderedSequences {
    return [self orderedValueForKey:@"sequences"];
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
